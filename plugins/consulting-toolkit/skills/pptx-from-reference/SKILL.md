---
name: pptx-from-reference
description: スキル配下の reference-decks/ に配備した参照 pptx 全件をデザイン見本として解析し、引数で指定された Markdown の内容を流し込んで PowerPoint を直接生成するスキル。参照デッキをテンプレートとして開くことでテーマ配色・フォント・スライドマスター・レイアウト・ロゴ／フッタを無傷で継承し、HTML 等の中間形式を経由せず python-pptx で pptx を組み上げる。`--masters-only` を指定すると既存スライドの中身は解析・模倣せず、スライドマスター・レイアウト・テーマだけを参照するモードになる。「参照 pptx と同じデザインでスライドを作って」「このテンプレートに合わせて pptx 化して」「既存資料のフォーマットで md から資料を作成して」「見本のパワポに寄せて作って」「md を pptx に直接変換して」「スライドマスターだけ流用して作って」などのリクエスト時に使用する。ブランドトークンをコードで定義して一から組む場合は 800-branded-pptx、HTML デッキを作る場合は html-artifact を使う。
---

# PPTX from Reference Deck

**参照 pptx（デザイン見本）＋ Markdown（コンテンツ）→ pptx** を、中間形式を挟まずに直接生成する。

## 中核の考え方

デザインを「読み取って真似る」のではなく、**参照 pptx をそのままテンプレートとして開き、
既存スライドだけを削除して中身を組み直す**。これによりテーマ配色・フォントスキーム・
スライドマスター・レイアウト・スライドサイズ・マスター上のロゴ／フッタ／ページ番号が
1 バイトも変わらずに引き継がれる。色やフォントを自前で定義し直さない。

## 入力

| 入力 | 指定方法 | 必須 |
|---|---|---|
| コンテンツ Markdown | **引数でパスを指定**（例: `/consulting-toolkit:pptx-from-reference docs/提案書.md`） | 必須 |
| 参照 pptx | `reference-decks/` に配備。**配下の pptx を全件参照する**（再帰・追加削除は自動反映） | 必須 |
| テンプレートに使う 1 本 | 引数 `--template <名前の一部>`。省略時はスキルが解析結果から選び、ユーザーに確認する | 任意 |
| 参照モード | 引数 `--masters-only`。省略時は全量参照モード（下表） | 任意 |
| 出力先 | 引数 `--out <path>`。省略時は md と同じディレクトリに `<md名>.pptx` | 任意 |

引数に md パスが含まれない場合は、**作業を始める前にパスを尋ねる**。推測で探しに行かない。

## 参照モード

| モード | 解析対象 | 使いどころ |
|---|---|---|
| **全量参照**（既定） | マスター・レイアウト・テーマに加え、**既存スライドの実測**（座標・配色・図形語彙・反復要素）まで学ぶ | 参照デッキの完成スライドに寄せたいとき |
| **マスターのみ参照**（`--masters-only`） | **スライドマスター・レイアウト・テーマのみ**。既存スライドの中身は一切解析・模倣しない | スライドが機密・内容が無関係・出来が悪い等で、マスターとテーマだけ継承したいとき |

マスターのみ参照でも、テンプレート継承（`open_template()`）の挙動は同じ
（既存スライドは削除され、マスター・テーマは無傷で引き継がれる）。
違いは **デザインの学習元を意図的にマスターへ限定する**ことにある。
ユーザーが「マスターだけ」「スライドの中身は見ないで」等と指定した場合はこのモードを使う。
どちらか迷う場合（例: 参照デッキの完成度が判断できない）はユーザーに確認する。

## 構成

| パス | 役割 |
|---|---|
| `reference-decks/` | **参照 pptx の配備先**。ここに置いた `.pptx` / `.potx` を全件解析する（[README](reference-decks/README.md)） |
| `scripts/analyze_references.py` | 参照デッキ全件を解析し `deck-spec.json`（全量）と `deck-spec.md`（要約）を出力 |
| `scripts/deck_kit.py` | python-pptx ラッパ。テンプレート継承・テキスト・箇条書き・図形・表・自動縮小 |
| `scripts/build_example.py` | `build.py` の雛形（そのままでも動く足場。案件ごとに書き換える） |
| `scripts/verify_deck.py` | 機械 QA（はみ出し・溢れ・空プレースホルダ・フォント／配色逸脱・重なり） |
| `scripts/render_pptx.sh` | PNG 化（soffice + pdftoppm）。ビジュアル QA 用 |
| `references/build-guide.md` | **deck_kit の API と実装規約**。build.py を書く前に必ず読む |

