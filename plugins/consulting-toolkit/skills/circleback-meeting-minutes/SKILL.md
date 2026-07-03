---
name: circleback-meeting-minutes
description: Circleback MCP が接続されている環境で使用する。「Circlebackから議事録を作って」「過去1週間の会議の議事録を作成して」「Circlebackの会議をMDにして」「先週のミーティング議事録をまとめて」「先週の会議を整理して」「○○MTGの議事録だけ作って」「会議名を指定して議事録化」「5/20〜5/26の△△の会議だけまとめて」などのリクエスト時に使用。
---

# Circleback 議事録一括作成スキル

Circleback MCP から会議を取得して議事録 MD を生成する。取得対象は **(A) ユーザーが指定した絞り込み条件（会議名・期間）に該当する会議**、指定がなければ **(B) 過去1週間（デフォルト）の会議からプロジェクト関連のものをスコアリング抽出** する。単一会議は親が直接生成（ファストパス）、複数件は `circleback-minutes-worker` サブエージェントで並列処理する。

## 設計原則: 親が取得→単一はファストパス・複数はワーカー並列

サブエージェントのツール権限はホスト環境によって変動し、MCP ツール（`mcp__claude_ai_Circleback__*`）がワーカーに露出しないケースがある。そのため、本スキルでは:

- **親（本スキル）**が Circleback MCP を直接呼んでトランスクリプト・会議詳細を取得し、`/tmp` に raw JSON で保存する
- **単一会議（ファストパス）**: 親が直接議事録 MD を生成する（ワーカー起動コストを省略）
- **複数会議**: `circleback-minutes-worker` が Read / Write / Bash の最小権限で動作し、保存済み JSON から議事録 MD を生成する

これにより MCP ツール名の環境差異を吸収しつつ、単一会議の処理を高速化する。

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

ToolSearch の `select:` 構文で 3 ツールを **1 回の呼び出し** で解決する。UUID プレフィックスは環境ごとに異なるため、毎回動的に取得すること。

```
ToolSearch(query="select:SearchMeetings,ReadMeetings,GetTranscriptsForMeetings", max_results=3)
```

1 件もマッチしなければ「Circleback MCP が未接続です。`/mcp` で接続後に再実行してください」と案内して終了。

**親側で解決したツール名は親自身が使用する。ワーカーには渡さない**（ワーカーは MCP を呼ばない設計のため）。

> **往復削減**: Step 2 の ToolSearch、Step 3 のソース Read（`プロジェクトサマリ.md`）、Step 7 のファイル存在確認（`workflow.md`・`Output/インタビューガイド.md`）は相互に独立で MCP 結果に依存しない。**冒頭で 1 メッセージにまとめて並列発行**し、最大 4 往復を 1 往復に短縮する（`CLAUDE.md` はシステムプロンプトに既出のため再読込不要。`SearchMeetings` は解決済みツール名に依存するため次メッセージに残す）。

### Step 3: プロジェクトキーワード抽出

以下を優先順に Read し、最初に存在するソースから `clientName`・`projectName`・スコープ固有名詞 3〜5 語を抽出する:

1. `プロジェクトサマリ.md`
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

7.5.1（一括取得）は常に実行する。**7.5.2〜7.5.4 の `/tmp` ファイル化は複数会議（2 件以上＝8-B 行き）のときのみ**実行する。ワーカーは MCP を呼ばないため、親が一括取得したデータを会議ごとに分割してファイルで渡す必要があるためである。

**単一会議（1 件＝8-A 行き）は 7.5.2〜7.5.4 をスキップ**し、7.5.1 の取得結果をコンテキスト内データとして直接 8-A で使う（`GetTranscriptsForMeetings` が大容量レスポンスを自動ファイル退避した場合のみ、その退避パスを 8-A で Read する）。これにより単一会議では `mkdir` / 分割保存 / クリーンアップの Bash 往復をすべて省く。

#### 7.5.1 一括取得

**ReadMeetings 省略判定（モード A・1 件のみ）**: SearchMeetings の返却に `notes`（非空文字列）と `attendees`（非空配列）が含まれている場合、ReadMeetings をスキップし **GetTranscriptsForMeetings のみ** を呼ぶ。SearchMeetings の返却データをそのまま会議詳細として使用する（`actionItems` 等の追加フィールドは欠けるが、トランスクリプトから議事録を生成する上で支障はない）。

