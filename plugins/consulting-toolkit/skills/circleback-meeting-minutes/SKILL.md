---
name: circleback-meeting-minutes
description: Circleback MCP が接続されている環境で使用する。「Circlebackから議事録を作って」「過去1週間の会議の議事録を作成して」「Circlebackの会議をMDにして」「先週のミーティング議事録をまとめて」「先週の会議を整理して」「○○MTGの議事録だけ作って」「会議名を指定して議事録化」「5/20〜5/26の△△の会議だけまとめて」などのリクエスト時に使用。
---

# Circleback 議事録一括作成スキル

Circleback MCP から会議を取得して議事録 MD を生成する。取得対象は **(A) ユーザーが指定した絞り込み条件（会議名・期間）に該当する会議**、指定がなければ **(B) 過去1週間（デフォルト）の会議からプロジェクト関連のものをスコアリング抽出** する。`meeting-minutes-creator` / `interview-minutes-creator` を再利用し、複数件はサブエージェントで並列処理する。

## 設計原則: 親が取得→ワーカーにファイルで渡す

サブエージェントのツール権限はホスト環境によって変動し、MCP ツール（`mcp__claude_ai_Circleback__*`）がワーカーに露出しないケースがある。そのため、本スキルでは:

- **親（本スキル）**が Circleback MCP を直接呼んでトランスクリプト・会議詳細を取得し、`/tmp` に分割保存する
- **ワーカー**は Read / Write / Bash の最小権限のみで動作し、指定ファイルから読み込んで議事録 MD を生成する

これにより MCP ツール名の環境差異（UUID プレフィックス）を吸収し、ワーカーの再現性を確保する。

## Circleback MCP フィールド名（実証済み）

| 概念 | フィールド名 |
|---|---|
| 会議 ID | `id`（数値）、`linkId`（文字列） |
| 会議名 | `name` |
| 作成日時 | `createdAt`（ISO 8601 UTC） |
| 参加者 | `attendees[].name`、`attendees[].email`（ボットは null） |
| 要約 | `notes`（Markdown テキスト） |
| アクションアイテム | `actionItems[].{title, description, assignee.name, status}` |
| タグ | `tags`（配列、空の場合あり） |
| トランスクリプトセグメント | `{speaker, text, timestamp}` / 環境によっては `{speaker, words, startTimestamp, endTimestamp}` |

## ワークフロー

### Step 0: フィルタ指定の解析とモード判定

スキルの ARGUMENTS 文字列と、起動時のユーザー自然文の両方から明示フィルタを抽出する（例「先週のフジトラMTGの議事録だけ作って」＝期間＋会議名の混在）:

- **会議名キーワード（searchTerm）**: 「○○MTG の」「△△の会議」「<固有名> の議事録」等から、会議名 or notes に直接マッチさせるキーワードを 1 語句抽出する
- **期間**: 「過去 X 日」「MM/DD〜MM/DD」「先週」「今週」「N 月」等

モード判定:

| 条件 | モード |
|---|---|
| 会議名キーワードを抽出できた | **A: 明示フィルタモード** |
| 会議名なし（期間のみ or 指定なし） | **B: プロジェクト探索モード**（既存動作） |

- **モード A**: Step 4 で `searchTerm`＋期間により該当会議のみを取得し、**Step 5（スコアリング）・Step 6 のグルーピング UX をスキップ**する。Step 3（プロジェクトキーワード抽出）は Step 7 の議事録タイプ判定・interview worker の `projectContext` に必要なため**実行する**。
- **モード B**: 従来どおり全 Step を実行する。
- 判定したモードと抽出フィルタ（会議名・期間）を会話中に 1 行で提示してから次へ進む（AskUserQuestion 不要）。

> タグ・参加者での絞り込みは `SearchMeetings` の `tags`（ListTags で ID 解決）・`profiles`/`domains`（FindProfiles で ID 解決）で実現可能だが、現行スコープ外（将来拡張余地）。

