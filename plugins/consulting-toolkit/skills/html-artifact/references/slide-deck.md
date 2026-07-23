# Slide Deck — Slide Deck format 専用シェル仕様

16:9 HTML スライドデッキ（Slide Deck format）のフレーム・プレゼンモード・印刷対応仕様。本文コンポーネントの CSS はスライド専用部品（`.title-bar`, `.message`, `.body-list`, `.fact-list`, `.insight`（`.txt` 形）, `.scope`（スライド簡易形）等）も構造化データコンポーネント #10〜21（`.kpi-row`, `.state-grid`, `table.report-table`, `.prio-list`, `.budget-grid`, `.qa-grid`, `.roadmap-wrap`, `.proposal-card`, `.flow-margin`, `.scope-panel` 等）も `assets/template-slides.html` に搭載済み。仕様・利用ルール・配色テーマは `components.md` / `design-system.md` に従い、独自に再スタイルしない。

## 設計思想

- スライドは **1280×720 px の固定キャンバス**（HD 16:9）。テーマ・内容によらず変えない。ビューポートに合わせてビジュアルだけを自動スケーリングする
- 1 スライド = 1 メッセージ。詰め込みすぎない
- プレゼン中はキーボード・マウスクリック・タッチ（スワイプ）で操作完結。スマホでも閲覧しやすい（サムネイルパネルは小さく左に表示し、ビューを隠さない）
- URL ハッシュ `#sN` で深リンク可能。ブラウザの戻る/進むも同期
- 印刷で 1 スライド = 1 ページの PDF が出る（配布資料として渡せる）
- 自己完結（Google Fonts のみ外部依存。それ以外の CSS/JS リソース読み込みなし）

## テーマ切替

Slide Deck format は **5 テーマ共通の統一シャシ**を使う。角丸・影・Filled-Header Card 群・Value Bar 等の視覚言語は 5 テーマで完全に共通で、**テーマ切替は `:root` の `--accent` / `--accent-soft` / `--accent-bg` の 3 変数のみ**で完結する（`<body>` クラスによるモード切替はしない。旧表現の対応は `document-recipes.md`「エイリアス（後方互換）」を参照）。

**5 テーマは palette 違いのみ**：Mono = 黒帯、Terracotta = テラコッタ帯、Navy = 紺帯、Forest = 深緑帯、Charcoal = チャコール帯（実質モノに近い）。既定は Mono。

```css
/* Terracotta に切り替える場合の唯一の差分 */
:root{
  --accent:#9d3617;
  --accent-soft:#c45a2c;
  --accent-bg:#f5e8de;
}
```

構造色（`--bg` / `--panel-soft` / `--rule` / `--ink` 等）と、カード装飾（`--card-radius` / `--card-shadow`）、段階濃度ランプ（`--stage-1〜4`、`--accent` から `color-mix` で自動派生）は 5 テーマ共通で不動。Filled-Header Card / Value Bar / Icon Chip / Pill Tag / Expansion Pills（#26〜30）は **5 テーマすべてで使える**（Mono 専用ではない）。

| テーマ | accent 値 |
|---|---|
| **Mono（既定）** | `#1a1a1a` |
| Terracotta | `#9d3617` |
| Navy | `#1e3a5f` |
| Forest | `#2a4f3a` |
| Charcoal | `#2d2d33` |

迷ったら：**Slide Deck は Mono 既定**。色味を変えたい場合のみ他テーマを選ぶ。用途に応じた使い分けは規定しない。

### Mono テーマと拡張コンポーネントの組み合わせ

黒帯反転・巨大数字・結論バー・図解アノテーションのスタイルは、**Mono テーマ + 拡張コンポーネント 22〜25（Eyebrow Bar / Hero Number / Takeaway Strip / Annotation Pointer）** で構成する。

これら拡張コンポーネントは他テーマや Vertical Document でも使えるが、Mono テーマと組み合わせた時に最も映える。詳細は `components.md` を参照。

### 参照デザイン踏襲時のパターン（5 テーマ共通・スライド専用）

Slide Deck では 5 テーマ共通で、参照デザイン（`AI Biz Ops Partner/assets` および `V_ビザスク/24_インフォコム/02_Phase2/Output/提案書/figures`）を踏襲する。テキストパネル・箇条書きで済ませず、以下 5 種を積極的に組み合わせる。定義は `components.md` #26〜30。Terracotta を選べばテラコッタ帯のカード、Navy を選べば紺帯のカード、と `--accent` に自動追従する。

