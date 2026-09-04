# PPTX 変換セーフ規約（Slide Deck format）

生成した Slide Deck HTML を **見本としてネイティブ pptx へ変換する**（slide_generator の `make run_image_slide`、またはブランド pptx スキルの html-artifact 参照モード）ときだけ適用する追加規約。ブラウザ投影で完結する通常のデッキには適用しない（表現の幅が狭くなるため）。

## なぜ制約が要るのか（変換器の仕組み）

変換パイプラインは HTML を「読む」のではなく、**ヘッドレス Chromium で描画してから実 DOM 要素を実測する**。拾われるのは次に該当する要素だけで、拾えた矩形・色・フォントだけが構成計画（pptx の図形配置）に渡る。

| 実測される | 実測されない（＝pptx に出ない・推測になる） |
|---|---|
| 直接テキストノードを持つ要素の `textContent` | `::before` / `::after` の内容と装飾 |
| `background-color`（単色） | `background-image`（グラデーション・画像） |
| 4 辺の `border` 色・太さ・`border-radius`（左上 1 値のみ。4 隅同一が前提。§8） | `box-shadow`、`clip-path`、`filter`、`mix-blend-mode` |
| `getBoundingClientRect()` の矩形 | `transform: scale` 適用前の `font-size`（矩形は縮小後、文字は縮小前で読まれる） |
| `color` / `font-size` / `font-weight` / `text-align` | 縦書き（`writing-mode`）、45 度以外の回転 |
| インライン `<svg>` のマークアップと実寸 | CSS だけで描いた線・三角形・矢印 |

さらに pptx 側の構造上の制約が 2 つある。

1. **1 つの図形の中では、テキストは段落として縦に積まれる**。HTML の「同じ行に横並び」は表現できず、別要素に分かれた行は上下に分解される。
2. **PowerPoint のテーマフォントは Web フォントより字幅が広い**。同じ文字数でも 1〜2 割広くなり、余白の無い枠は折り返して下の要素と重なる。

規約はすべてこの 2 表から導かれている。**迷ったら「ブラウザを閉じても、要素の矩形・単色・文字だけで同じ意味が伝わるか」**で判断する。

## 検査

```bash
cd <slide_generator>/app/core
make run_html_pptx_lint SAMPLE_DIR=<見本HTMLのあるディレクトリ>
# run_image_slide 実行時は同じ検査が自動で先に走る（LINT=0 で省略、STRICT=1 で error 時に中断）
```

`pptx_safety_report.md` に、ルール別・スライド別の該当箇所が出る。**error は必ず潰す。warning は理由があれば残してよい**（判断はレポートの該当箇所を見て行う）。ルール名は以下の各節に対応している。

> **HTML を直したのに pptx が変わらないとき**：変換器はデッキ HTML をスライドごとに `<見本ディレクトリ>/slides/` へ分割したものを再利用する。HTML の更新時刻が新しければ自動で作り直されるが、確実に反映させたいときは `make run_image_slide ... REBUILD=1` を付ける。

---

## 1. 疑似要素で意味のあるものを描かない（`pseudo_shape` / `pseudo_text`）

`::before` / `::after` は実 DOM 要素ではないため、**位置・大きさ・色がまったく実測に載らない**。変換器は画像から目算するしかなく、箇条書きの点が本文の上にずれる・見出し罫が消える・矢印が別の場所に出る、といった崩れの最大の原因になる。

**NG**

```html
<!-- CSS: .body-list li::before{content:"";position:absolute;left:0;top:9px;
     width:5px;height:5px;border-radius:50%;background:var(--ink-mute)} -->
<li>作業指示を、文字から画像・アイコン中心のビジュアルな情報に変換</li>
```

**OK**（マーカーを行のテキストノードに入れる。字下げは `text-indent` の負値＋**同量の `padding-left`** で吸収する）

```html
<!-- CSS: .body-list li{padding-left:1em;text-indent:-1em} -->
<li>● 作業指示を、文字から画像・アイコン中心のビジュアルな情報に変換</li>
```