### Step 1: 期間決定

Step 0 で期間を抽出できていればそれを使う。**期間指定がない場合のデフォルト**: 今日から 7 日前（`startDate`・`endDate` を `YYYY-MM-DD` 形式で計算）。「過去 X 日」「MM/DD〜MM/DD」「先週」「今週」「N 月」等の指定があれば優先。期間を会話中に提示して次へ進む（AskUserQuestion 不要）。

**モード A で会議名のみ指定・期間指定なしの場合**: 会議名で直接絞るため、取りこぼし防止に検索窓を広めに取りデフォルト 30 日とする（0 件なら 90 日への拡張を提案）。

### Step 2: Circleback MCP ツール名の動的解決

ToolSearch で以下の3キーワードを検索し、返却されたフル名を記録する。UUID プレフィックスは環境ごとに異なるため、毎回動的に取得すること。**3つの ToolSearch は1メッセージ内の3回のツール呼び出しとしてまとめて発行**し、往復を1回に短縮する（ハーネスが独立呼び出しを並列実行する）。

```
ToolSearch(query="+SearchMeetings", max_results=1)
ToolSearch(query="+ReadMeetings", max_results=1)
ToolSearch(query="+GetTranscriptsForMeetings", max_results=1)
```

1 件もマッチしなければ「Circleback MCP が未接続です。`/mcp` で接続後に再実行してください」と案内して終了。

**親側で解決したツール名は親自身が使用する。ワーカーには渡さない**（ワーカーは MCP を呼ばない設計のため）。

### Step 3: プロジェクトキーワード抽出

以下を優先順に Read し、最初に存在するソースから `clientName`・`projectName`・スコープ固有名詞 3〜5 語を抽出する:

1. `Output/プロジェクトサマリ.md`
2. `workflow.md`
3. `CLAUDE.md`

全て不在の場合 → AskUserQuestion でクライアント名を 1 度だけ尋ねる（空回答なら全件マニュアル選択モードへ）。

> **モード A（明示フィルタ）の場合**: ここでの抽出はスコアリングに使わない（Step 5 をスキップするため）。ソースが全て不在でも**クライアント名は尋ねず**そのまま進む（`projectContext` は取得できた範囲のみ interview worker に渡す）。

### Step 4: SearchMeetings ページング取得

**モード A（明示フィルタ）**: `searchTerm` に Step 0 の会議名キーワードを渡す（会議名・notes への大小無視の直接マッチ）。

```
SearchMeetings(intent="指定された会議名の議事録作成のため該当会議を取得", searchTerm="<会議名キーワード>", startDate=..., endDate=..., pageIndex=0)
```

**モード B（プロジェクト探索）**: `searchTerm` は渡さず期間のみで取得する。

```
SearchMeetings(intent="プロジェクト関連会議を期間で取得", startDate=..., endDate=..., pageIndex=0)
```

返却件数が 20 件ちょうどなら `pageIndex+1` で繰り返す（20 件未満で終了と判断）。次ページ取得時は `startDate`/`endDate`/`searchTerm` を**完全に同一**にすること（pageIndex は同一検索条件でのみ有効）。最大 10 ページ（200 件）で打ち切り＋警告。

> **API 注記**: `searchTerm` を指定した検索のレスポンスは intent に基づく**抜粋ベース**で、`notes` 等の完全データを含まないことがある。会議の完全データは Step 7.5 の `ReadMeetings` で取得するため問題ないが、検索レスポンスの `notes` をそのまま議事録に使わないこと。

**ボット除外**: `attendees[].name` に「Circleback」「AI Notetaker」「tldv」「Notetaker」等を含み `email` が null の参加者は、スコアリング（モード B）および Step 7 の議事録タイプ判定の対象外とする。

### Step 5: 関連度スコアリング（モード B のみ）

> **モード A（明示フィルタ）ではこの Step をスキップ**し、Step 4 で取得した該当会議をそのまま処理対象とする（グルーピングへは進まず、Step 6 の「モード A の件数分岐」→ Step 7 へ）。