| コンポーネント | 使いどころ |
|---|---|
| **Filled-Header Card**（`.phase-card`） | Phase / Track / セグメント別のカード。黒帯ヘッダー＋淡グレーボディ＋内部に `.section` を積む。3〜4 枚横並びで Growth Model / Phase 概観 / 3 本柱を表現 |
| **Value Bar**（`.value-bar`） | スライド最下部の締めバー。3〜4 アイテム＋縦罫でメッセージを凝縮。「1. 案件で入り課題を理解 → 2. 月額関係を構築 → …」の型 |
| **Icon Chip**（`.icon-chip`） | Filled-Header Card 内の `.section-title` 先頭に置く 1 文字ラベル（G/K/S/X/T 等のセマンティックコード） |
| **Pill Tag**（`.tag` / `.tag.primary`） | 入口テーマ・カテゴリ・分類の列挙。`.tag.primary` が黒塗り優先タグ、通常が淡グレー |
| **Expansion Pills**（`.expansion-item`） | 「→ 経営企画」「→ 営業」「→ R&D」の横展開・派生方向のピル群 |

### 段階濃度 Gantt / Timeline

時系列の進行・スケジュールは、`--stage-1〜4`（`--accent` から `color-mix` で自動派生する濃淡ランプ）でフェーズの進行を表現する。VisasQ figures の Phase 1〜4 ガントバーが規範（Mono では黒 → 淡グレー）。Terracotta を選べば「濃 → 淡テラコッタ」、Navy なら「濃 → 淡ネイビー」に自動追従する。詳細は `diagram-components.md`「段階濃度パターン」。

### キャンバスサイズの実装

```css
:root{
  --slide-w: 1280px;
  --slide-h: 720px;
}
.slide{
  width: var(--slide-w);
  height: var(--slide-h);
}
```

JS の `SLIDE_W` / `SLIDE_H` 定数も `getComputedStyle(document.documentElement).getPropertyValue('--slide-w')` で読み込み、ビューポートに応じて自動スケールフィットする。

## フレーム仕様

### スライド DOM

```html
<div class="deck">
  <section class="slide cover" id="s1"> ... </section>
  <section class="slide" id="s2"> ... </section>
  <section class="slide" id="s3"> ... </section>
  ...
</div>
```

- `<section class="slide" id="sN">` を順に並べる。`N` は 1-origin の通し番号
- 先頭の Cover スライドだけ `.cover` 修飾子を付ける（任意。本文 padding 調整用）
- スライド外背景は **5 テーマ共通で `#e5e5e5` 薄グレー**（`<body>` 背景に指定）。統一シャシではスライド内が純白なので、暗地との過剰コントラストを避ける

### スケーリングと配置

```css
:root{
  --slide-scale: 1;
  --slide-shift-x: 0px;
}

html, body{
  height: 100vh;
  width: 100vw;
  overflow: hidden;
  background: #e5e5e5;  /* 5 テーマ共通の薄グレー */
}

.deck{
  position: fixed;
  inset: 0;
  width: 100vw;
  height: 100vh;
  overflow: hidden;
}

.slide{
  position: absolute;
  top: var(--slide-top, 50%);
  left: var(--slide-left, 50%);
  width: 1280px;
  height: 720px;
  background: var(--bg);
  overflow: hidden;
  box-shadow: 0 6px 36px rgba(0,0,0,0.45);
  display: none;
  /* 位置は JS で縮小後サイズから直接計算し、描画だけ scale する。
     CSS zoom は Chrome の text caret hit-testing がずれるため使わない。
     transform-origin:top left でスケール時の基準を左上に固定。 */
  transform-origin: top left;
  transform: var(--slide-transform, translate(-50%, -50%) scale(var(--slide-scale, 1)));
  transition: opacity 0.18s ease;
  opacity: 0;
  -webkit-user-select: text;
  -moz-user-select: text;
  user-select: text;
  cursor: auto;
}
.slide.current{
  display: block;
  opacity: 1;
}

/* presentation mode 表示保護：cover/divider などのレイアウト系クラスが
   display を再指定したとしても、現在表示中でないスライドを必ず非表示にする */
.deck > .slide:not(.current){
  display: none !important;
  pointer-events: none !important;
}
.deck > .slide.current{ pointer-events: auto; }
```

- `--slide-scale` / `--slide-top` / `--slide-left` / `--slide-transform` はビューポートに合わせて JS から動的に設定
- 位置は `--slide-top` / `--slide-left` で**ピクセル単位**で指定し、`transform` は `scale(N)` だけにする
  - `translate(-50%,-50%) scale(N)` だと Chrome がスライドを composited layer 化し、text caret hit-testing がマウス位置からずれる
  - 縮小後サイズから余白を JS で計算し、`top` / `left` に直接ピクセル値を入れて中央配置する
- CSS `zoom` も同様に hit-testing ズレを起こすため使わない
- 単スライド表示は `.current` クラスのみ可視。`.deck > .slide:not(.current)` で `display:none` を `!important` 強制（cover/divider 等のレイアウトクラスが display を再指定しても確実に非表示）

## 5 種のスライド型

すべて `<section class="slide">` の中身として組む。既存 `components.md` の HTML スニペットを流用する。

### 1. Cover

