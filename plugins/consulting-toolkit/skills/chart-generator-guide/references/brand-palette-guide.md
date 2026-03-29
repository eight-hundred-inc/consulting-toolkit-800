# ブランドパレット設定ガイド

`chart_utils.py` のカラーパレットとフォント設定をプロジェクトのブランドに合わせて差し替える手順。

## パレット構造

`chart_utils.py` は以下の色定数を持つ。すべてのチャート関数がこれらを参照する。

| 定数 | 役割 | デフォルト |
|------|------|-----------|
| `PRIMARY` | ハイライト色。メッセージの主役となる棒・線に使う | `#0052FF` |
| `GRAY` | 非強調の棒・系列 | `#B0B0B0` |
| `GRAY_LIGHT` | 第3系列、薄い背景 | `#D0D0D0` |
| `GRAY_DARK` | 濃いめの補助テキスト（任意） | `#707070` |
| `TEXT` | 本文テキスト、データラベル | `#404040` |
| `MUTED` | 軸ラベル、補足テキスト | `#595959` |
| `BORDER` | 軸線、グリッド線、区切り線 | `#D9D9D9` |
| `WHITE` | 背景、ハイライト棒内テキスト | `#FFFFFF` |

## 組み込みパレット: Blue Accent

デフォルトのパレット。レポート・プレゼン資料で汎用的に使える。

```python
PRIMARY    = "#0052FF"   # 鮮やかなブルー
GRAY       = "#B0B0B0"
GRAY_LIGHT = "#D0D0D0"
GRAY_DARK  = "#707070"
TEXT       = "#404040"
MUTED      = "#595959"
BORDER     = "#D9D9D9"
WHITE      = "#FFFFFF"
```

**設計意図**: PRIMARY のブルーだけが彩度を持ち、それ以外はグレースケール。ハイライトが1色に絞られるため、メッセージの焦点がブレない。

## 別ブランドへの差し替え

プロジェクトのブランドカラーが指定されている場合、`chart_utils.py` の先頭8行を差し替える。

### 差し替え例: Dark Green ベース

```python
PRIMARY    = "#1B3928"   # ダークグリーン
GRAY       = "#A0A0A0"
GRAY_LIGHT = "#C8C8C8"
GRAY_DARK  = "#606060"
TEXT       = "#333333"
MUTED      = "#666666"
BORDER     = "#D0D0D0"
WHITE      = "#FFFFFF"
```

### 差し替え例: Red Accent

```python
PRIMARY    = "#D32F2F"   # レッド
GRAY       = "#B0B0B0"
GRAY_LIGHT = "#D0D0D0"
GRAY_DARK  = "#707070"
TEXT       = "#404040"
MUTED      = "#595959"
BORDER     = "#D9D9D9"
WHITE      = "#FFFFFF"
```

### 差し替えルール

1. **PRIMARY のみ変更** すれば最低限のブランド適用ができる。GRAY 系は変えなくてよい場合が多い
2. TEXT / MUTED はブランド色に合わせて明度を調整する。PRIMARY が暗い場合、TEXT も暗めにする
3. BORDER はグリッド線に使う。目立ちすぎないよう `#C0C0C0`〜`#E0E0E0` の範囲で選ぶ
4. WHITE は変更しない

## フォント設定

`chart_utils.py` にはフォント関連の設定が 2 つある。

### RENDER_FONT

matplotlib がチャートを描画するときに使うシステムフォント。実行環境にインストールされている必要がある。

| OS | 推奨値 |
|----|--------|
| macOS | `"Hiragino Sans"` |
| Windows | `"Meiryo UI"` または `"Yu Gothic UI"` |
| Linux | `"Noto Sans CJK JP"` |

### SVG_FONTS

SVG ファイル内の `font-family` 属性に設定する値。納品先の環境で表示されるフォント。`save()` 関数が SVG 保存後に自動置換する。

```python
SVG_FONTS = "'Meiryo UI', 'Century Gothic'"
```

- 日本語フォント + 欧文フォントの組み合わせで指定する
- 引用符の入れ子に注意: 外側がダブルクォート、フォント名はシングルクォートで囲む
- 納品先が PowerPoint の場合、Meiryo UI / Century Gothic が安全な選択
- 納品先が Web の場合、`'Noto Sans JP', sans-serif` 等にする

### フォント置換の仕組み

`save()` 関数は以下の手順で SVG のフォントを差し替える:

1. `fig.savefig(svg)` で SVG を出力（`RENDER_FONT` で描画される）
2. SVG ファイルをテキストとして読み込む
3. `font-family:{RENDER_FONT}` → `font-family:{SVG_FONTS}` に文字列置換
4. 上書き保存

PNG はレンダリング環境のフォントがそのまま画像化されるため、置換は不要。

### 既知の制限

- matplotlib が `font-family` を出力する形式が環境によって微妙に異なる場合がある（スペースの有無等）。`save()` 関数ではスペースあり・なしの両パターンを置換している
- フォント名に日本語を使うと SVG 内で文字化けすることがある。英語名（`"Hiragino Sans"` 等）を使う