各会議を以下でスコアリング（部分一致・大文字小文字無視）:

| 信号 | 配点 |
|---|---|
| `name` に clientName または projectName 含む | +3 |
| `name` に抽出キーワード 1 語以上含む | +2 |
| `attendees[].email` のドメイン（@ 以降）に clientName 含む | +3 |
| `notes` に clientName または抽出キーワード ≥2 語含む | +2 |
| `tags` に clientName / projectName 由来の文字列含む | +2 |
| いずれもマッチせず全参加者が社内（email null または一致しない） | −2 |

分類: **確実**（≥5）/ **おそらく**（3〜4）/ **不確実**（1〜2）/ **該当しない**（≤0）

### Step 6: 選択 UX

#### モード A（明示フィルタ）: 該当件数による分岐

- **0 件** → 「指定の会議名『<キーワード>』に該当する会議は期間内に見つかりませんでした」と報告。`searchTerm` を外して同期間を再取得し、存在した会議名の一覧を提示する。キーワードの変更 or 期間の拡張を提案して終了。
- **1 件** → 確認なしでそのまま Step 7 へ（処理対象を 1 行提示）。
- **2 件以上** → 該当会議を**全件チェック済み**の状態で AskUserQuestion（multiSelect）を 1 回提示し、除外したいものがあれば外してもらう。

#### モード B（プロジェクト探索）: グルーピング選択

確実・おそらくが両方 0 件の場合 → 「自動判定では見つかりませんでした。全件を表示しますか？」と AskUserQuestion して終了 or 全件提示。

候補がある場合は **AskUserQuestion を multiSelect で 1 回**:

- `[A] 確実 N件をすべて処理（推奨）`
- `[B] おそらく M件もすべて処理`
- `[C] 不確実 K件のうち個別に選択する`
- `[D] 全件を一覧で見て個別選択する`

C を選んだ場合のみ、不確実リストを別の AskUserQuestion で個別確認。

### Step 7: 議事録タイプ判定（meeting vs interview）

各会議を以下の優先順で判定する:

1. `workflow.md` が存在し、Step 8（議事メモ作成）が `not_started` / `in_progress` → **強い interview 推定**
2. `Output/インタビューガイド.md` が存在し、`name` に「インタビュー」「ヒアリング」「Interview」「I/V」含む → **interview**
3. ボット除外後の参加者が「社外メールあり 1 名 + 残り email null または社内」構成 → **弱い interview 推定**
4. 上記外 → **meeting**

interview 型が 1 件以上含まれる場合のみ **AskUserQuestion を 1 回**:
- `Output/議事録/`（interview の標準保存先）
- `Meeting/`（通常会議と同じフォルダ）
- その他のパスを指定

meeting 型は問答無用で `Meeting/` へ。フォルダが存在しない場合は `mkdir -p` で作成。

### Step 7.5: トランスクリプト・会議詳細の一括取得＆ファイル化（重要）

ワーカーは MCP を呼ばないため、**親で一括取得して /tmp に分割保存**する。

#### 7.5.1 一括取得

対象会議の ID（または linkId）を最大 50 件まで `ReadMeetings` と `GetTranscriptsForMeetings` にまとめて渡す。**この2つは1メッセージ内の2回のツール呼び出しとして同時発行**し、逐次実行を避けて1往復分短縮する（1回の呼び出しで両方を取得する API はない）。

```
ReadMeetings(intent="議事録生成のため会議詳細を一括取得", meetingIds=[<id1>, <id2>, ...])
GetTranscriptsForMeetings(intent="議事録生成のためトランスクリプトを一括取得", meetingIds=[<id1>, <id2>, ...])
```

**大容量レスポンス**: `GetTranscriptsForMeetings` のレスポンスは MCP 側で自動的にファイル化される場合がある（context overflow 回避）。その場合は返却された一時ファイルパスをそのまま分割処理の入力とする。

