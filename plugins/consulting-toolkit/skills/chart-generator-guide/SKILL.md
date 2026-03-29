---
name: chart-generator-guide
description: >-
  matplotlib によるデータチャート生成ガイド。棒グラフ・レーダー・積み上げ等の
  チャートタイプ別テンプレート、ブランドパレット対応、PNG+SVG 二重出力を提供する。
  image-creator サブエージェントから読み込まれる。
---

# データチャート生成ガイド

image-creator サブエージェント向けの作業手順書。数値軸を持つデータチャートの生成に特化する。

概念図解（ファネル・レイヤー図・ペルソナカード等）は [image-generator-guide](../image-generator-guide/SKILL.md) の HTML+CSS パスを使う。

## 入出力

- **入力**: データ（インライン配列 or CSV）、チャートの種類、伝えたいメッセージ、ブランドカラー指定（任意）
- **出力**: PNG（300dpi）+ SVG（フォント置換済み）の 2 ファイル

## このスキルが適切な条件

以下のいずれかに該当する場合、このスキルを使う。

- 棒グラフ・折れ線・レーダー・散布図など、**数値軸を持つデータチャート**の作成
- サーベイ結果・統計データ・財務指標の可視化
- 軸ラベル・目盛・グリッドの精密な制御が必要
- 同じパレット・スタイルで複数のチャートを一括生成する

該当しない場合は [image-generator-guide](../image-generator-guide/SKILL.md) に戻ってルーティングをやり直す。

## ワークフロー

### Step 1: プロジェクトの準備

初回のみ、プロジェクトの出力ディレクトリに `chart_utils.py` を配置する。

1. [scripts/chart_utils_template.py](scripts/chart_utils_template.py) をプロジェクトの `figures/`（または `assets/`）にコピーする
2. ブランドカラーが指定されている場合、パレット定数を差し替える。差し替え方法は [references/brand-palette-guide.md](references/brand-palette-guide.md) を参照
3. フォント設定を環境に合わせて調整する（`RENDER_FONT` / `SVG_FONTS`）

### Step 2: データとメッセージの確認

チャートを作る前に、以下を明確にする。

- **データ**: カテゴリ名、数値、系列数
- **メッセージ**: このチャートで伝えたい主張（例: 「Tier B は WLB を最も重視している」）
- **ハイライト**: メッセージを裏付ける要素をどれにするか

メッセージが不明確なまま着手しない。「何を見せたいか」がチャートタイプと強調の設計を決める。

### Step 3: チャートタイプの選択

[references/chart-types.md](references/chart-types.md) から適切なパターンを選ぶ。

| パターン | 用途 |
|----------|------|
| 横棒（単系列・先頭ハイライト） | ランキング、度数比較 |
| 横棒（2系列オフセット） | グループ間比較 |
| 横棒（積み上げ） | 構成比、Likert 尺度 |
| 横棒（レンジ） | 年収帯・区間表示 |
| 縦棒（複数系列） | カテゴリ横断比較 |
| レーダー | 多軸プロフィール比較 |
| 2パネル横棒 | Before/After、段階比較 |

### Step 4: コード生成・実行

選んだパターンのテンプレートコードをベースに、データとメッセージに合わせてカスタマイズする。

**コード構造の標準形:**

```python
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import matplotlib.pyplot as plt
import numpy as np
from chart_utils import *

def chart_xxx():
    # 1. データ定義
    labels = [...]
    values = [...]
    colors = [PRIMARY] + [GRAY] * (len(labels) - 1)

    # 2. Figure 作成
    fig, ax = plt.subplots(figsize=(7, 3.2))

    # 3. プロット
    y = np.arange(len(labels))
    ax.barh(y, values, height=0.5, color=colors, edgecolor="none", zorder=2)

    # 4. ラベル付与
    for i, v in enumerate(values):
        ax.text(v + 0.3, i, str(v), va="center", ha="left", fontsize=9, color=TEXT)

    # 5. 軸・スタイル設定
    ax.set_yticks(y)
    ax.set_yticklabels(labels, fontsize=9.5)
    ax.set_xlim(0, max(values) * 1.2)
    ax.set_xlabel("軸ラベル", fontsize=8.5, color=MUTED, labelpad=8)
    ax.tick_params(axis="x", length=0)
    ax.tick_params(axis="y", length=0, pad=4)
    clean_spines(ax)
    add_vgrid(ax)
    ax.invert_yaxis()

    # 6. 出力
    plt.tight_layout(pad=0.5)
    save(fig, "chart_name")

if __name__ == "__main__":
    chart_xxx()
```

