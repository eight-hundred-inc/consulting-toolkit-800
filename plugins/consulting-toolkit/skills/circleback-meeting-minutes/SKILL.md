---
name: circleback-meeting-minutes
description: Circleback MCP が接続されている環境で使用する。「Circlebackから議事録を作って」「過去1週間の会議の議事録を作成して」「Circlebackの会議をMDにして」「先週のミーティング議事録をまとめて」「先週の会議を整理して」などのリクエスト時に使用。
---

# Circleback 議事録一括作成スキル

Circleback MCP から過去1週間（デフォルト）の会議を取得し、プロジェクト関連のものを抽出して議事録 MD を生成する。`meeting-minutes-creator` / `interview-minutes-creator` を再利用し、複数件はサブエージェントで並列処理する。

## Circleback MCP フィールド名（実証済み）

| 概念 | フィールド名 |
|---|---|
| 会議 ID | `id`（数値）、`linkId`（文字列） |
| 会議名 | `name` |
| 作成日時 | `createdAt`（ISO 8601 UTC） |
| 参加者 | `attendees[].name`、`attendees[].email`（ボットは null） |
| 要約 | `notes`（Markdown テキスト） |
| タグ | `tags`（配列、空の場合あり） |
| トランスクリプトセグメント | `{speaker, text, timestamp}`（秒） |

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

### Step 8: 並列実行

**ファイル名（必須遵守）**: `YYYY-MM-DD_<会議名>_議事録.md`

- **日付は必ず先頭** に置く。`meeting-minutes_<日付>_xxx.md` のように日付を後ろに置く形式は禁止
- 日付は `createdAt` から抽出（JST 換算）
- `<会議名>` は Circleback の `name` を使用（英語スラグへの変換はしない）
- 禁則文字（`/\:*?"<>|` と空白）は `_` に置換
- 同名衝突時は `_v2`, `_v3` を付与

`circleback-minutes-worker` サブエージェントを **最大 5 並列** でディスパッチ。6 件超は 5 件ずつ波で処理。

各ワーカーへのプロンプトに含める情報:
- `meetingId`: 数値 `id`（または `linkId` 文字列）
- `meetingType`: `meeting` または `interview`
- `outputPath`: 保存先の絶対パス（ファイル名含む）
- `projectContext`: interview の場合のみ、プロジェクトサマリ抜粋テキスト
- `readMeetingsTool`: 動的解決済みフル名
- `getTranscriptsTool`: 動的解決済みフル名

### Step 9: 完了報告

- 生成ファイルの絶対パスと 1 行サマリ（誰と何を話したか、60 字以内）
- 失敗した会議と理由（トランスクリプト空・API エラー等）
- 未処理の不確実件数

`workflow.md` の Step 8 が対象だった場合はステータス更新を「提案」のみ（自動更新しない）。

## エッジケース

| ケース | 処理 |
|---|---|
| 期間内に 0 件 | 「過去 N 日間に Circleback の会議なし」で終了 |
| transcript が空配列 | ワーカーが `incomplete` で最小ファイルを生成、完了報告に警告 |
| `Meeting/` フォルダ不在 | `mkdir -p` で作成 |
| CLAUDE.md 等が全て不在 | AskUserQuestion でクライアント名を尋ねる |
| 200 件超 | 「件数が多いため期間を絞ることを推奨」と警告し、最初の 200 件で続行 |
| API エラー / レート制限 | ワーカーで指数バックオフ 2 回リトライ（2s, 5s）、3 回目で failed 報告 |