#### 7.5.2 作業ディレクトリ作成

```bash
WORK="/tmp/circleback-minutes-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$WORK"
```

#### 7.5.3 Python で会議ごとに分割保存＋トランスクリプト整形

会議詳細は JSON で分割保存し、**トランスクリプトはここで決定論的に整形して `.txt` 化**する（ワーカー側の LLM 整形を不要化＝高速化の主レバー）。整形はロスレス（連続する同一話者の単純連結のみ。タイムスタンプは本文から除去、生データは別ファイルに保持）。

```python
import json, os, re

WORK = "<上で作成したディレクトリ>"

# トランスクリプト (一括レスポンスまたは MCP 自動ファイル化された結果)
with open(TRANSCRIPT_SRC, "r") as f:
    transcripts = json.load(f)

# 会議詳細 (一括レスポンス)
with open(MEETINGS_SRC, "r") as f:
    meetings = json.load(f)

def safe_slug(name, date_str):
    # YYYYMMDD_<会議名> 形式。禁則文字置換、空白→_
    s = re.sub(r"[/\\:*?\"<>|\s]+", "_", name).strip("_")
    return f"{date_str}_{s}"

def flatten_transcript(t):
    """transcript セグメント → 話者付きプレーンテキスト（ロスレス整形）。
    - 発言テキストは words 優先、なければ text
    - 連続する同一話者セグメントのみ単純連結（A→B→A は保持。時間ギャップ判断はしない）
    - per-segment タイムスタンプは本文に含めない（議事録に使われないため）
    両セグメント形式 {speaker,text,timestamp} / {speaker,words,startTimestamp,endTimestamp} に対応。
    """
    segs = t.get("transcript") or t.get("segments") or []
    lines, cur_spk, buf = [], None, []
    def flush():
        if buf:
            lines.append(f"{cur_spk}:\n" + " ".join(buf).strip())
    for s in segs:
        spk = (s.get("speaker") or "").strip() or "（話者不明）"
        txt = (s.get("words") or s.get("text") or "").strip()
        if not txt:
            continue
        if spk == cur_spk:
            buf.append(txt)
        else:
            flush()
            cur_spk, buf = spk, [txt]
    flush()
    return "\n\n".join(lines)

# meetingId（linkId or 数値 id）→ slug マッピング
slug_map = {}
for m in meetings:
    date_jst = m["createdAt"][:10].replace("-", "")  # YYYYMMDD
    slug = safe_slug(m["name"], date_jst)
    mid = m.get("linkId") or m["id"]
    slug_map[mid] = slug
    with open(f"{WORK}/meeting_{slug}.json", "w") as g:
        json.dump(m, g, ensure_ascii=False, indent=2)

# トランスクリプトを linkId / id で対応付け、(1) 生 JSON を退避 (2) 整形済み .txt を生成
for t in transcripts:
    mid = t.get("meetingId") or t.get("linkId") or t.get("id")
    slug = slug_map.get(mid) or safe_slug(t.get("meetingName", str(mid)), "unknown")
    # (1) 参照用に生データを保持（通常ワーカーには渡さない）
    with open(f"{WORK}/transcript_raw_{slug}.json", "w") as g:
        json.dump(t, g, ensure_ascii=False, indent=2)
    # (2) ワーカーが直接読む整形済みテキスト（再整形不要）
    with open(f"{WORK}/transcript_{slug}.txt", "w") as g:
        g.write(flatten_transcript(t))
```

#### 7.5.4 ワーカーに渡すパス確定

各会議について以下を控えておく:
- `meetingDetailsPath`: `<WORK>/meeting_<slug>.json`
- `transcriptPath`: `<WORK>/transcript_<slug>.txt`（親で整形済みのプレーンテキスト。ワーカーはそのまま使う）
- （参照用）整形前の生データは `<WORK>/transcript_raw_<slug>.json` に保持。通常ワーカーには渡さない

### Step 8: 並列実行