### Step 5: 出力確認

生成した PNG を目視で確認し、以下の品質チェックリストを通す。問題があればコードを修正して再実行する。

## スタイル規約

### 色の使い方

- **ハイライト**: メッセージの主役となる棒・系列に `PRIMARY` を使う。原則 1 チャートにつき 1 色
- **その他**: `GRAY` で統一する。グラデーションは使わない
- **ハイライト棒の内側テキスト**: 白（`WHITE`）、`fontweight="bold"`
- **通常棒のラベル**: 棒の右（横棒）または上（縦棒）に `TEXT` 色で配置

### 軸とスパイン

- `clean_spines(ax)` で上・右スパインを消す。左スパインは縦棒チャートのみ表示
- 横棒チャート: `add_vgrid(ax)` で縦のグリッド線を追加
- 縦棒チャート: `add_hgrid(ax)` で横のグリッド線を追加
- tick の長さは 0 にする（`ax.tick_params(axis="x", length=0)`）

### 目盛フォーマット

- 3 桁以上の数値には `comma_fmt(ax, "x")` でカンマ区切りを適用
- x 軸は原則 0 始まりにする（任意の値から始めない）

### 凡例

- `frameon=False`, `labelcolor=TEXT` を標準にする
- データラベルと重ならない位置に配置する。重なる場合は `bbox_to_anchor` でグラフ外に出す

### テキスト

- y 軸ラベル: `fontsize=9.5`
- x 軸説明: `fontsize=8.5, color=MUTED, labelpad=8`
- データラベル: `fontsize=9`（棒上の数値）

### 「その他」カテゴリの扱い

降順チャートで「その他」がある場合、値に関わらず末尾（最下行）に固定する。

### 比較チャートの要素順序

2 パネルや 2 系列で比較するチャートでは、カテゴリの並び順を揃える。意図的に異なる順序にする場合は、ソートの基準をコメントに明記する。

## SVG フォント置換

matplotlib はレンダリング環境のシステムフォントで描画するが、納品先の環境では別のフォントが必要な場合がある。

`chart_utils.py` の `save()` 関数がこれを自動で処理する:
1. PNG は `RENDER_FONT`（レンダリング環境のフォント）で描画
2. SVG 保存後、ファイル内の `font-family` 属性を `SVG_FONTS`（納品先のフォント）に文字列置換

設定方法の詳細は [references/brand-palette-guide.md](references/brand-palette-guide.md) のフォント設定セクションを参照。

## 品質チェックリスト

チャート生成後、以下を必ず確認する。

### レイアウト

- [ ] 凡例がデータラベルや棒と重なっていないか
- [ ] テキストがチャート枠外にはみ出していないか
- [ ] `tight_layout` で余白が適切か

### 軸・数値

- [ ] x 軸（横棒）/ y 軸（縦棒）が 0 始まりか。0 以外の場合は意図的かどうか確認
- [ ] 3 桁以上の数値にカンマ区切りが入っているか
- [ ] 縦または横のグリッド線が入っているか

### データの並び

- [ ] 降順チャートで「その他」が末尾に固定されているか
- [ ] 比較チャートのカテゴリ順序が左右・上下で一致しているか
- [ ] ハイライト色が伝えたいメッセージの要素に付いているか

### 出力

- [ ] PNG（300dpi）と SVG の両方が生成されているか
- [ ] SVG のフォントが `SVG_FONTS` に置換されているか

## ファイル整理

- チャートの PNG / SVG は `figures/` に格納する（ファイル名は `chart_xxx.png` / `.svg`）
- 複数チャートを一括生成するスクリプトは `figures/regenerate_all.py` にまとめる
- `chart_utils.py` はプロジェクト期間中変更しない前提で設計する（パレット・フォントの変更のみ許容）
