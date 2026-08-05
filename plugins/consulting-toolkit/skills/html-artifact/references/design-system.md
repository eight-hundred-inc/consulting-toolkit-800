# Design System — 配色・タイポ・コンポーネント仕様

業務文書（コンサルティングファームの社内資料）として違和感のない、紙質クリーム背景＋Noto Sans JP 統一フォントの上品で実務的なドキュメントスタイル。情報の構造性を最優先し、装飾は最小限。

## 設計原則

1. **コンテンツ第一**: 装飾は情報を読みやすくするためだけにある
2. **オフライン擬似自己完結**: 外部 CSS/JS は禁止。**ただし Google Fonts（`fonts.googleapis.com`）の `<link rel="stylesheet">` のみ例外で許可**（Noto Sans JP / JetBrains Mono の読み込みのため、公開スキル `html-publish` 側の検証カーブアウトと同期）
3. **印刷可能**: `@media print` で sticky を解除し、page-break を制御する
4. **画面サイズ非依存**: 最大幅 1180px 中央寄せ、`@media (max-width:920px)` の 1 段階のみで対応
5. **長期可読性**: ダークモードに頼らず、ライトモード単独で完成させる

## カラーパレット

```css
:root{
  /* 背景 */
  --bg: #fafaf6;          /* メイン背景（紙質クリーム）。純白(#ffffff)は使わない */
  --bg-alt: #f1ede3;      /* セカンダリ背景（lede・scope-panel） */
  --panel: #ffffff;       /* カード・テーブル等の前面パネル */

  /* テキスト */
  --ink: #1a1c20;         /* 主本文（純黒ではないチャコール） */
  --ink-soft: #3d4148;    /* 補助テキスト */
  --ink-mute: #6b6f76;    /* メタ・ラベル等の弱いテキスト */

  /* 罫線 */
  --rule: #d8d2c2;        /* 主罫線（やや暖かいグレー） */
  --rule-soft: #e8e3d6;   /* 細罫線・テーブル内罫線 */

  /* アクセント（必ずこの3トーンの範囲で使う） */
  --accent: #9d3617;      /* 主アクセント（深いテラコッタ） */
  --accent-soft: #c45a2c; /* 明るいアクセント（ダーク背景上で使う） */
  --accent-bg: #f5e8de;   /* アクセント背景（insight・固定8図解の .accent 等）。
                             ★契約：文字を載せる面なので 6 テーマすべてで accent の淡ティント
                             （明るい色）にする。詳細は下記「--accent-bg の契約」 */

  /* 作り込み図版（crafted figures, Slide Deck 限定）の配色基点。
     既定で --accent を継承し、テーマ切替に追従する。
     ブランド色を図版にだけ効かせたいデッキでは、このデッキ単位で
     --fig-accent: #0052FF; のように上書きする（既定では使わない）。
     詳細は references/diagram-components.md（作り込み図版）。 */
  --fig-accent: var(--accent);

  /* セマンティック（最小限） */
  --good: #2e5a3f;
  --good-bg: #e4ebd9;
  --warn: #7a4a1a;
  --warn-bg: #f0e3cd;
}
```

### 使い方の原則

- **アクセントカラーは1色（`--accent`）のみ**。「区別したいから青も追加」はしない。区別は罫線・配置・ラベルで行う
- **帯系コンポーネントはテーマ追従**：`report-table thead`・`state-box.target`・`budget-card.premium`・`proposal-head`・`dc-marker`・`hero-number.dark`・`takeaway-strip` の帯背景は `var(--accent)` を使う（`var(--ink)` 固定にしない）。Navy なら紺帯、Forest なら深緑帯になり、テーマを選んだのに帯だけ黒く浮く「モノトーン見え」を防ぐ。Mono テーマは accent≈ink のため従来どおり黒帯になる
- **accent 帯上の小ラベル・箇条書きマーカーは `rgba(255,255,255,0.78)`**（`--accent-soft` は同系色のため帯上ではコントラスト不足）。本文は `#fff`
- **`--accent-soft` はダーク背景上でのみ使う**（サムネイルパネル等）。クリーム背景上では `--accent-soft` ではなく通常の `--accent` を使う
- **`--good` / `--warn` は意味のある対比のみで使う**（例：「適した進め方 vs 避けるべき進め方」）。装飾目的では使わない
- **CSS変数は必ず `:root` で定義し、ハードコードしない**

