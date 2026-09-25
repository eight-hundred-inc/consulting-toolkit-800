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

## 禁じ手の棲み分け（本スキルの担当範囲）

紙書き研修「15 の禁じ手」（正本：`${CLAUDE_PLUGIN_ROOT}/skills/_shared/kinjite-15.md`）は、
どのレイヤーで潰すかが項目ごとに決まっている。**本スキルは B と C を担当し、A には手を出さない。**

| 分類 | 禁じ手 | 本スキルでの扱い |
|---|---|---|
| **A. HTML 作成時に完結**（html-artifact / slide-pattern-creator） | ② 改行＆スペース多用 ／ ③ 箇条書きの点直打ち ／ ④ スペース・インデント ／ ⑤ モノ文字ボックス ／ ⑥ バラバラフォント ／ ⑦ 下線直書き ／ ⑧ 行間ピッタリ ／ ⑪ サイズバラバラ ／ ⑫ 縦横配置バラバラ ／ ⑬ 線でマトリックス ／ ⑭ アニメーション ／ ⑮ 3 軸グラフ | **本スキルでは直せない。**変換器は実測した矩形・文字をそのまま pptx にするため、HTML で崩れているものは pptx でも必ず崩れる。検査で引っかかったら **html-artifact 側を直して `--rebuild`**。pptx を手直しして辻褄を合わせない（次の再変換で消え、修正の容易性そのものを壊す） |
| **B. 変換時に決まる** | ① タイトル＆メッセージ直打ち（マスター継承） | **本スキルの担当。**タイトル／メッセージのプレースホルダを持つマスターのテンプレート pptx を渡す。テンプレートのテーマ・マスターは変換で継承される |
| **C. 組み合わせて対応** | ① マスター継承 ／ ③ 箇条書きの段落化 ／ ④ ぶら下げインデント ／ ⑨ 図形に文字ボックス ／ ⑩ 図形間の線が"ただ"の線 | HTML 側が「変換器がそう解釈できる形」で書き、**本スキルが変換後に実際そうなったかを確認**して初めて成立する。確認項目は手順 4 を参照 |

変換前の機械検査（`strict=true`）で拾えるのは A のうち機械検出できる分（②③④⑦⑨⑩⑬ の一部）だけで、
**⑤⑥⑧⑪⑫⑭⑮ は lint に出ない**。`pptx_safety_report.md` が error 0 でも禁じ手を踏んでいる
可能性があるため、結果を渡す前に手順 4 の確認を行う。

## 前提

| 前提 | 確認方法 | 無いとき |
|---|---|---|
| `slide-generator` MCP サーバーが登録済み | `mcp__slide-generator__*` ツールが見える（`/mcp` に `slide-generator` が出る） | [connect-slide-generator](../connect-slide-generator/SKILL.md) スキルを呼んで接続する（利用者はブラウザでログインするだけ。コマンド入力は不要）。登録後は Claude Code の開き直しが要るため、そこでいったん止める |
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
2. **禁じ手 C（組み合わせ）の確認**を行う。report.md と、必要なら
   `<スライド名>/output.pptx` を見て次を確かめる。**いずれも直し先は見本 HTML 側**で、
   直したら `--rebuild` を付けて再変換する（pptx を手で直さない）

   | # | 確認すること | 崩れていたときの直し先 |
   |---|---|---|
   | ① | 全スライドのタイトル行・メッセージ行が**同じ座標・同じサイズ**で出ているか | 1 枚だけずれていれば、その枚の HTML にスライド固有の位置上書きが混じっている（`pptx-safe.md` §10） |
   | ③ | 各リスト項目が**独立した段落**になっているか（1 項目が 2 段落に割れていないか） | 割れていれば `pptx-safe.md` §2（1 行を複数要素に分けない）違反 |
   | ⑨ | 塗り・枠のある図形と本文が**別オブジェクトに分解されていない**か | 分解されていれば、その要素がテキストノードを直接持っていない（`pptx-safe.md` §2） |
   | ⑩ | 図形間の線が**コネクタ**になっているか（図形を動かして追従するか） | ただの線に落ちていれば、オーバーレイ SVG にまとめている（`pptx-safe.md` §7）。矢印を 1 対 1 で独立させる |
   | ⑥ | **自動縮小で文字が小さくなった箱**が無いか（欄外はみ出し・折り返しの報告） | HTML 側の文字数を減らす。pptx でフォントサイズを戻すと禁じ手⑥そのものになる |