タイトル・サブタイトル・4 項目メタの表紙。

```html
<section class="slide cover" id="s1">
  <div class="cover-tag">Document Type / Slide Deck</div>
  <h1 class="cover-title">タイトル（最大2行）</h1>
  <p class="cover-sub">サブタイトル<br>2行程度の説明</p>
  <dl class="cover-meta">
    <div><dt>Client</dt><dd>クライアント名</dd></div>
    <div><dt>Document</dt><dd>ドキュメント種別</dd></div>
    <div><dt>Date</dt><dd>2026.05</dd></div>
    <div><dt>Doc ID</dt><dd>DOC-2026-001</dd></div>
  </dl>
</section>
```

- `cover-title` はスライド内では 44〜52px が目安（縦長文書版の 46px と同程度）

### 2. TOC

章一覧。スライドデッキでは「セクション一覧」になる。

```html
<section class="slide" id="s2">
  <div class="title-bar"><h2>目次</h2></div>
  <ol class="toc-grid">
    <li><span class="toc-num">01</span><span class="toc-name">章名</span></li>
    <li><span class="toc-num">02</span><span class="toc-name">章名</span></li>
    ...
  </ol>
</section>
```

- TOC は 4〜8 項目までを目安に。多い場合は 2 列に分割する
- 短い議事メモなどは TOC を省略可

### 3. Section Divider（章扉）

章の切り替わりを示す。`.divider` + `.lede` の組み合わせ。

```html
<section class="slide" id="s3">
  <div class="divider">
    <div class="div-num">Section 01</div>
    <h2 class="div-title">章タイトル</h2>
    <p class="lede">この章で扱う論点を 2〜3 行で端的に提示する。</p>
  </div>
</section>
```

- 章扉は「これから何の話をするか」を 1 行で示すリード文を必ず置く

### 4. Content（本文）

1 スライド 1 メッセージの本体。`.title-bar` + `.message` を必須とし、本文系コンポーネント 1〜2 個を組み合わせる。

```html
<section class="slide" id="s4">
  <div class="title-bar">
    <span class="sec-num">1.1</span>
    <h2>スライドタイトル</h2>
  </div>

  <p class="message">このスライドで伝える唯一のメッセージを 1〜2 行で書く。</p>

  <!-- 以下のいずれか 1〜2 個 -->
  <ul class="body-list">
    <li>論拠 1</li>
    <li>論拠 2</li>
    <li>論拠 3</li>
  </ul>

  <div class="insight">
    <div class="txt">この章での重要な示唆を 1 文で。</div>
  </div>

  <div class="slide-foot">
    <span class="doc-id">DOC-2026-001</span>
    <span class="pg"><b>4</b> / 34</span>
  </div>
</section>
```

- `.title-bar` の章番号は `sec-num`（4.1 など）。`JetBrains Mono` で表示
- `.message` は本スライドの「答え」。読み手が 3 秒で意味を取れる長さに収める
- `.slide-foot` はオプション。ページ番号・doc-id を右下に出す

### 5. Summary（クロージング）

最終スライド。`.summary` ブロックで「持ち帰ってほしい結論」を端的に示す。

```html
<section class="slide" id="s34">
  <div class="title-bar"><h2>まとめ</h2></div>
  <div class="summary">
    <ul>
      <li>主要結論 1</li>
      <li>主要結論 2</li>
      <li>主要結論 3</li>
    </ul>
  </div>
  <div class="slide-foot">
    <span class="doc-id">DOC-2026-001</span>
    <span class="pg"><b>34</b> / 34</span>
  </div>
</section>
```

- Summary はスライド全体で **1 枚だけ**置く（複数置かない）
- `.pg` 右側は空欄でよい（「ご清聴に感謝いたします」等の定型の締め文句は付けない）

## 作り込み図版（crafted figures / fig-canvas）

8 図解で表現しきれない構造的メッセージのスライドでは、`.fig-NN` 名前空間の per-figure CSS で図版を 1 枚だけ作り込む。**設計・作図文法・配色・ガードレール・レイアウトパターン（スイムレーン/マトリクス/カード/ステップ/タイムライン）の本体は [diagram-components.md](diagram-components.md)（図解の統合リファレンス）を参照**。ここではシェル側の仕組みだけ示す。

### fig-canvas / scale の仕組み

大きいネイティブサイズで図版を組み、`transform: scale` で本文領域（padding 内 = **1152px** 幅）に縮小する。`.slide` は 1280×720・padding 60/64/56 のため本文領域は 1152×604px、Content スライドでは title-bar（≈70px）＋ message を引いて **図版領域は概ね 1152×440px**。

template-slides.html に定義済みのスキャフォルド：

```css
.fig-wrap{display:flex;justify-content:center;align-items:flex-start;overflow:hidden;margin:6px 0}
.fig-canvas{flex-shrink:0;transform-origin:top center}
```

