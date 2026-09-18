---
name: html-to-deck
description: html-artifact が生成した 16:9 スライドデッキ HTML（`section.slide` 形式）を見本として、テンプレート pptx の部品で組み直した編集可能な PPTX を生成するスキル。slide_generator の MCP サーバー（`slide-generator`）経由で、見本をブラウザ描画して実測した座標・配色・文字を土台に構成計画を作り、テンプレートのテーマ・マスターを継承したまま pptx を組み上げる。「HTML デッキを pptx にして」「このデッキを PowerPoint に変換して」「html-artifact の出力を pptx 化して」「見本 HTML からスライドを作って」「HTML スライドを編集できる形にして」などのリクエスト時に使用する。HTML を作るところから一括で頼まれた場合は html-artifact で生成してから本スキルへ続ける。Markdown から中間形式を挟まず直接 pptx にする場合は pptx-from-reference、ブランドトークンから組む場合は 800-branded-pptx を使う。
---

# HTML デッキ → PPTX 変換

**見本 HTML（16:9 スライドデッキ）＋ テンプレート pptx → 編集可能な pptx**。

## 中核の考え方

見本 HTML を「読んで真似る」のではなく、**ブラウザで描画して実 DOM の矩形・背景色・
枠線・フォントを実測し、その値を土台にテンプレート pptx の部品で組み直す**。
そのため実測に載らない表現（疑似要素で描いた装飾、`transform: scale` 配下の文字、
グラデーション背景など）は再現できない。見本側をそれに合わせて作るのが前提で、
規約は html-artifact の [PPTX 変換セーフ規約](../html-artifact/references/pptx-safe.md) にある。

変換の実体は別リポジトリ（slide_generator）の `run_image_slide` パイプラインで、
本スキルはその MCP サーバーを呼ぶ薄いラッパーである。

## 前提

