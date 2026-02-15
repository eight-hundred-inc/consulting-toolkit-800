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