マークアップ（title-bar / message の下、slide-foot の上）：

```html
<div class="fig-wrap"><div class="fig-canvas fig-01"><!-- 図版 --></div></div>
```

per-figure 寸法はデッキの `<style>` に追記：

```css
.fig-01{ width:1400px; transform:scale(0.823); }   /* scale = 1152 / ネイティブ幅 */
```

- **scale は必ず `1152 / ネイティブ幅`** で算出（視覚幅を本文幅に一致させる）。作例の `1488px/0.78` をコピーしない（このシェルは padding 64px・本文 1152px で別ジオメトリ）。
- ネイティブ幅は 1300〜1500px、ネイティブ高 × scale ≦ ≈440px に収める。
- 配色は `--fig-accent`（既定 `--accent`）由来の `color-mix` ランプ + `--good`/`--warn` のみ（テーマ追従）。ブランド色はデッキの `:root` で `--fig-accent` を上書き。

### 図版スライドは `fig-slide` で縦領域を使い切る（必須）

作り込み図版を載せる Content スライドの `<section class="slide">` には **`fig-slide` クラスを付ける**。template-slides.html がスライドを縦 flex 化し、`.fig-wrap` に `flex:1`＋上下中央を与えるため、図版が縦領域（≈440〜460px）の上 1/3 に縮こまって下半分が空白になる事故を防げる。

```html
<section class="slide fig-slide" id="sN"> ... </section>
```

- **flow 図版**：表示サイズ（1152px 幅）で直組みし、領域に対して小さければ**ノードの `min-height`・`padding`・`gap` を増やして自然高を ≈440〜460px まで伸ばす**。残差は `fig-slide` の縦中央寄せが吸収する（小さい図を上に張り付けない）。
- **絶対配置図版**：ネイティブ高 × scale を**図版領域高（≈440px）に近づける**よう設計する（小さく作らない）。
- 「図版領域を使い切る」は diagram-components.md の作図文法 step 6・検証チェックリストの必須項目。`fig-slide` はそれをシェル側で担保する受け皿。

### 非図版スライドの縦充填は `vfill` で行う（SKILL.md step 5「縦充填」の標準手段）

図版を載せない通常の Content スライドは、そのままではコンテンツが上に積まれる（上重心）。SKILL.md step 5 の縦充填（下部に約 120px 超の空白を残さない）は、まず**行高・パディング・フォント・要素間マージンのスケールアップ**で領域を使い切り、それでも残る縦の余りを template-slides.html 標準搭載の `vfill` で吸収する。

```html
<section class="slide vfill" id="sN">
  <div class="title-bar"> ... </div>
  <p class="message"> ... </p>
  <div class="vgrow">
    <!-- 本文ブロック（body-list / kpi-row / state-grid 等）をここに集める -->
  </div>
  <div class="slide-foot"> ... </div>
</section>
```

- `vfill` はスライドを縦 flex 化し、`.vgrow` に残りの縦領域を与えて**縦中央寄せ**にする（fig-slide の非図版版）
- 本文ブロックが複数あり、ブロック間の余白を均等に広げたい場合は `<div class="vgrow spread">`
- 表紙（cover）・章扉（divider）・まとめ（summary）の上重心にも `vfill`＋`.vgrow` が使える（divider は自前で縦中央のため不要）
- 図版スライドには `vfill` でなく `fig-slide` を使う（併用しない）

### 印刷・サムネイルでのクリップ注意

`transform: scale` は見た目を縮めるがレイアウト箱は縮まないため、`.fig-wrap{overflow:hidden}` が「視覚的には収まる」図版をクリップしうる。`.fig-canvas` の scale は `.slide` のビューポート scale、さらにサムネイルの `scale(0.125)` と三重に入れ子になる。**ライブ・印刷（PDF）・サムネイルの 3 経路で確認**し、`@media print` が `.slide` の transform だけを解除して子孫 `.fig-canvas` の scale を消さないことを確かめる。

## タイポグラフィ調整（スライド向け）

縦長文書版より少し大きめに調整する。`<style>` 末尾に以下を追加する：

```css
/* Slide-context typography overrides */
.slide .message{ font-size: 17px; line-height: 1.7; margin: 12px 0 18px }
.slide .body-list{ font-size: 14.5px; line-height: 1.85 }
.slide .minor-head{ font-size: 14.5px }
.slide .insight .txt{ font-size: 15.5px; line-height: 1.7 }
.slide .fact-list{ font-size: 13.5px }
.slide table.report-table{ font-size: 13px }
.slide .scope ul{ font-size: 14.5px; line-height: 1.75 }
.slide .summary ul li{ font-size: 17px; line-height: 1.7 }
```

- 投影距離・解像度に応じて全体を ±1〜2px の幅で調整する
- 本文サイズを上げたら、その分 1 スライドに入る情報量を減らす（密度ガイドラインを守る）

## プレゼンチャーム（HTML）

