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
  * { margin: 0; padding: 0; box-sizing: border-box; }

  body {
    font-family: 'Meiryo UI', 'Meiryo', sans-serif;
    background: #FFFFFF;
    width: 1200px;
    padding: 40px 48px;
    overflow: hidden;
  }
</style>
</head>
<body>
  <!-- コンテンツ -->
</body>
</html>
```

## 共通コンポーネント

### ヘッダー（タイトル + サブタイトル）

```css
.title {
  font-size: 21px;
  font-weight: 700;
  color: #1a1a1a;
  letter-spacing: 0.03em;
  margin-bottom: 4px;
}

.subtitle {
  font-size: 13px;
  font-weight: 400;
  color: #777;
  margin-bottom: 26px;
}
```

### バッジ（ステップ番号やカテゴリラベル）

```css
.badge {
  font-size: 11px;
  font-weight: 700;
  color: #FFF;
  background: #1a1a1a;
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
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  padding: 12px 14px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
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
  background: #f5f5f5;
  border-radius: 5px;
  border-bottom: 2.5px solid #1a1a1a;
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
  background: #1a1a1a;
  color: #FFFFFF;
  font-size: 15px;
  font-weight: 700;
  padding: 12px 8px;
  text-align: center;
}

/* カテゴリラベル（行ヘッダー） */
.matrix-row-label {
  background: #f5f5f5;
  border: 1px solid #E0E0E0;
  font-size: 15px;
  font-weight: 700;
  color: #1a1a1a;
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
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  overflow: hidden;
}

.focus-card-header {
  background: #1a1a1a;
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
  color: #1a1a1a;
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
  border: 1px solid #e0e0e0;
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
  color: #1a1a1a;
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

## パターン 5: タイムライン/ロードマップ型

横軸に時間（クォーター等）、縦軸にチーム/レーンを配置し、施策バーとマイルストーンで進行計画を表現する。ロードマップ、ガントチャート、プロジェクト計画に適する。

**実例**: `Work/assets/fig10-roadmap-timeline.html`

### 構造

```
[タイトル + サブタイトル]

[フェーズヘッダー行: Phase 1 | Phase 2 | Phase 3 | Phase 4]
[マイルストーン行:   ◆ MS1   | ◆ MS2   | ◆ MS3   | ◆ MS4  ]

[レーン1: ██ 短期施策 ···→ ██████ 長期施策     ███ 横展開]
[レーン2: ██ 短期施策 ···→ ██████ 長期施策     ███ 横展開]
[レーン3: ██ 短期施策 ···→ ██████ 長期施策     ███ 横展開]

[凡例行]
```

### CSS スケルトン

```css
/* タイムライン全体 */
.timeline {
  display: flex;
  flex-direction: column;
  gap: 0;
}

/* フェーズヘッダー行 */
.phase-headers {
  display: flex;
  gap: 2px;
  margin-left: 140px; /* レーンラベル幅 */
}

.phase-header {
  flex: 1;
  padding: 10px 16px;
  text-align: center;
  font-size: 14px;
  font-weight: 700;
  color: #fff;
  border-radius: 4px 4px 0 0;
}
/* フェーズ進行: 濃→淡 */
.phase-header:nth-child(1) { background: #1a1a1a; }
.phase-header:nth-child(2) { background: #444; }
.phase-header:nth-child(3) { background: #666; }
.phase-header:nth-child(4) { background: #888; }

/* マイルストーン行 */
.milestone-row {
  display: flex;
  margin-left: 140px;
  padding: 8px 0;
  border-bottom: 1px solid #e0e0e0;
}

.milestone {
  flex: 1;
  text-align: center;
  font-size: 11px;
  font-weight: 700;
  color: #1a1a1a;
}

.milestone::before {
  content: '◆';
  margin-right: 4px;
}

/* レーン行 */
.lane-row {
  display: flex;
  align-items: center;
  min-height: 48px;
  border-bottom: 1px dashed #e0e0e0;
}

.lane-label {
  width: 140px;
  flex-shrink: 0;
  font-size: 12px;
  font-weight: 700;
  color: #1a1a1a;
  padding-right: 12px;
  text-align: right;
}

.lane-content {
  flex: 1;
  display: flex;
  gap: 4px;
  position: relative;
}

/* 施策バー */
.bar {
  height: 28px;
  border-radius: 6px;
  display: flex;
  align-items: center;
  padding: 0 10px;
  font-size: 10px;
  font-weight: 600;
  color: #fff;
  white-space: nowrap;
}

.bar-primary { background: #1a1a1a; }
.bar-secondary { background: #666; }
.bar-tertiary { background: #aaa; }

/* 凡例 */
.legend {
  display: flex;
  gap: 20px;
  margin-top: 16px;
  margin-left: 140px;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 10px;
  color: #555;
}

.legend-dot {
  width: 12px;
  height: 12px;
  border-radius: 3px;
}
```

### 設計のポイント

- フェーズヘッダーは左から右へ色を段階的に明るくし（`#1a1a1a` → `#444` → `#666` → `#888`）、時間の進行を表現する
- レーン間は破線ボーダー（`border-bottom: 1px dashed #e0e0e0`）で区切る
- 施策バー間の接続（短期→長期など）は、HTML 内にインライン SVG を配置し `<path>` で破線カーブを描く
- マイルストーンは CSS 疑似要素（`◆`）またはインライン SVG の `<polygon>` で描画する
- `width: 1200px` のキャンバスでレーンラベル 140px + コンテンツ領域を `flex: 1` で分割する

---

## カラーパレット参考値

ブランドカラーの指定がない場合のデフォルト（モノクロマティック）:

| 用途 | カラー | Hex |
|------|--------|-----|
| プライマリ（テキスト・バッジ・ヘッダー） | ディープブラック | #1a1a1a |
| 本文テキスト | ダークグレー | #333 |
| ラベル・注釈 | ミディアムグレー | #555 |
| サブタイトル・セカンダリ | ライトミディアムグレー | #777 |
| 補助UI | グレー | #999 |
| ボーダー（濃） | ボーダー | #ccc |
| ボーダー（淡） | ライトボーダー | #e0e0e0 |
| カード背景 | ライトグレー | #f5f5f5 |
| カード背景（淡） | オフホワイト | #f8f8f8 |
| 背景 | ホワイト | #ffffff |
| シャドウ（軽） | — | rgba(0,0,0,0.06) |
| シャドウ（標準） | — | rgba(0,0,0,0.08) |
| フェーズ進行1 | ディープブラック | #1a1a1a |
| フェーズ進行2 | ダークグレー | #444 |
| フェーズ進行3 | ミディアムグレー | #666 |
| フェーズ進行4 | ライトグレー | #888 |
| 意味的: 積極投資 | ライトグリーン | #E8F5E9 |
| 意味的: 維持 | ライトイエロー | #FFF8E1 |
| 意味的: 縮小 | ライトグレー | #F5F5F5 |