依存: `python-pptx`（`pip install python-pptx`）。PNG QA のみ LibreOffice と poppler を使う。

---

## 手順

### 1. 参照デッキを解析する

```bash
mkdir -p <work> && cd <work>
python3 <skill>/scripts/analyze_references.py --outdir .            # 全量参照（既定）
python3 <skill>/scripts/analyze_references.py --outdir . --masters-only  # マスターのみ参照
```

`reference-decks/` 配下の pptx を全件読み、`deck-spec.md` / `deck-spec.json` を出力する。
参照 pptx が 0 件なら終了コード 3 で止まる（その旨をユーザーに伝え、配備を依頼する）。

`deck-spec.md` から次を読み取る。**これが以降の全ての座標・配色の根拠になる**。

- キャンバスサイズ、テーマ配色（accent1… ）、テーマフォント（latin / ea）
- 実使用カラー・フォントサイズの頻度分布 ＝ そのデッキの実質的なパレット
- スライドレイアウト名とプレースホルダの実測座標
- **反復要素**（全スライドに繰り返し現れるヘッダ・フッタ・ページ番号・ロゴの位置）
- スライド別の実測ダンプ（図形の x/y/w/h、フォント、色、表の列幅）

`--masters-only` の場合、スライド由来の情報（頻度分布・反復要素・スライド別ダンプ）は出力されず、
代わりに **マスター既定書式（txStyles）・マスター実測ダンプ（ロゴ／フッタ等）・レイアウト別実測ダンプ**が出る。
本文レイアウトの座標根拠はレイアウトのプレースホルダ実測とマージン規約
（`references/build-guide.md` §3）、配色根拠はテーマ配色とマスター／レイアウト上の実使用色に限られる。

### 2. Markdown を読み、作成モードを確認する

引数のパスから md を読む。そのうえで、スライド作成に着手する前に次を確認する。

| モード | 内容 |
|---|---|
| **忠実再現モード** | md の内容を割愛・要約・文言変更せずそのままスライド化する。1 枚に収まらない場合のみ分割する |
| **柔軟作成モード** | md を素材として、スライドに適した構成・表現へ再編集する（取捨選択・要約・言い換えを行う） |

確認例: 「md の内容をそのまま忠実に反映しますか？ スライド向けに再編集してもよろしいですか？」

### 3. テンプレートを選び、スライドプランを立てる

- 解析した複数デッキのうち、用途（提案書／報告書／ディスカッション資料）が今回の md に
  最も近い 1 本をテンプレートに選ぶ。**根拠を 1 行添えてユーザーに確認する**。
- 他のデッキは、レイアウト・図版・配色の語彙を借りる材料として参照する。
- md の見出し構造からスライド構成（1 スライド 1 メッセージ）を起こす。構成の規範は
  [`_shared/deck-rhetoric.md`](../_shared/deck-rhetoric.md) と
  [`_shared/slide-body-principles.md`](../_shared/slide-body-principles.md) に従う。
- 複数枚にまたがるパートは**サマリ → 詳細**の順に置き、同階層のタイトル粒度を揃える。

### 4. build.py を書いて生成する

[`references/build-guide.md`](references/build-guide.md) を読んでから書く。

```bash
cp <skill>/scripts/build_example.py build.py
# build_slides() を案件用に書き換える
python3 build.py --md <md> --template <skill>/reference-decks/<選んだ>.pptx \
                 --spec deck-spec.json --out <出力>.pptx
```

`build_example.py` は md の見出しから機械的にスライドを起こす**足場**であり完成形ではない。
箇条書きの羅列で済ませず、内容の構造（比較・手順・階層・並列・推移）に応じたレイアウトを
毎回設計する。座標・配色は `deck-spec.md` の実測値と `st.theme_colors` から取る。