`</div><!-- /.deck -->` の直後に配置：

```html
<button class="thumb-toggle" id="thumbToggle" type="button"
        aria-label="サムネイル一覧の表示切替"
        title="サムネイル一覧（T）"></button>
<aside class="thumb-panel" id="thumbPanel" aria-label="スライド一覧">
  <div class="thumb-panel-head">Slides</div>
  <div class="thumb-list" id="thumbList"></div>
</aside>

<div class="deck-counter" id="deckCounter"><b>1</b> / 34</div>
<div class="deck-hint" id="deckHint">← → / Enter / Space で移動　・　T でサムネイル</div>
```

- カウンタとヒントは右下・左下の固定オーバーレイ
- サムネイルは JS で `slides[i].cloneNode(true)` から動的に生成

## プレゼンチャーム（CSS）

```css
/* Slide counter */
.deck-counter{
  position: fixed; bottom: 14px; right: 20px; z-index: 1000;
  font-family: "JetBrains Mono", monospace; font-size: 11px;
  color: rgba(255,255,255,0.55); letter-spacing: 0.12em;
  pointer-events: none; user-select: none;
}
.deck-counter b{ color: rgba(255,255,255,0.85); font-weight: 500 }

/* Navigation hint (auto-fade) */
.deck-hint{
  position: fixed; bottom: 14px; left: 20px; z-index: 1000;
  font-family: "JetBrains Mono", monospace; font-size: 11px;
  color: rgba(255,255,255,0.4); letter-spacing: 0.08em;
  pointer-events: none; user-select: none;
  transition: opacity 0.6s ease, left 0.25s ease;
}
.deck-hint.fade{ opacity: 0 }
body.panel-open .deck-hint{ left: 228px }

/* Thumbnail toggle button */
.thumb-toggle{
  position: fixed; top: 12px; left: 12px; z-index: 1200;
  width: 34px; height: 34px;
  background: rgba(20,22,26,0.88); color: rgba(255,255,255,0.85);
  border: 1px solid rgba(255,255,255,0.15); border-radius: 6px;
  font-size: 16px; line-height: 1; cursor: pointer;
  display: flex; align-items: center; justify-content: center;
  transition: background 0.15s ease, left 0.25s ease, color 0.15s ease;
  user-select: none; font-family: "Noto Sans JP", sans-serif;
}
.thumb-toggle:hover{ background: rgba(40,42,46,0.95); color: #fff }
.thumb-toggle::before{ content: "\2630" }
body.panel-open .thumb-toggle{ left: 222px }
body.panel-open .thumb-toggle::before{ content: "\2715" }

/* Thumbnail panel */
.thumb-panel{
  position: fixed; top: 0; left: 0; bottom: 0; z-index: 1100;
  width: 210px;
  background: rgba(18,20,24,0.97);
  border-right: 1px solid rgba(255,255,255,0.08);
  overflow-y: auto; overflow-x: hidden;
  transform: translateX(-100%);
  transition: transform 0.25s ease;
  padding: 56px 0 16px;
}
body.panel-open .thumb-panel{ transform: translateX(0) }
.thumb-panel::-webkit-scrollbar{ width: 6px }
.thumb-panel::-webkit-scrollbar-track{ background: transparent }
.thumb-panel::-webkit-scrollbar-thumb{ background: rgba(255,255,255,0.15); border-radius: 3px }
.thumb-panel::-webkit-scrollbar-thumb:hover{ background: rgba(255,255,255,0.25) }

.thumb-panel-head{
  font-family: "JetBrains Mono", monospace; font-size: 10px;
  letter-spacing: 0.14em; color: rgba(255,255,255,0.4);
  padding: 0 16px 10px; text-transform: uppercase;
}
.thumb-list{ display: flex; flex-direction: column; gap: 2px }

.thumb-item{
  display: flex; align-items: center; gap: 8px;
  padding: 6px 10px 6px 8px;
  cursor: pointer; transition: background 0.12s ease;
  border-left: 2px solid transparent;
}
.thumb-item:hover{ background: rgba(255,255,255,0.04) }
.thumb-item.current{
  background: rgba(120,156,224,0.14);
  border-left-color: rgba(150,180,240,0.85);
}

.thumb-num{
  width: 20px; flex-shrink: 0; text-align: right;
  font-family: "JetBrains Mono", monospace; font-size: 10px;
  color: rgba(255,255,255,0.45);
}
.thumb-item.current .thumb-num{ color: rgba(190,215,255,0.95); font-weight: 600 }

.thumb-frame{
  width: 160px; height: 90px; flex-shrink: 0;
  overflow: hidden; position: relative;
  background: var(--bg);
  border: 1px solid rgba(255,255,255,0.1); border-radius: 2px;
}
.thumb-item.current .thumb-frame{
  border-color: rgba(160,190,245,0.6);
  box-shadow: 0 0 0 1px rgba(160,190,245,0.3);
}

/* Cloned slide inside a thumbnail: reset positioning and scale to 1/8 */
.thumb-frame .slide{
  position: absolute !important;
  top: 0 !important; left: 0 !important;
  width: 1280px !important; height: 720px !important;
  transform: scale(0.125) !important;
  transform-origin: top left !important;
  display: block !important;
  opacity: 1 !important;
  margin: 0 !important;
  box-shadow: none !important;
  transition: none !important;
  pointer-events: none;
}

/* スマホ等の狭い画面：サムネイルパネルを小さく左に置く。
   開いてもスライドは右側に縮小表示され、ビューが隠れない（JS fit が実測幅を差し引く）。 */
@media (max-width:899px){
  .thumb-panel{ width: 104px; padding: 46px 0 12px }
  .thumb-panel-head{ display: none }
  .thumb-item{ padding: 5px 6px; gap: 0; justify-content: center }
  .thumb-num{ display: none }
  .thumb-frame{ width: 86px; height: 48px }
  .thumb-frame .slide{ transform: scale(0.0672) !important }
  body.panel-open .thumb-toggle{ left: 114px }
  .deck-hint{ display: none }
}
```

