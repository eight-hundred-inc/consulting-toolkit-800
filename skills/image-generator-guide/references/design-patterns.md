# Design Patterns — レイアウトパターン集

HTML+CSS によるダイアグラム生成で使用するレイアウトパターン。
実例は `Work/_fw_image_src/` にある HTML ファイルを参照。

## 共通の CSS ボイラープレート

すべてのパターンで共通する基本構造:

```html
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<style>
  @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@300;400;500;600;700&display=swap');

  * { margin: 0; padding: 0; box-sizing: border-box; }

  body {
    font-family: 'Noto Sans JP', 'Meiryo UI', sans-serif;
    background: #FFFFFF;
    display: flex;
    justify-content: center;
    align-items: flex-start;
    padding: 0;
  }

  .slide {
    width: 1440px;
    height: 810px;
    background: #FFFFFF;
    padding: 44px 52px 28px;
    position: relative;
    overflow: hidden;
  }
</style>
</head>
<body>
<div class="slide">
  <!-- コンテンツ -->
</div>
</body>
</html>
```

## 共通コンポーネント

### ヘッダー（タイトル + サブタイトル）

```css
.title {
  font-size: 28px;
  font-weight: 700;
  color: #1B3928;
  letter-spacing: 0.03em;
  margin-bottom: 4px;
}

.subtitle {
  font-size: 15px;
  font-weight: 400;
  color: #6B7B73;
  margin-bottom: 26px;
}
```

### バッジ（ステップ番号やカテゴリラベル）

```css
.badge {
  font-size: 12px;
  font-weight: 700;
  color: #FFF;
  background: #1B3928;
  padding: 2px 14px;
  border-radius: 10px;
  letter-spacing: 0.04em;
  display: inline-block;
}
```

### 角丸ボーダーカード

```css
.card {
  background: #FFFFFF;
  border: 1px solid #C2D4C9;
  border-radius: 7px;
  padding: 12px 14px;
}
```

---

## パターン 1: スイムレーン型

複数の横レーンが並走し、縦軸にフェーズが並ぶ構造。プログラム全体設計やプロジェクト計画に適する。

**実例**: `Work/_fw_image_src/program_structure.html`

### 構造

```
[レーンラベル] [基盤ブロック] → [フェーズ1][フェーズ2][フェーズ3] → [ゴール]
                                   ┌─ トレーニング行 ─┐
                                   │  コネクタ行      │
                                   └─ 実践行 ────────┘
```

### CSS スケルトン

```css
.main {
  display: flex;
  align-items: stretch;
  height: 530px;
  gap: 0;
}

/* 左端のレーンラベル列 */
.lane-labels {
  width: 120px;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  padding-top: 58px; /* フェーズヘッダーの高さ分 */
}

.lane-lbl {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  justify-content: center;
  padding-right: 14px;
}

/* 基盤ブロック（左端の大きなカード） */
.col-found {
  width: 145px;
  flex-shrink: 0;
  padding-top: 58px;
}

/* 矢印カラム */
.col-arrow {
  width: 24px;
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  padding-top: 58px;
}

/* フェーズ領域（メインコンテンツ、flex: 1 で残り全幅） */
.col-phases {
  flex: 1;
  display: flex;
  flex-direction: column;
}

/* フェーズヘッダー（横並び） */
.phase-headers {
  display: flex;
  gap: 8px;
  height: 58px;
  flex-shrink: 0;
}

/* フェーズヘッダー個別 */
.ph-head {
  flex: 1;
  background: #F0F5F2;
  border-radius: 5px;
  border-bottom: 2.5px solid #1B3928;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

/* ゴールカラム（右端） */
.col-goal {
  width: 142px;
  flex-shrink: 0;
  padding-top: 58px;
}
```

### 設計のポイント

- レーンラベル・基盤・矢印・ゴールは固定幅、フェーズ領域だけ `flex: 1`
- `padding-top` でフェーズヘッダーの高さ分だけ下げて水平位置を揃える
- レーンラベルの `white-space: nowrap` で意図しない改行を防ぐ
- トレーニング行と実践行の間にコネクタ行（矢印+ラベル）を挟む