## 代替カラーテーマ

デフォルトは Mono。Vertical Document / Slide Deck format いずれも既定はこの 1 つ。他 5 テーマ（Terracotta / Navy / Forest / Charcoal / EightHundred）は色味を変えたい場合の任意の代替パレット。**変更時は `:root` 内の `--accent` / `--accent-soft` / `--accent-bg` の3変数のみを置き換える**（Mono との入れ替えは `--bg` / `--ink` / `--rule` 等の構造色も異なるため対象外。詳細は Theme 5 参照）。それ以外の色は触らない。**唯一の例外は Theme 6: EightHundred**（クライアントブランド固有テーマ）で、3変数に加えて `--font-jp` も置き換える（詳細は Theme 6 参照）。

### Theme 1: Terracotta（warm consulting）

```css
--accent: #9d3617;
--accent-soft: #c45a2c;
--accent-bg: #f5e8de;
```

コンサル系の温かみのある印象。

### Theme 2: Navy（formal corporate）

```css
--accent: #1e3a5f;
--accent-soft: #3a5e8a;
--accent-bg: #e3eaf3;
```

冷静で信頼感のある印象。

### Theme 3: Forest（academic / sustainability）

```css
--accent: #2a4f3a;
--accent-soft: #4a7558;
--accent-bg: #e2ebe1;
```

落ち着いた知的な印象。

### Theme 4: Charcoal（minimal / modernist）

```css
--accent: #2d2d33;
--accent-soft: #5a5a64;
--accent-bg: #ebe9e4;
```

ニュートラルでアクセントを目立たせない印象。

### Theme 5: Mono（デフォルト・Vertical Document 用ブロック）

```css
--bg: #ffffff;            /* 純白（紙質クリームではなく純白） */
--bg-alt: #f5f5f5;        /* カード薄背景 */
--panel: #ffffff;
--ink: #1a1a1a;           /* 純黒に近い */
--ink-soft: #444444;
--ink-mute: #777777;
--rule: #d0d0d0;
--rule-soft: #e0e0e0;
--accent: #1a1a1a;        /* アクセントを ink と同色に → 実質モノクロ */
--accent-soft: #444444;
--accent-bg: #ededed;     /* accent の淡ティント（文字を載せる面。下記の契約） */
```

黒帯反転・巨大数字・大きい余白で構造を見せるスタイル。

**Mono テーマの追加ルール**：
- 紙質クリームではなく純白背景を使う（コンサル提案書らしい清潔感）
- フォントは他テーマと同じ Noto Sans JP（Meiryo・Noto Serif JP は使わない）。「コンサル提案書らしさ」は構成・余白・拡張コンポーネント（22〜25）で出す

**Slide Deck では扱いが違う**：Slide Deck では 6 テーマ共通の統一シャシを使い、Mono を含む 6 テーマは `--accent` 系 3 変数（EightHundred のみ `--font-jp` も追加）で palette 切替される。上記の Mono ブロックは **Vertical Document で使う場合の定義**。Slide Deck の統一シャシは `slide-deck.md`「テーマ切替」を参照。

### Theme 6: EightHundred（クライアントブランド固有）

```css
--accent: #1B3928;
--accent-soft: #127D70;
--accent-bg: #E4E7E5;
```

クライアント企業（株式会社エイトハンドレッド）のPPTXブランドテーマ（`accent1`/`accent2`）に準拠した固有パレット。深いダークグリーンに、ティール系グリーンを添える2色構成。

**EightHundred テーマの追加ルール**：
- **フォント例外**：本文・見出しに他 5 テーマと異なり **Meiryo UI** を使う。`--font-jp: "Meiryo UI","Meiryo","Hiragino Kaku Gothic ProN","Noto Sans JP",sans-serif;` を `:root` で上書きする（タイポグラフィ節「フォント読み込み」参照）。数値・章番号・コードは他テーマと同じ `JetBrains Mono` のまま変更しない
- Meiryo UI は Windows 標準搭載フォントで Google Fonts 提供が無いため、Web フォント読み込みの追加は不要（フォールバックチェーンで自然に代替表示される。Windows 以外の環境では Noto Sans JP 等にフォールバックする）
- **`--accent-soft` の例外**：他 5 テーマは `--accent` の淡ティント（同一色相の明るい色）を使うが、EightHundred はブランド定義の第2アクセント `#127D70`（ティール系グリーン）をそのまま採用する。色相は近縁（共にグリーン系）のため「アクセントは1色」の趣旨（複数系統の色を混在させない）を大きく損なわない
- 1 ドキュメント内でこのテーマを使う場合も、他テーマ同様「1 ドキュメント 1 テーマ」を守る