## プレゼンチャーム（JavaScript 完成形）

スライド遷移・スケーリング・サムネイル生成・キーボード操作・URL ハッシュ同期をひとつの IIFE にまとめる。`</body>` 直前に置く。

```html
<script>
(function(){
  var slides = Array.from(document.querySelectorAll('.slide'));
  var counter = document.getElementById('deckCounter');
  var hint = document.getElementById('deckHint');
  var toggleBtn = document.getElementById('thumbToggle');
  var thumbList = document.getElementById('thumbList');
  var PANEL_W = 210;
  var SLIDE_W = 1280;
  var SLIDE_H = 720;
  var current = 0;
  var thumbItems = [];

  // Build thumbnail items by cloning each slide. IMPORTANT: strip all id
  // attributes from the clone to avoid duplicates.
  function buildThumbnails(){
    slides.forEach(function(slide, i){
      var item = document.createElement('div');
      item.className = 'thumb-item';
      item.setAttribute('data-idx', i);

      var num = document.createElement('span');
      num.className = 'thumb-num';
      num.textContent = String(i + 1).padStart(2, '0');

      var frame = document.createElement('div');
      frame.className = 'thumb-frame';

      var clone = slide.cloneNode(true);
      clone.removeAttribute('id');
      clone.classList.remove('current');
      clone.querySelectorAll('[id]').forEach(function(el){ el.removeAttribute('id'); });
      frame.appendChild(clone);

      item.appendChild(num);
      item.appendChild(frame);
      item.addEventListener('click', function(e){
        e.stopPropagation();
        go(i);
      });
      thumbList.appendChild(item);
      thumbItems.push(item);
    });
  }

  // Fit current slide into viewport, preserving 16:9
  function fit(){
    var panelOpen = document.body.classList.contains('panel-open');
    // パネルを開いている間はスライド表示領域からパネル幅を差し引く（ビューを隠さない）。
    // 幅は CSS 実測値を使うため、デスクトップ(210px)/スマホ(小さいパネル)が自動で整合する。
    var panelEl = document.querySelector('.thumb-panel');
    var panelW = (panelOpen && panelEl) ? panelEl.offsetWidth : 0;
    var availW = window.innerWidth - panelW;
    var availH = window.innerHeight;
    var scale = Math.min(availW / SLIDE_W, availH / SLIDE_H);
    document.documentElement.style.setProperty('--slide-scale', scale);
    document.documentElement.style.setProperty('--slide-shift-x', (panelW / 2) + 'px');
  }

  function update(){
    slides.forEach(function(s, i){
      s.classList.toggle('current', i === current);
    });
    thumbItems.forEach(function(t, i){
      t.classList.toggle('current', i === current);
    });
    if (counter){
      counter.innerHTML = '<b>' + (current + 1) + '</b> / ' + slides.length;
    }
    if (document.body.classList.contains('panel-open') && thumbItems[current]){
      var rect = thumbItems[current].getBoundingClientRect();
      if (rect.top < 60 || rect.bottom > window.innerHeight - 16){
        thumbItems[current].scrollIntoView({block: 'center', behavior: 'smooth'});
      }
    }
    try { window.history.replaceState(null, '', '#s' + (current + 1)); } catch(_){}
  }

  function go(idx){
    if (idx < 0) idx = 0;
    if (idx >= slides.length) idx = slides.length - 1;
    if (idx === current) return;
    current = idx;
    update();
  }

  function togglePanel(){
    document.body.classList.toggle('panel-open');
    try {
      localStorage.setItem('slide-deck-panel-open',
        document.body.classList.contains('panel-open') ? '1' : '0');
    } catch(_){}
    fit();
    setTimeout(update, 60);
  }

  function initFromHash(){
    var m = (window.location.hash || '').match(/^#s(\d+)$/);
    if (m){
      var n = parseInt(m[1], 10);
      if (n >= 1 && n <= slides.length) current = n - 1;
    }
  }

  function initPanelState(){
    var saved = null;
    try { saved = localStorage.getItem('slide-deck-panel-open'); } catch(_){}
    // 既定はデスクトップのみ開く。スマホ等の狭い画面では閉じた状態で開始する。
    var open = (saved === null) ? (window.innerWidth >= 900) : (saved === '1');
    if (open) document.body.classList.add('panel-open');
  }

  function isTyping(target){
    if (!target) return false;
    var tag = (target.tagName || '').toLowerCase();
    return tag === 'input' || tag === 'textarea' || tag === 'select' || target.isContentEditable;
  }

  document.addEventListener('keydown', function(e){
    if (e.metaKey || e.ctrlKey || e.altKey) return;
    if (isTyping(e.target)) return;

    var next = ['Enter','ArrowRight','ArrowDown','PageDown'];
    var prev = ['Backspace','ArrowLeft','ArrowUp','PageUp'];

    if (next.indexOf(e.key) !== -1 || (e.key === ' ' && !e.shiftKey)){
      e.preventDefault(); go(current + 1);
    } else if (prev.indexOf(e.key) !== -1 || (e.key === ' ' && e.shiftKey)){
      e.preventDefault(); go(current - 1);
    } else if (e.key === 'Home'){
      e.preventDefault(); go(0);
    } else if (e.key === 'End'){
      e.preventDefault(); go(slides.length - 1);
    } else if (e.key === 't' || e.key === 'T'){
      e.preventDefault(); togglePanel();
    } else if (e.key === 'f' || e.key === 'F'){
      e.preventDefault();
      if (document.fullscreenElement) document.exitFullscreen();
      else if (document.documentElement.requestFullscreen) document.documentElement.requestFullscreen();
    } else if (e.key === 'Escape' && document.body.classList.contains('panel-open')){
      e.preventDefault(); togglePanel();
    }
  });

  if (toggleBtn){
    toggleBtn.addEventListener('click', function(e){
      e.stopPropagation(); togglePanel();
    });
  }

  // --- スワイプでページ送り（タッチ端末） ---
  var tStartX = null, tStartY = null;
  document.addEventListener('touchstart', function(e){
    if (e.touches.length !== 1){ tStartX = null; return; }
    // サムネイルパネル内のスワイプ（縦スクロール）はページ送りに使わない
    if (e.target.closest && e.target.closest('.thumb-panel')){ tStartX = null; return; }
    tStartX = e.touches[0].clientX;
    tStartY = e.touches[0].clientY;
  }, {passive:true});
  document.addEventListener('touchend', function(e){
    if (tStartX === null) return;
    var dx = e.changedTouches[0].clientX - tStartX;
    var dy = e.changedTouches[0].clientY - tStartY;
    tStartX = null;
    // 横移動が十分大きく、かつ縦移動より主であるときだけページ送り
    if (Math.abs(dx) < 45 || Math.abs(dx) < Math.abs(dy) * 1.3) return;
    if (dx < 0) go(current + 1); else go(current - 1);
  }, {passive:true});

  window.addEventListener('hashchange', function(){
    var m = (window.location.hash || '').match(/^#s(\d+)$/);
    if (m){
      var n = parseInt(m[1], 10);
      if (n >= 1 && n <= slides.length && (n - 1) !== current){
        current = n - 1; update();
      }
    }
  });

  window.addEventListener('resize', fit);

  initPanelState();
  buildThumbnails();
  initFromHash();
  fit();
  update();
  setTimeout(function(){ if (hint) hint.classList.add('fade'); }, 4500);
})();
</script>
```

