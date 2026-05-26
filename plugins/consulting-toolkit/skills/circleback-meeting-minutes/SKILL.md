---
name: circleback-meeting-minutes
description: Circleback MCP が接続されている環境で使用する。「Circlebackから議事録を作って」「過去1週間の会議の議事録を作成して」「Circlebackの会議をMDにして」「先週のミーティング議事録をまとめて」「先週の会議を整理して」などのリクエスト時に使用。
---

# Circleback 議事録一括作成スキル

Circleback MCP から過去1週間（デフォルト）の会議を取得し、プロジェクト関連のものを抽出して議事録 MD を生成する。`meeting-minutes-creator` / `interview-minutes-creator` を再利用し、複数件はサブエージェントで並列処理する。

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

### Step 1: 期間決定

デフォルト: 今日から 7 日前（`startDate`・`endDate` を `YYYY-MM-DD` 形式で計算）。
ユーザー指示に「過去 X 日」「MM/DD〜MM/DD」等があれば優先。期間を会話中に提示して次へ進む（AskUserQuestion 不要）。

### Step 2: Circleback MCP ツール名の動的解決

ToolSearch で以下のキーワードを検索し、返却されたフル名を記録する。UUID プレフィックスは環境ごとに異なるため、毎回動的に取得すること。

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

### Step 4: SearchMeetings ページング取得

```
SearchMeetings(intent="プロジェクト関連会議を期間で取得", startDate=..., endDate=..., pageIndex=0)
```

返却件数が 20 件ちょうどなら `pageIndex+1` で繰り返す（20 件未満になった時点で終了と判断）。最大 10 ページ（200 件）で打ち切り＋警告。

**ボット除外**: `attendees[].name` に「Circleback」「AI Notetaker」「tldv」「Notetaker」等を含み `email` が null の参加者はスコアリング対象外。

### Step 5: 関連度スコアリング

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

### Step 6: グルーピング選択 UX

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

対象会議の ID（または linkId）を最大 50 件まで `ReadMeetings` と `GetTranscriptsForMeetings` にまとめて渡す。

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

#### 7.5.3 Python で会議ごとに分割保存

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

# meetingId（linkId or 数値 id）→ slug マッピング
slug_map = {}
for m in meetings:
    date_jst = m["createdAt"][:10].replace("-", "")  # YYYYMMDD
    slug = safe_slug(m["name"], date_jst)
    mid = m.get("linkId") or m["id"]
    slug_map[mid] = slug
    with open(f"{WORK}/meeting_{slug}.json", "w") as g:
        json.dump(m, g, ensure_ascii=False, indent=2)

# トランスクリプトを linkId / id で対応付けて分割保存
for t in transcripts:
    mid = t.get("meetingId") or t.get("linkId") or t.get("id")
    slug = slug_map.get(mid) or safe_slug(t.get("meetingName", str(mid)), "unknown")
    with open(f"{WORK}/transcript_{slug}.json", "w") as g:
        json.dump(t, g, ensure_ascii=False, indent=2)
```

#### 7.5.4 ワーカーに渡すパス確定

各会議について以下を控えておく:
- `meetingDetailsPath`: `<WORK>/meeting_<slug>.json`
- `transcriptPath`: `<WORK>/transcript_<slug>.json`

### Step 8: 並列実行

**ファイル名（必須遵守）**: `YYYY-MM-DD_<会議名>_議事録.md`

- **日付は必ず先頭** に置く。`meeting-minutes_<日付>_xxx.md` のように日付を後ろに置く形式は禁止
- 日付は `createdAt` から抽出（JST 換算）
- `<会議名>` は Circleback の `name` を使用（英語スラグへの変換はしない）
- 禁則文字（`/\:*?"<>|` と空白）は `_` に置換
- 同名衝突時は `_v2`, `_v3` を付与

`circleback-minutes-worker` サブエージェントを **最大 5 並列** でディスパッチ。6 件超は 5 件ずつ波で処理。

**各ワーカーへのプロンプトに含める情報（新仕様）**:
- `meetingType`: `meeting` または `interview`
- `outputPath`: 保存先の絶対パス（ファイル名含む）
- `transcriptPath`: Step 7.5.3 で分割保存したトランスクリプト JSON の絶対パス
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
| transcript が空配列 | ワーカーが `incomplete` で notes 要約のみの最小ファイルを生成、完了報告に警告 |
| `Meeting/` フォルダ不在 | `mkdir -p` で作成 |
| CLAUDE.md 等が全て不在 | AskUserQuestion でクライアント名を尋ねる |
| 200 件超 | 「件数が多いため期間を絞ることを推奨」と警告し、最初の 200 件で続行 |
| `GetTranscriptsForMeetings` レスポンスがファイル退避された | 退避ファイルを Python で直接読み込んで分割処理（メモリに展開しない） |
| 同一 ID の重複会議（複数ボットによる二重録音） | url / icalUid が一致するか確認し、duration の長い方または実名 attendees が記録されている方を採用、他はスキップ |
| API エラー / レート制限 | Step 7.5 取得時に指数バックオフ 2 回リトライ（2s, 5s）、3 回目で当該会議のみ failed 報告 |