**上記以外（モード B、モード A 2 件以上、notes/attendees 欠落時）**: 対象会議の ID（または linkId）を最大 50 件まで `ReadMeetings` と `GetTranscriptsForMeetings` にまとめて渡す。**この2つは1メッセージ内の2回のツール呼び出しとして同時発行**し、逐次実行を避けて1往復分短縮する。

```
ReadMeetings(intent="議事録生成のため会議詳細を一括取得", meetingIds=[<id1>, <id2>, ...])
GetTranscriptsForMeetings(intent="議事録生成のためトランスクリプトを一括取得", meetingIds=[<id1>, <id2>, ...])
```

**大容量レスポンス**: `GetTranscriptsForMeetings` のレスポンスは MCP 側で自動的にファイル化される場合がある（context overflow 回避）。その場合は返却された一時ファイルパスをそのまま分割処理の入力とする。

#### 7.5.2 作業ディレクトリ作成（複数会議時のみ）

```bash
WORK="/tmp/circleback-minutes-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$WORK"
```

#### 7.5.3 会議ごとに分割保存（複数会議時のみ・Python 整形なし）

会議詳細・トランスクリプトともに **raw JSON のまま** `/tmp` に分割保存する。トランスクリプトの話者連結・タイムスタンプ除去等の整形は LLM が議事録生成時に直接行うため、Python による前処理（`flatten_transcript` 等）は不要。

**保存方法**: 会議詳細は `ReadMeetings`（または ReadMeetings スキップ時は `SearchMeetings`）のレスポンスを JSON 保存。トランスクリプトは `GetTranscriptsForMeetings` のレスポンスを JSON 保存。

複数会議の場合は Bash の `python3 -c` で meetingId をキーに JSON を分割する。1 件の場合はツール結果をそのまま Bash でファイル保存すればよい。

```bash
# ファイル命名規則
meeting_<linkId>.json        # 会議詳細
transcript_<linkId>.json     # トランスクリプト（raw JSON）
```

#### 7.5.4 ワーカーに渡すパス確定（複数会議時のみ）

各会議について以下を控えておく:
- `meetingDetailsPath`: `<WORK>/meeting_<linkId>.json`
- `transcriptPath`: `<WORK>/transcript_<linkId>.json`（raw JSON。ワーカーが直接読んで議事録を生成する）

### Step 8: 議事録生成（ファストパス / 並列実行）

**ファイル名（必須遵守）**: `YYYY-MM-DD_<会議名>_議事録.md`

- **日付は必ず先頭** に置く。`meeting-minutes_<日付>_xxx.md` のように日付を後ろに置く形式は禁止
- 日付は `createdAt` から抽出（JST 換算）
- `<会議名>` は Circleback の `name` を使用（英語スラグへの変換はしない）
- 禁則文字（`/\:*?"<>|` と空白）は `_` に置換
- 同名衝突時は `_v2`, `_v3` を付与

#### 8-A: 単一会議ファストパス（対象が 1 件の場合）

対象会議が **1 件のみ** の場合、ワーカーサブエージェントを起動せず **親が直接** 議事録 MD を生成する。これによりサブエージェント起動コスト（数分）を省き、単一会議の処理を大幅に高速化する。

1. `GetTranscriptsForMeetings` の結果がコンテキスト内にあればそのまま使う。大容量レスポンスでファイル退避された場合は Read で読み込む
2. 会議詳細（`ReadMeetings` の結果、または ReadMeetings スキップ時は `SearchMeetings` の結果）も同様にコンテキスト内のデータを直接使用する
3. **`Skill` ツールで `meeting-minutes-creator`（meeting の場合）または `interview-minutes-creator`（interview の場合）を呼び出し、スキルの出力フォーマットを正確に取得してから議事録を生成する**。スキルのフォーマットを記憶や推測で再現してはならない
4. トランスクリプト JSON のセグメント（`{speaker, text, timestamp}` or `{speaker, words, startTimestamp, endTimestamp}`）を読み解き、音声認識誤りを文脈から補正しながら間接話法で再構成する
5. `projectContext`（interview の場合）・`documentGuidelines`（CLAUDE.md の文書作成ガイドライン）は親コンテキストに既にあるため、ファイル経由の受け渡しは不要