3. `combined_path`（全スライドを結合した pptx）を利用者に示す。`fetch_artifact` が
   `download_url` を返す構成ではそのリンクを渡す。スライドごとの
   `<スライド名>/output.pptx` も残るので、一部だけ差し替えたい場合に使えることを添える
4. **申し送り**：③ の箇条書きは pptx ではテキスト先頭の記号として出ることがある。
   ④ のぶら下げインデント（`text-indent`）も pptx に引き継がれない。以後 PowerPoint 上で
   編集を続けるなら、**段落の行頭文字設定・段落インデントに移しておくと修正が楽になる**旨を
   1 行添える（変換器の仕様であり、見本 HTML の誤りではない）

`FAILED` のとき:

| 状況 | 対応 |
|---|---|
| `error` が「サーバーが停止したため中断されました」 | 前のセッションが待たずに終わったジョブ。`retry_image_slide` で**残りのスライドから再開**する（済んだ枚はやり直さない） |
| **一部のスライドだけ失敗**（`progress.failed` が 1 以上） | 成功した分は `combined_path` に結合済み。失敗が一時的（LLM の応答不良など）なら `mcp__slide-generator__retry_image_slide(job_id)` で**失敗した枚だけ**やり直す。分割とテンプレート分析は再利用されるので速い |
| 変換セーフ検査の error（`strict=true` で中断） | 該当箇所を提示し、**html-artifact 側で直す**（[pptx-safe.md](../html-artifact/references/pptx-safe.md) の該当ルールを参照）。直したら `--rebuild` を付けて再実行（retry ではなく作り直し） |
| 上限時間の超過 | 枚数が多い。デッキを分割して渡す |
| `401` / `403` が返る（どのツールでも） | 接続用トークンの期限切れ（30 日）。[connect-slide-generator](../connect-slide-generator/SKILL.md) スキルで取り直す。見本 HTML やテンプレートの問題ではないので、利用者に直させない |
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
| タイトル行が 1 枚だけずれる | 見本 HTML にスライド固有の位置上書きがある（禁じ手①）。テンプレート pptx を替えても直らない |
| 図形を動かすと線が取り残される | 矢印がオーバーレイ SVG にまとまっていてコネクタにならなかった（禁じ手⑩）。矢印を 1 対 1 で独立させて `--rebuild` |
| 塗り図形の文字が縦にずれる | その要素がテキストを直接持たず、図形＋テキストボックスに分解された（禁じ手⑨） |
| 並んだカードの大きさ・位置が不揃い | 見本 HTML の時点で不揃い（禁じ手⑪⑫）。**塗りも枠も無いゾーンの不揃いも矩形として実測される**。変換側では直せない |
| lint は error 0 なのに見苦しい | ⑤⑥⑧⑪⑫⑭⑮ は機械検査に出ない。`_shared/kinjite-15.md` のチェックリスト A を html-artifact 側で通す |

## 関連スキル

| スキル | 関係 |
|---|---|
| [html-artifact](../html-artifact/SKILL.md) | 見本 HTML を作る上流。**PPTX 変換セーフモード**で生成しておくと手戻りが減る。**禁じ手 A（12 項目）はこちらの責任**で、本スキルでは直せない |
| [slide-pattern-creator](../slide-pattern-creator/SKILL.md) | レイアウトパターンの保守。禁じ手①③⑤⑪⑫⑬⑮ は**パターン定義の段階**で決まり、そのパターンを使う全スライドに伝播する |
| `_shared/kinjite-15.md` | 禁じ手 15 の正本（A / B / C の棲み分けと全項目のチェックリスト） |
| [pptx-from-reference](../pptx-from-reference/SKILL.md) | Markdown から中間形式を挟まず pptx を直接生成する別経路。デザインの学習元が「参照 pptx」なのに対し、本スキルは「見本 HTML」 |
| [800-branded-pptx](../800-branded-pptx/SKILL.md) | ブランドトークンから pptx を一から組む経路 |
| [deck](../deck/SKILL.md) | 構成 MD から HTML デッキ生成と本スキルの変換までを一気通貫で行う上位スキル |