**字下げは `margin-left` で作らない。** `margin-left` は要素の箱ごと右へずらすため、その行に付けた `border-bottom`（アンダーライン）・背景・枠が、マーカーではなく折り返し行の位置から始まる（実測でも「文字は正しいのに罫線だけ右にずれる」形になる）。`padding-left` なら箱の左端が親の内側左端に残り、罫線・背景がマーカーと揃う。

**行ごとのアンダーライン（`border-bottom`）は付けない。** pptx では行が個別図形になり、行ごとに独立した線シェイプが追加される。テーマフォントの折り返し差で線の長さ・位置が行ごとにばらつくため、項目の区切りは**行間**で表現する（`.summary ul li` / `.qa-card ol li` / `.fact-list li` 等、テンプレート既定で点線を持つ部品は変換セーフモードでは `border-bottom:none` にする）。なお `text-indent` は pptx に引き継がれないため、**吊り下げインデントに依存した見た目にしない**（折り返し行が左端に戻っても崩れない字面にする）。

- 使ってよい記号：`● ○ ■ □ ◆ ＋ × ✓ －`（絵文字は SKILL.md どおり禁止）
- 見出しの下罫・カードの区切り線は、疑似要素ではなく**その要素自身の `border-top` / `border-bottom`** で引く（辺の罫線は実測される）
- 装飾のためだけの `::before`（`content:""` で何も塗らない・サイズ 0）は検出対象外なので残してよい

## 2. 1 行を複数要素に分けない（`split_inline_row` / `chip_prefixed_row`）

pptx では 1 図形内のテキストは段落として縦に積まれる。**行頭の記号・番号・ラベルを本文と別要素にすると、pptx では上下 2 段に分解され**、枠の高さを超えて片方が消える（章番号 01〜10 が全部消える・✓ が本文の上に乗る、という実際の崩れはすべてこれ）。

**NG**

```html
<div class="lr-eff"><span class="lr-check">✓</span><span>教育・指示に費やす時間の削減（目標：<b>30%削減</b>）</span></div>
<li><span class="toc-num">01</span><span class="toc-name">背景・目的</span></li>
```

**OK**（親要素が行のテキストを**直接**持つ。書式差を付けたい部分だけを `<span>` / `<b>` にする）

```html
<div class="lr-eff"><span class="lr-check">✓</span>教育・指示に費やす時間の削減（目標：<b>30%削減</b>）</div>
<li><span class="toc-num">01</span>背景・目的</li>
```

判定の基準はシンプルで、**行を包む要素が自分のテキストノードを持っているか**。持っていれば変換器はその行を 1 つの文字列として拾い、`<b>` / `<strong>` は pptx の部分太字（run）として復元される。持っていなければ子要素ごとにバラバラの段落になる。

- **左右に並ぶカード同士は分けてよい**（それぞれが塗り・枠を持つ独立した図形になるため正しく並ぶ）。禁じているのは「1 行の中身」を分けることだけ
- 塗り付きの丸番号チップ・バッジをどうしても行頭に置く場合は `chip_prefixed_row`（warning）になる。pptx では図形＋テキストの 2 図形になり縦位置が合わせにくいので、**塗りが必須でなければ色付き `<span>` に落とす**

## 3. `transform: scale` を掛けた領域にテキストを置かない（`scaled_container`）

`.fig-canvas` のように `transform: scale(0.72)` で図版を縮める書き方は、**矩形は縮小後・フォントサイズは縮小前**で読まれるため、pptx の文字だけが約 1.4 倍になって枠から溢れる。

- **作り込み図版は 1152px 幅のネイティブサイズで組む**（`diagram-components.md` の flow 図版の方式）。`transform: scale` を使う絶対配置図版は、pptx 変換前提のデッキでは採らない
- どうしても縮小が必要なら、`scale` ではなく**中の `font-size` / 間隔を直接小さい値で書く**

## 4. 塗りは単色・境界は border（`background_image`）

- `background: linear-gradient(...)` / `background-image` は実測に載らず、pptx では無地になる。**`background-color` の単色**にする（`color-mix()` の計算値は単色として実測されるので使ってよい）
- `box-shadow` は再現されない。影で浮かせているカードは、**`border: 1px solid var(--rule)` を必ず併せて持たせる**（影が消えても境界が残る）
- `clip-path` / `filter` / `mix-blend-mode` / `backdrop-filter` は使わない（`unsupported_paint`）