### キーボードショートカット一覧

| キー | 動作 |
|---|---|
| `→` `↓` `Enter` `Space` `PageDown` | 次のスライド |
| `←` `↑` `Shift+Space` `PageUp` `Backspace` | 前のスライド |
| `Home` | 先頭スライド |
| `End` | 末尾スライド |
| `F` | フルスクリーン切替 |
| `T` | サムネイルパネルの開閉 |
| `Esc` | サムネイルパネルを閉じる |

### マウス操作

| 操作 | 動作 |
|---|---|
| サムネイル項目をクリック | そのスライドへジャンプ |
| トグルボタン（左上 ☰ / ✕）をクリック | サムネイルパネル開閉 |

スライド本体のクリックではページ送りを行わない（プレゼン中の誤クリックによる不意の遷移を避けるため、キーボード・サムネイル・スワイプで遷移する）。

### タッチ操作（スマホ・タブレット）

| 操作 | 動作 |
|---|---|
| 左スワイプ | 次のスライド |
| 右スワイプ | 前のスライド |
| トグルボタン（左上 ☰）をタップ | サムネイルパネル開閉 |

- 横移動が 45px 未満、または縦移動が主のスワイプはページ送りにしない（縦スクロール・誤操作と干渉しない）。サムネイルパネル内のスワイプはページ送りに使わない。
- 狭い画面（`max-width:899px`）ではサムネイルパネルは既定で閉じ、開いてもパネルを小さく左に表示してスライドを右側に残す（ビューを隠さない）。