#### EightHundred のフレーム仕様（Slide Deck format 専用）

**他 5 テーマは配色（`--accent` 系 3 変数）と `--font-jp` だけが差分**で、Cover・title-bar・footer の構造とルック（背景・罫線・ロゴの有無）は 6 テーマ共通の統一シャシのまま変わらない。**EightHundred のみ、実際のクライアント PPTX（フタバロジコム向けディスカッション資料 等）のマスターに合わせてフレームのルックも上書きする**唯一の例外テーマ。上書きは以下の追加トークン＋アセットで完結し、`assets/template-slides.html` の構造（HTML）自体は変更しない。

**フレーム用トークン**（`template-slides.html` の `:root` に定義済み。他 5 テーマは既存トークンのエイリアスのため無変化）：

```css
--cover-bg: var(--bg);                                  /* Cover の背景 */
--cover-ink: var(--ink);                                /* Cover の主テキスト色 */
--cover-ink-soft: var(--ink-soft);                      /* Cover の副テキスト色 */
--cover-rule: var(--rule);                              /* Cover meta の罫線色 */
--titlebar-border-color: var(--ink);                    /* title-bar 下罫線の色 */
--titlebar-border-width: 2px;                           /* title-bar 下罫線の太さ */
--titlebar-eyebrow-font: "JetBrains Mono", monospace;   /* title-bar .sec-num のフォント */
--titlebar-eyebrow-color: var(--accent);                /* title-bar .sec-num の文字色 */
--titlebar-direction: row;                              /* sec-num と h2 の並び：row=横並び／column=縦積み */
--titlebar-gap: 18px;                                   /* row 時の間隔（column 時は詰めた値にする） */
--titlebar-align: baseline;                             /* row 時 baseline／column 時 flex-start */
--titlebar-padding-bottom: 14px;
--titlebar-margin-bottom: 22px;
--message-margin-top: 12px;                             /* .message の title-bar からの上マージン */
--message-weight: 500;                                  /* .message の文字太さ */
--footer-id-color: var(--accent);                       /* slide-foot .doc-id の文字色 */
--footer-border-width: 1px;                             /* slide-foot 上罫線の太さ */
--footer-font: "JetBrains Mono", monospace;              /* slide-foot 全体のフォント */
```

**EightHundred 選択時はこれらを以下に上書きする**（`--accent` 系 3 変数・`--font-jp` と同じ `:root` 上書きブロックにまとめてよい）：

```css
:root{
  --accent:#1B3928;
  --accent-soft:#127D70;
  --accent-bg:#E4E7E5;
  --font-jp:"Meiryo UI","Meiryo","Hiragino Kaku Gothic ProN","Noto Sans JP",sans-serif;

  --cover-bg:#1B3928;                     /* Cover はダークグリーン全面背景（実 PPTX 準拠） */
  --cover-ink:#ffffff;
  --cover-ink-soft:rgba(255,255,255,0.78);
  --cover-rule:rgba(255,255,255,0.3);

  /* 実 PPTX はアイブロウラベル（例："弊社認識"）を見出しの真上に縦積みし、
     見出し直下に罫線を引かない。リード文（.message）も間隔を詰めて続ける。 */
  --titlebar-border-width:0;
  --titlebar-eyebrow-font:var(--font-jp);  /* .sec-num に日本語ラベルを使うため */
  --titlebar-eyebrow-color:var(--ink);     /* ラベルは accent 色にせず本文と同じ濃色にする */
  --titlebar-direction:column;
  --titlebar-gap:2px;
  --titlebar-align:flex-start;
  --titlebar-padding-bottom:0;
  --titlebar-margin-bottom:10px;
  --message-margin-top:0;
  --message-weight:700;                   /* 実 PPTX はリード文が太字 */

  --footer-id-color:var(--ink-mute);      /* コピーライト表記は accent 色にせず控えめなグレーに */
  --footer-border-width:0;                /* footer 上にも罫線を引かない */
  --footer-font:var(--font-jp);           /* 実 PPTX は Century Gothic だが Web で描画できないため本文フォントに寄せる */
}
```