## 5. 折り返しの余白を 1〜2 割残す（`text_no_headroom` / `nowrap_text`）

PowerPoint のテーマフォントは Web フォントより字幅が広い。**1 行のテキストが枠内幅の 93% を超えている箇所は、pptx でほぼ確実に折り返して下の要素と重なる**。

- 見出し・ラベル・ピル・番号チップなど**折り返させたくない 1 行**は、枠内幅に対して 8 割程度に収まる文字数にする
- `white-space: nowrap` は pptx に引き継がれない（`nowrap_text` は info）。nowrap に頼って詰めている箇所ほど危険なので、実幅に余裕を持たせる
- カード内の本文は、行数が 1 行増えてもカード下端を突き破らない高さにする（`padding-bottom` を厚めに取る）

## 6. フォントは 11px 以上（`tiny_font`）

10px は 7.5pt になり、pptx では判読しづらいうえ自動縮小の影響も受けやすい。**11px（8.25pt）を下限**とし、注記・凡例も 11px までに留める。入り切らないなら情報量をスライド分割で減らす。

## 7. 図版の線・矢印は「結ぶ 2 要素の間に 1 本ずつ」（`svg_overlay` / `svg_thin`）

インライン `<svg>` はマークアップごと実測されるため、CSS の三角形ハックより遥かに安全。ただし置き方で結果が変わる。

- **OK**：矢印 1 本＝独立した 1 つの `<svg>`（または `<div>` の border）を、結ぶ 2 つのノードの間に置く。変換器はこれを pptx のコネクタ（両端が図形にグルーされた線）に変換でき、後編集にも耐える
- **NG**：図版全体を覆う 1 枚の `<svg class="fig-edges">` に全部の線を描く。変換器は「1 枚の画像として貼る」か「線に分解する」かで揺れ、修正ループが収束しない
- アイコン `<svg>` は縦横比 2.5 未満に収める（それ以上細長いと線とみなされて分解される）

## 8. 角丸（`mixed_corner_radius` / `layered_card_overlay`）

> **デザイン規約（lint より上位・html-artifact 全体に適用）**：**面（カード・パネル・帯・バー）は角丸を使わず直角にする**（`border-radius:0`）。とくに **2 色構成（塗りヘッダー帯＋本文）のカードで角丸は使わない**。円形（`border-radius:50%`）とピル形のチップ／バッジのみ例外。lint 上は下記のとおり「1 要素・4 隅同一半径」なら通るが、面の角丸はデッキ内で角丸と直角が混在して見えるため使わない。

lint の判定はこうなっている。実測は `border-top-left-radius` の 1 値だけを読み、**4 隅が均一である前提**で 1 枚の `roundRect` に変換される。この前提が崩れる書き方（部分丸め・重ね合わせ）が error になる。

**OK**（1 要素＝1 オブジェクトで完結する角丸）

```html
<!-- カード1枚がbackground-color・border・border-radiusを自分自身で持つ -->
<div style="background-color:#fff;border:1px solid var(--rule);border-radius:8px;padding:16px;">…</div>
<!-- 丸バッジも1要素なので同様にOK -->
<span style="width:32px;height:32px;border-radius:50%;background:var(--accent);"></span>
```

**NG**（角丸のために複数要素を重ねる・4 隅の半径をそろえない）

```html
<!-- ヘッダー部だけ角丸（border-radius: 8px 8px 0 0）＋本文部を重ねた2要素構成 -->
<div class="ph" style="border-radius:8px 8px 0 0;background:var(--accent);">見出し</div>
<div class="pb" style="background:#fff;">本文</div>
```