## 印刷モード（必須）

```css
@media print{
  html, body{
    background: white;
    overflow: visible;
    height: auto;
    width: auto;
  }
  .deck{
    position: static;
    padding: 0;
    width: auto; height: auto;
    overflow: visible;
    display: block;
  }
  .slide{
    position: relative !important;
    top: auto !important; left: auto !important;
    transform: none !important;
    opacity: 1 !important;
    display: block !important;
    box-shadow: none;
    page-break-after: always;
    break-after: page;
    margin: 0 !important;
  }
  /* シェルの .deck > .slide:not(.current){display:none !important} は
     .slide 単体（0-1-0）より詳細度が高く（0-3-0）、上の display:block !important に
     勝ってしまう（印刷時に現在のスライド 1 枚しか出ないバグ）。
     同詳細度のセレクタで上書きして全スライドを展開する */
  .deck > .slide:not(.current){
    display: block !important;
    pointer-events: auto !important;
  }
  .deck-counter, .deck-hint, .thumb-panel, .thumb-toggle{
    display: none !important;
  }
  @page{ size: 1280px 720px; margin: 0 }
}
```

- 印刷ダイアログから「PDF として保存」で配布資料用 PDF が出る
- プレゼンチャーム（カウンタ・ヒント・サムネイル・トグル）は印刷時に必ず非表示
- すべてのスライドが順に展開され、1 ページ 1 スライドで出力される
- **`.deck > .slide:not(.current)` の print 上書きを忘れない**：presentation mode の表示保護（`display:none !important`）は `.slide` 単体の print 宣言より詳細度が高いため、これがないと印刷で 1 枚しか出力されない

## 配色

Slide Deck では **5 テーマが統一シャシを共有**する（Vertical Document のテーマ体系とは別）。

- スライド内背景：**5 テーマ共通で `#ffffff` 純白**
- スライド外背景：**5 テーマ共通で `#e5e5e5` 薄グレー**
- アクセント：`var(--accent)` 1 色のみ。テーマ切替は `--accent` / `--accent-soft` / `--accent-bg` の 3 変数
- カード装飾（`--card-radius` / `--card-shadow`）、段階濃度ランプ（`--stage-1〜4` = `--accent` 派生）、構造色（`--panel-soft` / `--rule` / `--ink` 等）は 5 テーマ共通で不動

**Vertical Document との差**：Vertical Document は各テーマが独自の背景・ink 等を持ち（Terracotta は紙質クリーム、Navy は同、Mono は純白）、視覚言語も異なる。Slide Deck の統一シャシは Slide Deck 専用の運用。

## アクセシビリティ・チェックリスト

- [ ] `<html lang="ja">` を指定
- [ ] スライド外側（プレゼンチャーム）の操作要素に `aria-label` を付ける
- [ ] フォーカス可視（`:focus-visible` のアウトラインを残す）
- [ ] キーボード操作だけで全機能にアクセス可（マウス必須にしない）
- [ ] フォーム要素にフォーカス中はキーボード送りを奪わない（`isTyping()` で判定済み）
- [ ] 印刷で全スライドが順に出る（PDF として配布可能）
- [ ] 絵文字は使わない（`●■◆＋×✓` 等の記号のみ）

## トラブルシューティング

- **サムネイルにスライド内の要素 ID が二重登録される**：`buildThumbnails()` で `cloneNode(true)` した直後に `clone.querySelectorAll('[id]').forEach(...)` で全 ID を剥がすことを徹底
- **`fit()` が呼ばれずスライドが小さい / はみ出す**：初期化時の `fit()` と `window.addEventListener('resize', fit)` の両方が必要
- **印刷で 1 ページに複数スライドが入ってしまう**：`@page size: 1280px 720px` と `.slide { page-break-after: always }` の両方が必要
- **印刷（PDF 保存）で現在表示中の 1 枚しか出ない**：`@media print` 内に `.deck > .slide:not(.current){ display:block !important }` の上書きが必要（presentation mode の表示保護が `.slide` 単体の print 宣言より詳細度で勝つため。「印刷モード（必須）」参照）
- **`#sN` で開いても先頭になる**：`initFromHash()` が `update()` の前に呼ばれているか確認
- **サムネイルパネルを閉じてもスライドが右寄せのまま**：`togglePanel()` から `fit()` を必ず呼ぶ
- **スライドが詰まりすぎて読めない**：1 スライド 1 メッセージに分割。本文系コンポーネントは 1〜2 個まで
