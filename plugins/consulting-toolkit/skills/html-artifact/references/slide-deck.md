# Slide Deck — Slide Deck format 専用シェル仕様

16:9 HTML スライドデッキ（Slide Deck format）のフレーム・プレゼンモード・印刷対応仕様。本文コンポーネント（`.title-bar`, `.message`, `.body-list`, `.insight`, `.scope-panel`, `.fact-list`, `.kpi-row` 等）と配色テーマは触らず、`components.md` / `design-system.md` のものをそのまま使う。

## 設計思想

- スライドは **1280×720 px の固定キャンバス**（HD 16:9）。テーマ・内容によらず変えない。ビューポートに合わせてビジュアルだけを自動スケーリングする
- 1 スライド = 1 メッセージ。詰め込みすぎない
- プレゼン中はキーボードと（少しの）マウスクリックだけで全操作完結
- URL ハッシュ `#sN` で深リンク可能。ブラウザの戻る/進むも同期
- 印刷で 1 スライド = 1 ページの PDF が出る（配布資料として渡せる）
- 自己完結（Google Fonts のみ外部依存。それ以外の CSS/JS リソース読み込みなし）

## テーマ切替

Slide Deck format は **5 テーマ共通の同一シェル**を使う。テーマ切替は `:root` の `--accent` / `--accent-soft` / `--accent-bg` の 3 変数のみで行う。`<body>` クラスでモードを分ける仕組みは持たない（旧表現の対応は `document-recipes.md`「エイリアス（後方互換）」を参照）。

| テーマ | 性格・主用途 |
|---|---|
| Terracotta（デフォルト） | warm consulting — 企画書・報告書・議事メモのスライド版 |
| Navy | 金融・大企業・通達のスライド |
| Forest | 調査結果報告、ESG・サステナビリティ |
| Charcoal | テクニカル・議事メモ |
| **Mono** | **投資家ピッチ、コンサル提案書、ハイステークス資料** |

迷ったら：**外部のハイステークスステークホルダー向け = Mono**、それ以外は Terracotta。

### Mono テーマと拡張コンポーネントの組み合わせ

黒帯反転・巨大数字・結論バー・図解アノテーションのスタイルは、**Mono テーマ + 拡張コンポーネント 22〜25（Eyebrow Bar / Hero Number / Takeaway Strip / Annotation Pointer）** で構成する。

これら拡張コンポーネントは他テーマや Vertical Document でも使えるが、Mono テーマと組み合わせた時に最も映える。詳細は `components.md` を参照。

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
- スライド外背景は **`#2a2c30` 固定**（テーマ非依存）。本体の `<body>` 背景に指定する

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
  background: #2a2c30;
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
    <span class="pg"><b>34</b> / 34 · ご討議に感謝いたします</span>
  </div>
</section>
```

- Summary はスライド全体で **1 枚だけ**置く（複数置かない）
- 議論喚起・謝辞を `.pg` 右側に付け加えるのは可

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
.slide table.tb{ font-size: 13px }
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
    var panelW = panelOpen ? PANEL_W : 0;
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
    var open = (saved === null) ? true : (saved === '1');
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

スライド本体のクリックではページ送りを行わない（プレゼン中の誤クリックによる不意の遷移を避けるため、キーボード操作・サムネイル経由のみで遷移する）。

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

スライド固有のカラーパレットは持たない。`design-system.md` の `:root` 変数（Terracotta / Navy / Forest / Charcoal の 4 テーマ）をそのまま使う。

- スライド内背景：`var(--bg)`（`#fafaf6` 紙質クリーム）
- スライド外背景：`#2a2c30` 固定（プレゼンモードでスライド周辺を暗くするため）
- アクセント：`var(--accent)` 1 色のみ
- テーマ差し替えは `--accent` / `--accent-soft` / `--accent-bg` の 3 変数のみ

スライド外背景の `#2a2c30` は唯一の例外。これは「投影中にスライドを浮き立たせる」ための機能色で、`design-system.md` のテーマには依存しない。

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