---

## パターン 2: マトリクス型

行列テーブルで、行=カテゴリ、列=チャネル（または任意の軸）のクロス分析を表現する。市場マップや優先度評価に適する。

**実例**: `Work/_fw_image_src/fw_01_where_to_play.html`（Pillow版は `generate_fw_images.py` の `generate_where_to_play()`）

### 構造

```
         [チャネルA] [チャネルB] [チャネルC] ...
[カテゴリ1]  [セル]     [セル]     [セル]
[カテゴリ2]  [セル]     [セル]     [セル]
...
[凡例バー]
[数式/注記ボックス]
```

### CSS スケルトン

```css
.matrix {
  display: grid;
  grid-template-columns: 150px repeat(6, 1fr); /* カテゴリ列 + データ列 */
}

/* ヘッダーセル */
.matrix-header {
  background: #1B3928;
  color: #FFFFFF;
  font-size: 15px;
  font-weight: 700;
  padding: 12px 8px;
  text-align: center;
}

/* カテゴリラベル（行ヘッダー） */
.matrix-row-label {
  background: #F5F7F5;
  border: 1px solid #E0E0E0;
  font-size: 15px;
  font-weight: 700;
  color: #1B3928;
  padding: 16px 14px;
  display: flex;
  align-items: center;
}

/* データセル — 優先度で背景色を変える */
.cell-invest {
  background: #E8F5E9; /* 積極投資 */
  border-left: 3px solid #2E7D32;
}

.cell-maintain {
  background: #FFF8E1; /* 維持 */
  border-left: 3px solid #F9A825;
}

.cell-shrink {
  background: #F5F5F5; /* 縮小 */
  border-left: 3px solid #BDBDBD;
}

/* セル内メトリクス */
.cell-metric {
  display: flex;
  gap: 8px;
  font-size: 12px;
  line-height: 1.8;
}

.cell-metric-label { color: #888; }
.cell-metric-value { font-weight: 600; color: #444; }
```

### 設計のポイント

- CSS Grid がテーブルレイアウトに最適。flexbox でも可能だが Grid の方が列幅の制御が楽
- セルの左端にアクセントバー（3px border-left）を入れると優先度が視覚的に伝わる
- 凡例は下部に横並びで配置し、凡例ドット+ラベルのペアを並べる

---

## パターン 3: カード型

ヘッダー + 複数カラムのカードを縦に並べる。戦略方針や比較分析に適する。

**実例**: `Work/_fw_image_src/fw_02_how_to_win.html`（Pillow版は `generate_fw_images.py` の `generate_how_to_win()`）

### 構造

```
[カードA]
  ├─ ヘッダー（タイトル + タグ）
  └─ ボディ（4カラム: Product / Pack / Price / Promotion）

[カードB]
  ├─ ヘッダー
  └─ ボディ
...
```

### CSS スケルトン

```css
.cards-container {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.focus-card {
  border: 1px solid #D5E0D5;
  border-radius: 8px;
  overflow: hidden;
}

.focus-card-header {
  background: #1B3928;
  color: #FFFFFF;
  padding: 12px 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.focus-card-header h3 {
  font-size: 15px;
  font-weight: 700;
}

.focus-card-body {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 0;
}

.mix-column {
  padding: 14px 16px;
  border-right: 1px solid #E0E0E0;
}

.mix-column:last-child {
  border-right: none;
}

.mix-column-label {
  font-size: 12px;
  font-weight: 700;
  color: #1B3928;
  margin-bottom: 8px;
  padding-bottom: 6px;
  border-bottom: 2px solid; /* カラムごとに色を変える */
}

.mix-item {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  margin-bottom: 10px;
}

.mix-bullet {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: #CCC;
  flex-shrink: 0;
  margin-top: 6px;
}

.mix-text {
  font-size: 13px;
  color: #444;
  line-height: 1.6;
}
```

### 設計のポイント