#### 8-B: 並列実行（対象が 2 件以上の場合）

`circleback-minutes-worker` サブエージェントは **1 メッセージ内に複数の Agent 呼び出しをまとめてディスパッチ**し、同時実行させる（逐次起動は禁止）。**並列上限は 8**（実効同時実行数はハーネス依存。環境が許す範囲で 8 まで）。9 件超は 8 件ずつの波で処理し、波内のワーカーは必ず 1 メッセージでまとめて起動する。

> Opus のまま並列数を上げるとレート制限・リソース競合が起きうる。失敗が頻発する場合は波サイズを 5 などに縮小する。

**各ワーカーへのプロンプトに含める情報**:
- `meetingType`: `meeting` または `interview`
- `outputPath`: 保存先の絶対パス（ファイル名含む）
- `transcriptPath`: Step 7.5.3 で保存した**トランスクリプト raw JSON** の絶対パス（ワーカーが JSON を直接読んで議事録を生成する）
- `meetingDetailsPath`: Step 7.5.3 で分割保存した会議詳細 JSON の絶対パス
- `projectContext`: interview の場合のみ、プロジェクトサマリ抜粋テキスト
- `documentGuidelines`: クライアント文書ガイドラインの要旨（CLAUDE.md から抜粋、任意）

**渡してはいけない情報**:
- `readMeetingsTool` / `getTranscriptsTool`（ワーカーは MCP を呼ばない）
- トランスクリプト本文や会議 notes の生テキスト（ファイルパス経由で渡す）
- **議事録のフォーマット仕様をインラインで記載してはならない**。ワーカーは `skills: meeting-minutes-creator / interview-minutes-creator` が注入済みであり、フォーマットはワーカー側のスキル定義に委ねる。親がフォーマットをインライン指定すると、スキルの正規フォーマットと乖離する原因になる

### Step 9: 完了報告とクリーンアップ

- 生成ファイルの絶対パスと 1 行サマリ（誰と何を話したか、60 字以内）
- 失敗した会議と理由（トランスクリプト空・API エラー等）
- 未処理の不確実件数
- **クリーンアップ**: 複数会議で `/tmp` に保存した場合のみ、全ワーカー完了後に `/tmp/circleback-minutes-*` を削除（ユーザー指示がある場合は保持）。単一会議ファストパスで `/tmp` を作成していない場合はクリーンアップ不要

`workflow.md` の Step 8 が対象だった場合はステータス更新を「提案」のみ（自動更新しない）。

## エッジケース

| ケース | 処理 |
|---|---|
| 期間内に 0 件 | 「過去 N 日間に Circleback の会議なし」で終了 |
| モード A で会議名フィルタが 0 件 | 期間内に存在した会議名を提示し、キーワード変更 or 期間拡張を提案して終了（Step 6 参照） |
| モード A で会議名が多義的（想定外の会議が多数ヒット） | 全件チェック済み multiSelect で除外させる。より限定的なキーワードでの再指定も案内 |
| transcript が空配列 | `incomplete` として notes 要約のみの最小議事録を生成（ファストパス: 親が直接、並列: ワーカーが生成）、完了報告に警告 |
| `Meeting/` フォルダ不在 | `mkdir -p` で作成 |
| CLAUDE.md 等が全て不在 | AskUserQuestion でクライアント名を尋ねる |
| 200 件超 | 「件数が多いため期間を絞ることを推奨」と警告し、最初の 200 件で続行 |
| `GetTranscriptsForMeetings` レスポンスがファイル退避された | 退避ファイルパスをそのまま `transcriptPath` として使用する（ファストパスでは Read で読み込む） |
| 同一 ID の重複会議（複数ボットによる二重録音） | url / icalUid が一致するか確認し、duration の長い方または実名 attendees が記録されている方を採用、他はスキップ |
| API エラー / レート制限 | Step 7.5 取得時に指数バックオフ 2 回リトライ（2s, 5s）、3 回目で当該会議のみ failed 報告 |