**ファイル名（必須遵守）**: `YYYY-MM-DD_<会議名>_議事録.md`

- **日付は必ず先頭** に置く。`meeting-minutes_<日付>_xxx.md` のように日付を後ろに置く形式は禁止
- 日付は `createdAt` から抽出（JST 換算）
- `<会議名>` は Circleback の `name` を使用（英語スラグへの変換はしない）
- 禁則文字（`/\:*?"<>|` と空白）は `_` に置換
- 同名衝突時は `_v2`, `_v3` を付与

`circleback-minutes-worker` サブエージェントは **1 メッセージ内に複数の Agent 呼び出しをまとめてディスパッチ**し、同時実行させる（逐次起動は禁止）。**並列上限は 8**（実効同時実行数はハーネス依存。環境が許す範囲で 8 まで）。9 件超は 8 件ずつの波で処理し、波内のワーカーは必ず 1 メッセージでまとめて起動する。

> Opus のまま並列数を上げるとレート制限・リソース競合が起きうる。失敗が頻発する場合は波サイズを 5 などに縮小する。

**各ワーカーへのプロンプトに含める情報（新仕様）**:
- `meetingType`: `meeting` または `interview`
- `outputPath`: 保存先の絶対パス（ファイル名含む）
- `transcriptPath`: Step 7.5.3 で生成した**整形済みトランスクリプト `.txt`** の絶対パス（ワーカーは JSON 再整形をしない）
- `meetingDetailsPath`: Step 7.5.3 で分割保存した会議詳細 JSON の絶対パス
- `projectContext`: interview の場合のみ、プロジェクトサマリ抜粋テキスト
- `documentGuidelines`: クライアント文書ガイドラインの要旨（CLAUDE.md から抜粋、任意）

**渡してはいけない情報**:
- `readMeetingsTool` / `getTranscriptsTool`（ワーカーは MCP を呼ばない）
- トランスクリプト本文や会議 notes の生テキスト（ファイルパス経由で渡す）

### Step 9: 完了報告とクリーンアップ

- 生成ファイルの絶対パスと 1 行サマリ（誰と何を話したか、60 字以内）
- 失敗した会議と理由（トランスクリプト空・API エラー等）
- 未処理の不確実件数
- **クリーンアップ**: 全ワーカー完了後、`/tmp/circleback-minutes-*` ディレクトリは削除（ユーザー指示がある場合のみ保持）

`workflow.md` の Step 8 が対象だった場合はステータス更新を「提案」のみ（自動更新しない）。

## エッジケース

| ケース | 処理 |
|---|---|
| 期間内に 0 件 | 「過去 N 日間に Circleback の会議なし」で終了 |
| モード A で会議名フィルタが 0 件 | 期間内に存在した会議名を提示し、キーワード変更 or 期間拡張を提案して終了（Step 6 参照） |
| モード A で会議名が多義的（想定外の会議が多数ヒット） | 全件チェック済み multiSelect で除外させる。より限定的なキーワードでの再指定も案内 |
| transcript が空配列 | ワーカーが `incomplete` で notes 要約のみの最小ファイルを生成、完了報告に警告 |
| `Meeting/` フォルダ不在 | `mkdir -p` で作成 |
| CLAUDE.md 等が全て不在 | AskUserQuestion でクライアント名を尋ねる |
| 200 件超 | 「件数が多いため期間を絞ることを推奨」と警告し、最初の 200 件で続行 |
| `GetTranscriptsForMeetings` レスポンスがファイル退避された | 退避ファイルを Python で直接読み込んで分割処理（メモリに展開しない） |
| 同一 ID の重複会議（複数ボットによる二重録音） | url / icalUid が一致するか確認し、duration の長い方または実名 attendees が記録されている方を採用、他はスキップ |
| API エラー / レート制限 | Step 7.5 取得時に指数バックオフ 2 回リトライ（2s, 5s）、3 回目で当該会議のみ failed 報告 |