**title-bar（コンテンツスライドの見出し）の使い方**：実 PPTX は章番号ではなく短い日本語ラベル（例："弊社認識"）を、見出しの真上に**縦に積んで**（横並びにしない）アイブロウとして使う。ラベル・見出し・リード文の3行は罫線を挟まず、詰めた間隔で1つの塊として続ける。`.sec-num` に数値ではなく短いラベル文字列を入れる。**リード文（`.message`）は太字**（`--message-weight:700`）にする。

```html
<div class="title-bar">
  <span class="sec-num">弊社認識</span>
  <h2>背景と目的</h2>
</div>
<p class="message">ベテラン人材のノウハウを資産化し、持続可能な倉庫オペレーションを実現する。</p>
```

**footer（コピーライト・ページ番号）の使い方**：`.doc-id` の中身をドキュメント管理番号ではなく `© Eight Hundred, Inc.` にし、ページ番号は総数を付けず単独表記にする。footer 上部にも罫線を引かない（実 PPTX 準拠）。実 PPTX のフッターフォントは Century Gothic だが、Web フォントとして配布されておらず HTML では描画できないため、`--footer-font` は `var(--font-jp)`（本文と同じ Meiryo UI 系）に寄せる（他 5 テーマの `JetBrains Mono` から変更する）。

```html
<div class="slide-foot">
  <span class="doc-id">© Eight Hundred, Inc.</span>
  <span class="pg"><b>12</b></span>
</div>
```

**ロゴマーク（`.eh-logo` / `.eh-logo-badge`）**：実 PPTX の砦（とりで）アイコンを再現したインライン SVG。CSS は `template-slides.html`「EIGHTHUNDRED LOGO MARK」に定義済み。

```html
<!-- 共通の SVG 本体（両パターンで使い回す） -->
<svg viewBox="0 0 116 100" fill="currentColor">
  <path fill-rule="evenodd" clip-rule="evenodd" d="M8,32 L8,8 L32,8 L32,32 L46,32 L46,8 L70,8 L70,32 L84,32 L84,8 L108,8 L108,32 L108,100 L8,100 Z M41,100 L41,54 A17,17 0 0 1 75,54 L75,100 Z"/>
</svg>
```

- **単体マーク**（`.eh-logo`）：見出し＋太い短尺アクセントバー＋ロゴ配置の「参照系」スライド（会社概要・経営メンバー・お取引実績・メンバー紹介 等、`SLIDE-PATTERN-attribute-rows-profile` / `profile-*` / `logo-grid` 系パターンを使うスライド）の右上に絶対配置する。`<section class="slide">` 直下に `<div class="eh-logo" aria-hidden="true">{svg}</div>` を置く（`.eh-logo` が `position:absolute` を持つため、`.slide` 自身が `position:relative` 相当であることを前提とする。`.slide` は既に `position:absolute` なので子要素の絶対配置は正しく機能する）
- **バッジ付きマーク**（`.eh-logo-badge`）：Cover・Summary（クロージング）で「800」のブランド表記として使う。白背景の小さなバッジにロゴ＋"800"の文字を組み合わせる：
  ```html
  <div class="eh-logo-badge">
    <span class="eh-logo">{svg}</span>
    <span class="eh-logo-text">800</span>
  </div>
  ```
- 通常の Content スライド（`.title-bar` + `.message` + 本文コンポーネントの一般形）にはロゴを付けない（実 PPTX でも「弊社認識」のような分析系スライドにはロゴが出ない。会社紹介・実績紹介の一部の「参照系」スライドのみに付く）

**Vertical Document には適用しない**：上記フレーム上書き（Cover 全面ダークグリーン化・ロゴマーク）は Slide Deck format 専用。Vertical Document で EightHundred テーマを使う場合は `--accent` / `--accent-soft` / `--accent-bg` / `--font-jp` の 4 トークンのみが反映され、Cover 等の構造は他テーマと同じ白／クリーム背景のままでよい（縦長文書は PPTX のスライド 1 枚と 1 対 1 対応しないため、フレーム忠実再現の対象外とする）。