| 前提 | 確認方法 | 無いとき |
|---|---|---|
| `slide-generator` MCP サーバーが登録済み | `/mcp` に `slide-generator` が出る | 利用者に README の「[slide-generator（見本 HTML → PPTX）](../../../../README.md#slide-generator見本-html--pptx-html-to-deck-利用時に必須)」の手順で登録してもらう |
| テンプレート pptx | 引数または利用者への確認 | パスを尋ねる。推測で探さない |
| 見本 HTML のディレクトリ | 引数、または直前に html-artifact が出力したファイル | パスを尋ねる |

## 入力

| 入力 | 指定方法 | 必須 |
|---|---|---|
| 見本 HTML のあるディレクトリ | 引数（例: `/consulting-toolkit:html-to-deck ~/work/deck`）。**ファイルではなくディレクトリ**を渡す | 必須 |
| テンプレート pptx | 引数 `--template <path>`。省略時は利用者に尋ねる | 必須 |
| 崩れる書き方の扱い | 引数 `--force`。省略時は検査で error があれば中断する | 任意 |
| 見本の作り直し | 引数 `--rebuild`。見本 HTML を直したのに結果が変わらないとき | 任意 |

PNG は用意しなくてよい。無ければ見本 HTML をブラウザで描画し、スライドごとに
分割した HTML と PNG が自動生成される。

## 手順

### 1. 入力を確定する

引数に見本ディレクトリとテンプレートが無ければ尋ねる。直前に html-artifact で
デッキを生成した場合は、その出力ファイルを含むディレクトリを使ってよいか確認する
（**HTML 単体ではなく、それが入ったディレクトリのパス**を使う）。

### 2. 変換を開始する

```
mcp__slide-generator__upload_asset(kind="template", path="<テンプレート pptx>")
mcp__slide-generator__upload_asset(kind="sample",   path="<見本ディレクトリ>")
mcp__slide-generator__start_image_slide(
    template_asset_id=..., sample_asset_id=...,
    strict=true,          # --force が指定された場合のみ false
    rebuild=<--rebuild が指定されたら true>
)
```

`strict=true` にすると、**PPTX 変換セーフ検査で error を検出した時点で中断する**。
数十分かけて変換してから崩れに気づく事故を防ぐため、これを既定にする。

`upload_asset` が「ローカルのパスを受け取れない」旨のエラーを返したら、サーバーが
手元のファイルを読めない構成（サーバーが別のマシンにある）。次の順に切り替える。

```
mcp__slide-generator__create_asset_upload(kind="template", file_name="<名前>.pptx")
# 返った upload_url へファイルの中身を PUT（見本はディレクトリを .zip に固めて渡す）
mcp__slide-generator__complete_asset_upload(asset_id=...)
```

### 3. 完了を待つ

`mcp__slide-generator__get_image_slide(job_id)` を **30〜60 秒おき**に呼ぶ。
`status` が `RUNNING` の間は待つ。スライド 1 枚あたり数分かかり、デッキの枚数に
比例するため、**全体では数分から数十分**になる。

待ち時間は `Bash` の `sleep 60` で作る。使えない場合は間を置かずに
`get_image_slide` を呼び直す（呼び出し自体に数秒かかる）。

**終了状態（`SUCCEEDED` / `FAILED`）を見る前に応答を終えない。**
「あとで確認します」と言って止まると、変換を動かしているサーバーごと終了して
ジョブが `RUNNING` のまま取り残される（次のセッションが `retry_image_slide` で
拾い直すことになる）。

応答の `progress`（total / succeeded / failed）と `slides`（スライドごとの状態）で
進み具合が分かるので、「7 枚中 3 枚完了」のように伝える（同じ文言を繰り返さない）。

### 4. 結果を渡す

`SUCCEEDED` のとき:

1. `fetch_artifact` で `report.md` を取得し、検証結果の要点（未再現の要素・座標の
   ずれ・欄外はみ出し）を 3〜5 行でまとめる
2. `combined_path`（全スライドを結合した pptx）を利用者に示す。`fetch_artifact` が
   `download_url` を返す構成ではそのリンクを渡す。スライドごとの
   `<スライド名>/output.pptx` も残るので、一部だけ差し替えたい場合に使えることを添える

`FAILED` のとき:

| 状況 | 対応 |
|---|---|
| `error` が「サーバーが停止したため中断されました」 | 前のセッションが待たずに終わったジョブ。`retry_image_slide` で**残りのスライドから再開**する（済んだ枚はやり直さない） |
| **一部のスライドだけ失敗**（`progress.failed` が 1 以上） | 成功した分は `combined_path` に結合済み。失敗が一時的（LLM の応答不良など）なら `mcp__slide-generator__retry_image_slide(job_id)` で**失敗した枚だけ**やり直す。分割とテンプレート分析は再利用されるので速い |
| 変換セーフ検査の error（`strict=true` で中断） | 該当箇所を提示し、**html-artifact 側で直す**（[pptx-safe.md](../html-artifact/references/pptx-safe.md) の該当ルールを参照）。直したら `--rebuild` を付けて再実行（retry ではなく作り直し） |
| 上限時間の超過 | 枚数が多い。デッキを分割して渡す |
| それ以外 | `log_tail` の末尾と `slides[].error` を読んで原因を 1〜2 文で説明する。環境不足（Chromium / LibreOffice 未導入）ならその旨を伝える |

**見本 HTML を直した場合は retry ではなく `--rebuild` を付けた再実行**。retry は
同じ見本のまま失敗した枚を流し直すだけなので、HTML の修正は反映されない。

**検査の error を黙って握り潰さない**。`--force` は利用者が明示したときだけ使う。

## 使うツール

| ツール | 用途 |
|---|---|
| `mcp__slide-generator__upload_asset` | テンプレート pptx（`kind="template"`）と見本ディレクトリ（`kind="sample"`）を登録し `asset_id` を得る |
| `mcp__slide-generator__start_image_slide` | 変換を開始し `job_id` を得る（完了は待たない） |
| `mcp__slide-generator__get_image_slide` | 状態・成果物一覧・ログ末尾を取得する |
| `mcp__slide-generator__retry_image_slide` | 失敗したスライドだけ再実行する |
| `mcp__slide-generator__fetch_artifact` | `report.md` の内容や `output.pptx` の在り処（パス、または `download_url`）を取得する |
| `mcp__slide-generator__create_asset_upload` / `complete_asset_upload` | サーバーが手元のファイルを読めない構成でのアップロード（上記） |

登録したアセットは作業ディレクトリへ複製されるため、**利用者の元ファイルは書き換わらない**。

## よくある詰まり

| 症状 | 原因 |
|---|---|
| 見本 HTML を直したのに結果が変わらない | 分割済みの見本が再利用されている。`--rebuild` を付ける |
| 図やアイコンが消える / 背景が単色になる | 疑似要素・グラデーション・`clip-path` など実測に載らない表現。pptx-safe.md の該当ルールで書き換える |
| 文字が溢れる | 折り返しの余白不足、または `transform: scale` 配下のテキスト |
| 画像が欠ける | 外部参照（CDN・相対パスのローカル画像）。自己完結 HTML（data URI）にする |

## 関連スキル

| スキル | 関係 |
|---|---|
| [html-artifact](../html-artifact/SKILL.md) | 見本 HTML を作る上流。**PPTX 変換セーフモード**で生成しておくと手戻りが減る |
| [pptx-from-reference](../pptx-from-reference/SKILL.md) | Markdown から中間形式を挟まず pptx を直接生成する別経路。デザインの学習元が「参照 pptx」なのに対し、本スキルは「見本 HTML」 |
| [800-branded-pptx](../800-branded-pptx/SKILL.md) | ブランドトークンから pptx を一から組む経路 |
| [deck](../deck/SKILL.md) | 構成 MD から HTML デッキ生成と本スキルの変換までを一気通貫で行う上位スキル |