- カラムの区切り線色を変えて 4P を視覚的に区別する（Product=緑, Pack=青, Price=橙, Promotion=紫）
- カードヘッダーはダーク背景 + 白文字で視認性を確保
- ボディは CSS Grid の `repeat(4, 1fr)` で均等4分割

---

## パターン 4: ステップフロー型

横並びのステップカードを矢印で接続する。プロセスフローや手順説明に適する。

**実例**: `generate_fw_images.py` の `generate_cell_filling()`

### 構造

```
[STEP 1] → [STEP 2] → [STEP 3] → [STEP 4]
   │           │           │           │
   ├ 項目1     ├ 項目1     ├ 項目1     ├ 項目1
   ├ 項目2     ├ 項目2     ├ 項目2     ├ 項目2
   └ 項目3     └ 項目3     └ 項目3     └ 項目3
   ─────       ─────       ─────       ─────
   [出典]       [出典]      [出典]      [出典]
```

### CSS スケルトン

```css
.steps-container {
  display: flex;
  gap: 12px;
  align-items: stretch;
}

.step-card {
  flex: 1;
  border: 1px solid #D5E0D5;
  border-radius: 8px;
  padding: 20px;
  display: flex;
  flex-direction: column;
  position: relative;
}

.step-badge {
  display: inline-block;
  font-size: 11px;
  font-weight: 700;
  color: #FFF;
  padding: 3px 14px;
  border-radius: 4px;
  margin-bottom: 12px;
  /* 背景色はステップごとに変える */
}

.step-title {
  font-size: 18px;
  font-weight: 700;
  color: #1B3928;
  margin-bottom: 14px;
}

.step-divider {
  height: 3px;
  border-radius: 2px;
  margin-bottom: 14px;
  /* 背景色はステップごとに変える */
}

.step-items {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.step-item {
  display: flex;
  align-items: flex-start;
  gap: 8px;
}

.step-bullet {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  flex-shrink: 0;
  margin-top: 7px;
}

.step-text {
  font-size: 13px;
  color: #444;
  line-height: 1.6;
}

/* ステップ間の矢印（CSS疑似要素） */
.step-arrow {
  width: 24px;
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: center;
}

.step-arrow::after {
  content: '▶';
  color: #CCC;
  font-size: 14px;
}

/* フッター（出典情報） */
.step-source {
  margin-top: auto;
  padding-top: 12px;
  border-top: 1px solid #E0E0E0;
  font-size: 11px;
  color: #999;
}
```

### 設計のポイント

- 各ステップカードは `flex: 1` で均等幅
- ステップ間に矢印要素（固定幅 24px）を挟む。SVG の `>` 記号が最もきれい
- ステップごとにアクセントカラーを変える（バッジ、仕切り線、ビュレットの色）
- `margin-top: auto` でフッターをカード下端に固定する

---

## パターン 5: タイムライン/ロードマップ型（SVG）

横軸に時間（クォーター等）、縦軸にチーム/レーンを配置し、施策バーとマイルストーンで進行計画を表現する。ロードマップ、ガントチャート、プロジェクト計画に適する。HTML+CSS ではなく SVG で実装する。

**実例**: `output/roadmap-output-image.svg`

### 構造

```
[上段: 分析フレームワーク]
  [STEP 1] → [STEP 2] → [STEP 3] → [最終アウトプット]

[下段: クォーター別ロードマップ]
         Q1        Q2        Q3        Q4
  MS   ◆ 3万h    ◆ 7万h   ◆ 12万h  ◆ 15万h
  T1   ███ QW ···→ ██████ 長期     ███ 横展開
  T2   ███ QW ···→ ██████ 長期     ███ 横展開
  T3   ███ QW ···→ ██████ 長期     ███ 横展開
  現場  ─── ─── ─── ─── ─── ─── ─── ─── ───
  [凡例]
```

### SVG ボイラープレート

