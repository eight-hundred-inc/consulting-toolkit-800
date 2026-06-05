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
  --accent-bg: #f5e8de;   /* アクセント背景（insight等） */

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
- **`--accent-soft` はダーク背景パネル上でのみ使う**（`budget-card.premium` のような部分的ダークパネル）。Summary セクションはクリーム背景に変更したため `--accent-soft` ではなく通常の `--accent` を使う
- **`--good` / `--warn` は意味のある対比のみで使う**（例：「適した進め方 vs 避けるべき進め方」）。装飾目的では使わない
- **CSS変数は必ず `:root` で定義し、ハードコードしない**

## 代替カラーテーマ

デフォルトはテラコッタ（warm consulting）。ドキュメント種別やトーンに応じて以下の代替パレットへ差し替えてよい。**変更時は `:root` 内の `--accent` / `--accent-soft` / `--accent-bg` の3変数のみを置き換える**。それ以外の色は触らない。

### Theme 1: Terracotta（デフォルト・warm consulting）

```css
--accent: #9d3617;
--accent-soft: #c45a2c;
--accent-bg: #f5e8de;
```

**向いている文書**：企画書、提案書、戦略メモ。コンサル系の温かみのある印象。

### Theme 2: Navy（formal corporate）

```css
--accent: #1e3a5f;
--accent-soft: #3a5e8a;
--accent-bg: #e3eaf3;
```

**向いている文書**：金融系・大企業向け正式文書、意思決定文書、規程・通達。冷静で信頼感のある印象。

### Theme 3: Forest（academic / sustainability）

```css
--accent: #2a4f3a;
--accent-soft: #4a7558;
--accent-bg: #e2ebe1;
```

**向いている文書**：調査レポート、学術寄りの分析、ESG・サステナビリティ系。落ち着いた知的な印象。

### Theme 4: Charcoal（minimal / modernist）

```css
--accent: #2d2d33;
--accent-soft: #5a5a64;
--accent-bg: #ebe9e4;
```

**向いている文書**：テクニカル文書、システム提案、議事メモ。ニュートラルでアクセントを目立たせない印象。

### Theme 5: Mono（consulting pitch deck）

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
--accent-bg: #1a1a1a;     /* 黒帯反転用（白文字on黒地） */
```

**向いている文書**：投資家ピッチ、コンサル提案書、McKinsey/BCG的なフォーマル提案、ハイステークス資料。黒帯反転・巨大数字・大きい余白で構造を見せるスタイル。**他テーマと違い `--accent-bg` は黒**（Eyebrow Bar・Hero Number等の黒帯反転で使う）。

**Mono テーマの追加ルール**：
- `--accent-bg` が黒（`#1a1a1a`）であるため、Insight Callout など「アクセント背景にテキスト」のコンポーネントは Mono テーマでは反転表示（白文字on黒地）になる。読みづらい場合は `.insight.flat` 等の代替バリアントで `background: var(--bg-alt)` を使う
- 紙質クリームではなく純白背景を使う（コンサル提案書らしい清潔感）
- フォントは他テーマと同じ Noto Sans JP（Meiryo・Noto Serif JP は使わない）。「コンサル提案書らしさ」は構成・余白・拡張コンポーネント（22〜25）で出す

### テーマ選定のガイドライン

- **迷ったら Terracotta（デフォルト）**
- **公的・金融・大企業向け** → Navy
- **学術・調査・ESG** → Forest
- **テクニカル・無機質** → Charcoal
- **投資家ピッチ・コンサル提案書** → **Mono**
- **複数テーマを混ぜない**。1ドキュメントで1テーマ

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
| **本文・見出し（すべて）** | `"Noto Sans JP", sans-serif` | h1（cover-title）、h2（section-title）、h3（sub-head）、p、ul、ol、td、ボタンラベル等すべて |
| **数値・英記号・コード** | `"JetBrains Mono", monospace` | doc-id、章番号（4.1等）、eyebrow、価格、ページ番号 |

`body` のデフォルトを `"Noto Sans JP"` にし、見出し系も同じ Noto Sans JP のまま（weight だけ 600〜700 に上げる）。**Noto Serif JP / Meiryo / Inter 等の追加フォントは使わない**（旧仕様で残していた場合は外す）。

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

**使わない**。報告書スタイルではフラットに保つ。

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
- [ ] `font-family` は Noto Sans JP（本文・見出しすべて）/ JetBrains Mono（数値・章番号・コード）。Noto Serif JP / Meiryo / Inter は使っていない
- [ ] 背景は `#fafaf6`（純白を使っていない）
- [ ] 本文色は `#1a1c20`（純黒を使っていない）
- [ ] アクセントは 1 色のみ（複数色を使っていない）
- [ ] `max-width: 1180px` でコンテナ幅が制限されている
- [ ] `@media print` が定義されている（sticky 解除・page-break）
- [ ] アクセシビリティ：`lang="ja"`、見出しレベルが飛んでいない、リンクテキストが意味を持つ
- [ ] 絵文字を使っていない