## `--accent-bg` の契約（背景と文字色を衝突させない）

`--accent-bg` は **「文字を載せるアクセント面」** である。6 テーマすべてで **accent の淡ティント（明るい色）** にし、`--ink`（`#1a1a1a`）と `--accent` を載せて 4.5:1 以上を保つ。

| テーマ | `--accent` | `--accent-bg` |
|---|---|---|
| Mono | `#1a1a1a` | `#ededed` |
| Terracotta | `#9d3617` | `#f5e8de` |
| Navy | `#1e3a5f` | `#e3eaf3` |
| Forest | `#2a4f3a` | `#e2ebe1` |
| Charcoal | `#2d2d33` | `#ebe9e4` |
| EightHundred | `#1B3928` | `#E4E7E5` |

**`--accent-bg` に `--accent` と同値や暗い色を入れてはいけない。** 入れると `--accent-bg` を背景に使う全コンポーネントが一斉に「同色の地と文字」になり、テキストが消える。対象は次の 9 ルール（両テンプレート共通）で、いずれも文字色が `--ink` または `--accent` である。

- `.insight`（`.txt` は `--ink`、`.insight-label` は `--accent`）
- 固定 8 図解の `.accent` バリアント 8 種：`.dflow-node.accent` / `.dq-cell.accent` / `.dp-layer.accent` / `.df-stage.accent` / `.dc-node.accent` / `.dorg-node.accent` / `.dl-layer.accent`（ラベル・タグ・番号がいずれも `--accent`）

**反転（白文字 on 濃地）が要る場合は `--accent-bg` を使わない。** `background: var(--accent)` ＋ `color: #fff` の組み合わせで行う。既にこの方式を採っているのは Takeaway Strip・Hero Number（`.dark`）・State Box（`.target`）・Report Table の `thead`・Value Bar・Filled-Header Card の `.phase-header` で、いずれも `--accent-bg` に依存していない。

> **背景**：かつて Mono だけ `--accent-bg: #1a1a1a` を「黒帯反転用」として持っていたが、黒帯反転を行うコンポーネントはいずれも `--accent` を使っており、`--accent-bg` の黒を必要とするものは 1 つも無かった。結果として Insight と固定 8 図解の `.accent` が Mono（＝既定テーマ）で判読不能になっていた。2026-07 に契約を明文化し、Mono の値を淡ティントへ修正した。

### テーマ選定のガイドライン

**既定は Mono**。Vertical Document / Slide Deck format のいずれも既定はこの 1 つ（参照デザイン踏襲・純白＋モノクロで安定するため）。他 5 テーマ（Terracotta / Navy / Forest / Charcoal / EightHundred）は色味を変えたい場合に選ぶ任意の代替パレット。テーマは内容・出力形式と直交した独立軸であり、用途に応じた使い分けは規定しない。**EightHundred はクライアントのブランドカラーに合わせたい場合に選ぶ**（フォントも Meiryo UI に切り替わる唯一のテーマ）。

**共通ルール**：**複数テーマを混ぜない**。1 ドキュメントで 1 テーマ

## タイポグラフィ