```xml
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg"
     viewBox="0 0 1200 820"
     font-family="'Helvetica Neue', Arial, sans-serif"
     width="1200" height="820">
  <defs>
    <!-- グラデーション（ヘッダー等） -->
    <linearGradient id="headerGrad" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" style="stop-color:#1B3928"/>
      <stop offset="100%" style="stop-color:#2D5A3F"/>
    </linearGradient>

    <!-- ドロップシャドウ -->
    <filter id="shadow" x="-2%" y="-2%" width="104%" height="108%">
      <feDropShadow dx="0" dy="2" stdDeviation="3" flood-opacity="0.1"/>
    </filter>

    <!-- 矢印マーカー -->
    <marker id="arrowGray" viewBox="0 0 10 10"
            refX="10" refY="5" markerWidth="8" markerHeight="8" orient="auto">
      <path d="M 0 0 L 10 5 L 0 10 z" fill="#90A4AE"/>
    </marker>
    <marker id="arrowGreen" viewBox="0 0 10 10"
            refX="10" refY="5" markerWidth="8" markerHeight="8" orient="auto">
      <path d="M 0 0 L 10 5 L 0 10 z" fill="#1B3928"/>
    </marker>
  </defs>

  <!-- 背景 -->
  <rect width="1200" height="820" fill="#FAFBFC" rx="8"/>

  <!-- ヘッダーバー -->
  <rect x="0" y="0" width="1200" height="56" fill="url(#headerGrad)" rx="8"/>
  <rect x="0" y="28" width="1200" height="28" fill="url(#headerGrad)"/>
  <text x="40" y="36" fill="#fff" font-size="18" font-weight="600">
    <!-- タイトル -->
  </text>

  <!-- コンテンツ領域 -->
</svg>
```

### コンポーネント別スケルトン

**ステップカード（上段の分析フレームワーク）**

```xml
<g filter="url(#shadow)">
  <!-- カード背景 -->
  <rect x="40" y="116" width="220" height="140" rx="8"
        fill="#fff" stroke="#E0E0E0" stroke-width="1"/>
  <!-- カードヘッダー -->
  <rect x="40" y="116" width="220" height="36" rx="8" fill="#1B3928"/>
  <rect x="40" y="140" width="220" height="12" fill="#1B3928"/>
  <text x="150" y="140" fill="#fff" font-size="12" font-weight="600"
        text-anchor="middle">STEP 1</text>
  <!-- カード本文 -->
  <text x="56" y="172" fill="#546E7A" font-size="11">説明テキスト</text>
</g>

<!-- カード間の矢印 -->
<line x1="268" y1="186" x2="318" y2="186"
      stroke="#90A4AE" stroke-width="2" marker-end="url(#arrowGray)"/>
```

**クォーターヘッダー（タイムライン列見出し）**

```xml
<!-- 左ラベル列 120px + クォーター列 250px x 4 = 合計 1120px -->
<rect x="160" y="330" width="250" height="36" fill="#1B3928"/>
<text x="285" y="354" fill="#fff" font-size="13" font-weight="600"
      text-anchor="middle">Q1</text>

<rect x="410" y="330" width="250" height="36" fill="#2D5A3F"/>
<text x="535" y="354" fill="#fff" font-size="13" font-weight="600"
      text-anchor="middle">Q2</text>
<!-- Q3, Q4 も同様。色を段階的に明るくする -->
```

**マイルストーンマーカー（菱形）**

```xml
<g transform="translate(400, 380)">
  <polygon points="0,-12 12,0 0,12 -12,0" fill="#1B3928"/>
  <text x="0" y="26" fill="#1B3928" font-size="10" font-weight="700"
        text-anchor="middle">3万h</text>
</g>
```

**施策バー（ガントチャート行）**

```xml
<!-- Quick Win バー（緑系） -->
<rect x="170" y="436" width="220" height="28" rx="6"
      fill="#66BB6A" opacity="0.85"/>
<text x="180" y="455" fill="#fff" font-size="10" font-weight="600">
  QW: 施策名
</text>

<!-- QW → 長期施策の接続線（破線カーブ） -->
<path d="M 390 450 C 420 450, 420 465, 450 465"
      stroke="#1B3928" stroke-width="1.5" fill="none"
      stroke-dasharray="4,3" marker-end="url(#arrowGreen)"/>

<!-- 長期施策バー（青系） -->
<rect x="460" y="448" width="280" height="28" rx="6"
      fill="#42A5F5" opacity="0.75"/>
<text x="470" y="467" fill="#fff" font-size="10" font-weight="600">
  長期: 施策名
</text>

<!-- 横展開バー（青系・薄） -->
<rect x="750" y="448" width="200" height="28" rx="6"
      fill="#42A5F5" opacity="0.5"/>
```