- 上下（または左右）で半径が異なる 1 枚のカード（例：見出し部だけ角丸のヘッダー＋角ばった本文を重ねた構成）は、pptx では上 2 角・下 2 角だけ丸める専用シェイプに強制的に**分割**される。継ぎ目に意図しない線が入る・重ねた 2 枚の位置がずれる、という崩れの原因になる
- 「枠線付きの角丸カード」に「色帯」を上乗せする装飾（frame＋band の重ね合わせ）も同じ理由で 2 オブジェクト化する
- 半径を短辺の 50% 超で指定しても pptx 側は 50% で頭打ちになるため、意図した丸みにならない（真円・カプセル型にしたいときは 50% 指定で止める）
- ヘッダー部の色だけ変えたいときは、**カード全体は 4 隅同一半径の 1 要素のまま**にし、その内側に角丸なしの帯（`border-radius` を持たない `div`）を敷いて色だけ変える。角を丸めるのはカードを包む一番外側の 1 要素だけにする

## 9. 表の罫線は列・行を通じて統一する（`mixed_cell_border`）

このパイプラインは HTML の `<table>` から新規に pptx ネイティブテーブルを合成するのではなく、**セルを個別の図形に分解する**。各セルは「上辺の罫線スタイル」だけを本体の罫線として採用し、左右下辺が上辺と異なる色・太さ・実線/点線を持つ場合は、辺ごとに**独立した線シェイプ**が追加生成される。セルごとに罫線スタイルを変えるほど、生成されるオブジェクト数が線形に増える。

- **OK**：表全体で罫線の色・太さ・スタイル（実線/点線）を統一する。ヘッダー行の下だけ太くする程度の差は許容範囲
- **NG**：セルごとに異なる罫線色・太さ・破線種別を使う（例：強調セルだけ赤枠、警告セルだけ点線、行ごとに罫線色を変える）→ セル数×差分がある辺の数だけシェイプが増える
- セルを強調したいときは罫線を変えるのではなく **`background-color`**（塗りは 1 シェイプの実測に収まり追加オブジェクトが増えない）で差をつける

## 10. デッキの骨格（構造要件）

- スライドは `<section class="slide" id="sNN">`。**`id` は全スライド必須**（分割の単位になる）
- キャンバスは 1280×720 固定（`template-slides.html` の既定どおり）
- サムネイルパネルのクローンは `id` を削除する（SKILL.md の既定どおり。`id` 付きが 1 つでもあれば `id` 付きのみが処理対象になる）
- 1 スライドの HTML は自己完結させる（外部 CSS・外部 JS に依存した見た目にしない）

---

## チェックリスト（提出前）

- [ ] `make run_html_pptx_lint SAMPLE_DIR=...` で **error 0 件**
- [ ] warning のうち `text_no_headroom` は、見出し・ラベル・チップなど折り返し不可の行がゼロ
- [ ] 箇条書きマーカー・✓・章番号が、それぞれ行のテキストの一部になっている
- [ ] 字下げが `margin-left` ではなく `padding-left`＋負の `text-indent` で作られている
- [ ] 行ごとのアンダーライン（`border-bottom`）が無い（区切りは行間で表現している）
- [ ] カードは `background-color` ＋ `border` の両方を持つ
- [ ] 作り込み図版に `transform: scale` が無い
- [ ] 図版の矢印が 1 本ずつ独立した要素になっている
- [ ] 面（カード・パネル・帯・バー）が直角である（2 色構成のカードに角丸が無い。円・ピル形のチップのみ例外）
- [ ] 表の罫線（色・太さ・実線/点線）がセルごとにバラバラでなく統一されている
- [ ] 変換後の pptx を元 HTML のスクリーンショットと並べて差分確認した（SKILL.md step 11「元との比較」）

## 対応するルール名一覧

| ルール | 深刻度 | 節 |
|---|---|---|
| `pseudo_shape` / `pseudo_text` | error | 1 |
| `split_inline_row` | error | 2 |
| `chip_prefixed_row` | warning | 2 |
| `scaled_container` | error | 3 |
| `background_image` / `unsupported_paint` | warning | 4 |
| `vertical_text` | error | 4 |
| `rotated_element` | warning | 4 |
| `clipped_content` | warning | 4 |
| `text_no_headroom` | warning | 5 |
| `nowrap_text` | info | 5 |
| `tiny_font` | warning | 6 |
| `svg_overlay` / `svg_thin` | warning | 7 |
| `mixed_corner_radius` | error | 8 |
| `layered_card_overlay` | warning | 8 |
| `mixed_cell_border` | warning | 9 |