### 5. QA する

```bash
python3 <skill>/scripts/verify_deck.py <出力>.pptx --spec deck-spec.json
<skill>/scripts/render_pptx.sh <出力>.pptx ./render
```

1. **機械 QA**: `verify_deck.py` の ERROR を 0 にする（影の混入も ERROR で出る）。WARN も原則つぶす
   （INFO の配色逸脱は、意図的に参照外の色を使った場合のみ許容し理由を述べる）
2. **ビジュアル QA**: 生成 PNG を**全枚数読んで**、はみ出し・重なり・空欄・余白の偏りを見る
3. **コンテンツ QA**: 忠実再現モードなら md との項目対応を突き合わせ、脱落が無いことを確認する

PNG は LibreOffice の近似描画。フォント置換で字幅がずれるため、**字形の細部を根拠に微調整しない**
（`references/build-guide.md` §5）。最終確認は PowerPoint で行うようユーザーに伝える。

### 6. 納品

出力パスと、テンプレートに使った参照デッキ名、QA 結果（ERROR/WARN 件数）を報告する。
版管理が必要な成果物は [`_shared/versioning-conventions.md`](../_shared/versioning-conventions.md) に従う。
**md が正本、pptx は派生物**。修正は md 側に先に反映してから再生成する。

---

## 絶対ルール

| ルール | 詳細 |
|---|---|
| **参照は全件** | `reference-decks/` 配下の pptx を選り好みせず全件解析する。テンプレートに使うのは 1 本だが、パレットと語彙は全件から学ぶ |
| **テンプレート継承** | `open_template()` で参照 pptx を開く。マスター・レイアウト・テーマを作り直さない |
| **座標は実測値** | `deck-spec.md` の x/y/w/h を根拠に置く。目分量で配置しない（masters-only ではレイアウト・マスターの実測値が根拠） |
| **マージンの統一** | 左右マージン・本文開始 y をデッキ全体で 1 組の定数に揃える |
| **配色は参照デッキ内** | `st.theme_colors` / `st.used_colors` の外へ出ない。持ち込む場合は理由を述べる（masters-only ではテーマ配色＋マスター／レイアウト実使用色） |
| **日本語フォント** | `ea=` を必ず通す（`run.font.name` は `a:latin` しか書かないため日本語が化ける） |
| **空プレースホルダ** | 全スライドで `drop_empty_placeholders()` を呼ぶ |
| **影を付けない（禁じ手）** | `deck_kit` の図形 API は `no_shadow()` を自動適用する。生の `slide.shapes.add_shape()` を使う場合は必ず `no_shadow(sp)` を通す（`shadow.inherit = False` だけではテーマの `effectRef` が残り、LibreOffice 等で影が描かれる） |
| **md パスは引数** | 引数で受け取る。与えられなければ尋ねる |

## 禁止パターン

| 禁止 | 理由 |
|---|---|
| **ドロップシャドウ・影付き図形（禁じ手）** | Web 由来。矩形＋境界線か背景色で足りる。`deck_kit` が生成時に落とし（`no_shadow()`）、`verify_deck.py` が ERROR で検出する。`add_rect(shadow=True)` は例外 |
| グラデーション背景 | 参照デッキの様式から外れる |
| 英語ラベルの見出し（"FEATURES" 等） | 日本語の主張文に置き換える |
| スライド内の絵文字 | ビジネス資料では使わない |
| 参照デッキに無いアクセント色の持ち込み | デザイン見本に寄せる目的と矛盾する |
| スライド全体を画像で貼る | テキスト編集可能性が失われる。ネイティブ図形で組む |
| 箇条書きだけで全スライドを埋める | 構造の可視化を放棄している。比較・手順・階層は図表で示す |

## 関連スキルとの使い分け

| 状況 | 使うスキル |
|---|---|
| 見本 pptx のデザインに寄せて pptx を作る | **本スキル** |
| ブランドトークンをコードで定義して一から組む | `800-branded-pptx` |
| 16:9 の HTML スライドデッキを作る | `html-artifact`（Slide Deck format） |
| md より前に構成そのものを設計する | `slide-structure-designer` → 出力 md を本スキルの引数に渡す |