### フォント読み込み（必須）

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
```

**重要**: 外部 stylesheet は原則禁止だが、**Google Fonts に限り例外で許可**する。**この例外規約の正本は本ファイル**（SKILL.md の Guardrails には要約のみ置く）。例外は公開スキル `html-publish` の検証ロジック（`publish.sh` / `publish-flow.md`）と同期している（fonts.googleapis.com を含む URL のみ素通し）。文言を変更する場合は html-publish 側と必ず同期する。

### 役割分担

| 役割 | フォント | 使用場面 |
|------|---------|---------|
| **本文・見出し（すべて）** | `var(--font-jp)`（既定 `"Noto Sans JP", sans-serif`） | h1（cover-title）、h2（section-title）、h3（sub-head）、p、ul、ol、td、ボタンラベル等すべて |
| **数値・英記号・コード** | `"JetBrains Mono", monospace` | doc-id、章番号（4.1等）、eyebrow、価格、ページ番号 |

`body` のデフォルトを `var(--font-jp)` にし、見出し系も同じ変数のまま（weight だけ 600〜700 に上げる）。**Noto Serif JP / Meiryo / Inter 等の追加フォントは使わない**（旧仕様で残していた場合は外す）。

**`--font-jp` トークン（本文・見出し用フォント変数）**：`:root` で以下のように定義し、テンプレート内の本文・見出し系フォント指定は `var(--font-jp)` を参照する（ハードコードしない）。

```css
--font-jp: "Noto Sans JP", sans-serif;   /* 既定値。5テーマ共通 */
```

**唯一の例外は Theme 6: EightHundred**（上記「代替カラーテーマ」参照）で、このテーマを選んだ場合のみ以下に置き換える。

```css
--font-jp: "Meiryo UI","Meiryo","Hiragino Kaku Gothic ProN","Noto Sans JP",sans-serif;
```

`JetBrains Mono`（数値・章番号・コード用）はテーマによらず変更しない。

### サイズの目安

| 要素 | サイズ | weight | letter-spacing |
|------|--------|--------|----------------|
| cover-title (h1) | 46px | 700 | 0.01em |
| cover-sub | 20px | 400 | normal |
| section-title (h2) | 28px | 600 | 0.01em |
| sub-head (h3) | 18px | 600 | normal |
| minor-head (h4) | 14px | 700 | normal |
| 本文 p | 14px | 400 | 0.01em |
| メタテキスト | 11〜12px | 400 | 0.05〜0.2em |

### line-height

- 見出し：1.4〜1.5
- 本文：1.85〜1.95
- リスト：1.7〜1.85
- 表セル：1.7

## スペーシング

ベースの単位は **px**（rem は使わない）。報告書は印刷用途も想定するため固定値の方が扱いやすい。

| 用途 | 値 |
|------|-----|
| セクション縦パディング | 80px 上下 |
| ページ左右マージン | 56px（モバイル24px） |
| ページ最大幅 | 1180px |
| 見出し直下 | 16〜24px |
| 段落間 | 14px |
| カードのパディング | 20〜32px |
| テーブルセル | 12px 16px |

## 罫線とボーダー

- **章タイトル下**：`border-bottom: 2px solid var(--ink)` — 強い区切り
- **小見出し下**：`border-bottom: 1px solid var(--rule)` — 中程度
- **段落間**：`border-bottom: 1px dotted var(--rule)` — 弱い区切り
- **アクセント縦線**：`border-left: 3px solid var(--accent)` — minor-head, insight, lede

## 影・グラデーション

**Vertical Document では原則使わない**（報告書スタイルではフラットに保つ）。

**Slide Deck の統一シャシでの例外**：Slide Deck では 6 テーマ共通で、`--card-shadow`（`0 1px 4px rgba(0,0,0,.05)`）と `--card-shadow-lg`（`0 2px 12px rgba(0,0,0,.08)`）の 2 段階に限り、カード類（`.phase-card`, `.section`, `.expansion-area`, `.track` 等）で使用してよい。参照デザイン（AI Biz Ops Partner / VisasQ 提案書 figures）の紙面感を再現するための Slide Deck 全テーマ共通の設定で、それ以外の使い方（背景全体・大きな要素・複数レイヤーの重ね掛け）はしない。

グラデーションは Vertical / Slide 問わず一切使わない（単色のみ）。

## 印刷対応

テンプレートに以下を含める：

```css
@media print{
  body{ background: white }
  .doc-header{ position: static }   /* sticky を解除 */
  section{ page-break-inside: avoid }
  a{ color: inherit; text-decoration: none }
  details{ open: open }  /* 折りたたみを開いて出力 */
}
```

ユーザーがブラウザの「印刷」→「PDFとして保存」で資料化できるよう設計する。

## レスポンシブ・ブレークポイント

1ヶ所のみ：`@media (max-width: 920px)`

そのブレークポイントで：
- グリッドを1列化
- パディング縮小（56px → 24px）
- 章ナビ非表示
- テーブルフォント縮小

それ以上の細かい対応は不要（業務文書はデスクトップ中心の用途のため）。

### 多列グリッドの折りたたみルール

モバイル時の折りたたみは、要素の**意味的性質**で分ける。

| グリッド種別 | デスクトップ | モバイル（≤920px） | 例 |
|---|---|---|---|
| **順序・進行を示す**（Phase / Step / Stage） | 4列横並び | **必ず1列縦並び**（2x2禁止） | `.roadmap-bar`, `.roadmap-detail` |
| **独立メタデータ**（順序性なし） | 3-4列 | 2列または1列 | `.cover-meta`（4→2列OK） |
| **比較ペア**（As-Is/To-Be、案A/案B） | 2列 | 1列 | `.state-grid`, `.budget-grid` |
| **数値カード**（並列の指標） | 3列 | 1列 | `.kpi-row`, `.sum-grid` |

**核心ルール**：時系列・進行・優先順を示す要素は、画面が狭くても**2x2に崩してはならない**。Phase 1→2→3→4 の線形性は、行→列の切り替えでのみ維持する。理由は、2x2 だと「Phase 1, 2 が上段／Phase 3, 4 が下段」になり、視線が左→右→左→右と折り返してしまい、ぱっと見で順序を追えなくなるため。

## SVG / アイコン

- 全アイコンはインライン SVG。外部 CDN（Font Awesome 等）禁止
- `viewBox="0 0 24 24"`、`stroke="currentColor"`、`stroke-width="2"`、`fill="none"` 系統に統一（Lucide / Feather 互換）
- 装飾図形（フローのコネクタ等）も SVG インライン
- 記号は絵文字を使わず `●■◆＋×✓` 等のみ

## ダークモード

非対応。`prefers-color-scheme: dark` も指定しない。
理由：業務文書は印刷・スクショ共有が多く、ライト基調統一の方が安全。

## AI らしさを避ける表現

HTML 上の文言は Markdown と同様に AI らしさを排除する。生成時の置き換え対象：

| Bad | Good |
|-----|------|
| 革新的な | 新しい / 既存と異なる |
| 画期的な | これまでにない |
| 飛躍的に | 大きく |
| 〜と言えるでしょう | 〜と考えられる |
| Let's dive into | （省略 or 「では始めます」） |

## 禁止パターン（マガジン化・装飾化の排除）

| 禁止事項 | 理由 |
|---------|------|
| **巨大な装飾数字（200px超）** | 編集デザイン化する。最大46px（cover-title）まで |
| **イタリック装飾フォント（Instrument Serif等）** | 業務文書には不要 |
| **編集的なキャッチコピー** | 「〜である」「〜する」の業務文体を維持 |
| **章タイトル内の単語色分けの多用** | アクセントは控えめに、文全体で1〜2語まで |
| **アシンメトリックなレイアウト** | 整然としたグリッドのみ。グリッド破りはしない |
| **過度な空白（vh単位の大余白）** | 80px程度の標準パディングを守る |
| **背景画像・グラデーション** | 単色のみ |
| **ノイズ・テクスチャオーバーレイ** | 紙質風加工は不要 |
| **回転・斜め配置・浮遊要素** | すべて水平・垂直配置 |
| **派手なホバーアニメーション** | リンク色変更程度に留める |
| **複数のアクセント色** | アクセントは1色。区別は罫線・配置・ラベルで |
| **絵文字** | 一切使わない |

## チェックリスト（生成時）

- [ ] `<link rel="stylesheet">` は Google Fonts のみ（他の外部 CSS はゼロ）
- [ ] `<script src="https://…">` が font 系以外にない
- [ ] `font-family` は `var(--font-jp)`（既定 Noto Sans JP。EightHundred テーマのみ Meiryo UI）/ JetBrains Mono（数値・章番号・コード）。Noto Serif JP / Inter 等の追加フォントは使っていない
- [ ] 背景は `#fafaf6`（純白を使っていない）
- [ ] 本文色は `#1a1c20`（純黒を使っていない）
- [ ] アクセントは 1 色のみ（複数色を使っていない）
- [ ] `max-width: 1180px` でコンテナ幅が制限されている
- [ ] `@media print` が定義されている（sticky 解除・page-break）
- [ ] アクセシビリティ：`lang="ja"`、見出しレベルが飛んでいない、リンクテキストが意味を持つ
- [ ] 絵文字を使っていない