**レーンラベル（左端のチーム名）**

```xml
<rect x="40" y="424" width="120" height="90" fill="#F3E5F5" opacity="0.3"/>
<text x="100" y="456" fill="#7B1FA2" font-size="12" font-weight="700"
      text-anchor="middle">Team 1</text>
<text x="100" y="472" fill="#9C27B0" font-size="9"
      text-anchor="middle">取り組みA</text>
```

**凡例（フッター）**

```xml
<g transform="translate(50, 778)">
  <rect width="14" height="14" rx="3" fill="#66BB6A" opacity="0.85"/>
  <text x="20" y="12" fill="#546E7A" font-size="10">Quick Win</text>

  <rect x="170" width="14" height="14" rx="3" fill="#42A5F5" opacity="0.75"/>
  <text x="190" y="12" fill="#546E7A" font-size="10">長期取り組み</text>

  <!-- 以下同様に凡例アイテムを横並びで配置 -->
</g>
```

### 座標設計の目安

| 領域 | Y 座標 | 高さ |
|------|--------|------|
| ヘッダーバー | 0 | 56px |
| 上段（フレームワーク） | 92-260 | 約 170px |
| 下段セクション見出し | 290-310 | 20px |
| タイムライン外枠 | 330 | 460px |
| クォーターヘッダー | 330-366 | 36px |
| マイルストーン行 | 370-420 | 50px |
| チーム行（各） | 90px 間隔 | 90px |
| 現場対応行 | 最下段 | 50px |
| 凡例 | 778 | 20px |

| 領域 | X 座標 | 幅 |
|------|--------|-----|
| レーンラベル | 40 | 120px |
| Q1 | 160 | 250px |
| Q2 | 410 | 250px |
| Q3 | 660 | 250px |
| Q4 | 910 | 250px |

### 設計のポイント

- 上段と下段を明確に分ける。上段は分析フレームワーク（STEP 1→2→3→Output）、下段はクォーター別のガントチャート
- クォーターヘッダーの色は左から右へ段階的に明るくし、時間の進行を視覚化する
- Quick Win バー（緑）→ 長期施策バー（青）の接続を破線カーブ＋矢印で表現し、短期成果が長期施策に接続するストーリーを伝える
- マイルストーンは菱形（`<polygon>` の4点）で描画する。最終目標は色を変えて強調する
- レーン間は破線の区切り線で分ける。`stroke-dasharray="4,4"` を使う
- 現場対応レーンは別色（オレンジ系）で破線バーとし、他チームと性質が異なることを示す

---

## カラーパレット参考値

ブランドカラーの指定がない場合のデフォルト:

| 用途 | カラー | Hex |
|------|--------|-----|
| プライマリ（テキスト・バッジ） | ダークグリーン | #1B3928 |
| プライマリ背景（薄） | ライトグリーン | #F0F5F2 |
| カード背景（トレーニング系） | グリーングラデ | #F4F8F5 → #EDF3EE |
| カード背景（実践系） | イエローグラデ | #FDFAF0 → #FBF5E2 |
| ボーダー | グリーンボーダー | #C2D4C9 |
| サブテキスト | グレー | #6B7B73 |
| 積極投資セル背景 | ライトグリーン | #E8F5E9 |
| 維持セル背景 | ライトイエロー | #FFF8E1 |
| 縮小セル背景 | ライトグレー | #F5F5F5 |
| アクセント: 緑 | グリーン | #2E7D32 |
| アクセント: 青 | ブルー | #1565C0 |
| アクセント: 橙 | オレンジ | #E65100 |
| アクセント: 紫 | パープル | #6A1B9A |
