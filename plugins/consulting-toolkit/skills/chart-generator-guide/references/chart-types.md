# チャートタイプ別パターン集

各パターンのテンプレートコード、使い分けの判断基準、よくある落とし穴を示す。データはサンプル。実プロジェクトのデータに差し替えて使う。

すべてのパターンは `chart_utils.py` を前提とする（`from chart_utils import *`）。

---

## 1. 横棒（単系列・先頭ハイライト）

**用途**: ランキング、度数比較、重要度スコアの順位表示

**使い分け**: カテゴリ間の大小関係を直感的に見せたいとき。先頭（最大値または最小値）を強調して「どれが突出しているか」を伝える。

```python
def chart_ranking():
    labels = ["カテゴリA", "カテゴリB", "カテゴリC", "カテゴリD", "カテゴリE"]
    values = [3.21, 3.18, 2.97, 2.82, 2.58]
    colors = [GRAY] * (len(labels) - 1) + [PRIMARY]

    fig, ax = plt.subplots(figsize=(7, 3.2))
    y = np.arange(len(labels))
    bars = ax.barh(y, values, height=0.52, color=colors, edgecolor="none", zorder=2)
    ax.set_xlim(0, max(values) * 1.15)

    for i, (bar, val) in enumerate(zip(bars, values)):
        if colors[i] == PRIMARY:
            ax.text(val - 0.03, i, f"{val:.2f}", va="center", ha="right",
                    fontsize=10.5, fontweight="bold", color=WHITE)
        else:
            ax.text(val + 0.03, i, f"{val:.2f}", va="center", ha="left",
                    fontsize=10.5, fontweight="bold", color=TEXT)

    ax.set_yticks(y)
    ax.set_yticklabels(labels, fontsize=10)
    ax.tick_params(axis="x", length=0)
    ax.tick_params(axis="y", length=0, pad=6)
    ax.set_xlabel("スコア（5段階）", fontsize=8.5, color=MUTED, labelpad=8)
    clean_spines(ax)
    add_vgrid(ax)
    ax.invert_yaxis()
    plt.tight_layout(pad=0.5)
    save(fig, "ranking")
```

**落とし穴**:
- ハイライト棒の内側テキストは `ha="right"` で棒の右端寄せにする。棒が短いと文字がはみ出すので、その場合は外側に出す
- 「その他」カテゴリは降順であっても末尾に固定する

---

## 2. 横棒（2系列オフセット）

**用途**: 2 グループ間の比較（Tier 別、前後比較、属性別）

**使い分け**: 同じカテゴリについて 2 つの視点を並べて差を見せたいとき。ギャップの大きさが伝えたいメッセージなら、差分をラベルに入れる。

```python
def chart_group_comparison():
    labels = ["項目A", "項目B", "項目C", "項目D"]
    group1 = [4.09, 3.97, 3.94, 3.40]
    group2 = [3.06, 3.03, 3.16, 2.68]

    fig, ax = plt.subplots(figsize=(7, 3.2))
    y = np.arange(len(labels))
    bar_h, offset = 0.3, 0.17

    ax.barh(y - offset, group1, height=bar_h, color=GRAY, edgecolor="none",
            label="グループ1（N=35）", zorder=2)
    ax.barh(y + offset, group2, height=bar_h, color=PRIMARY, edgecolor="none",
            label="グループ2（N=31）", zorder=2)

    for i in range(len(labels)):
        ax.text(group1[i] + 0.03, i - offset, f"{group1[i]:.2f}",
                va="center", ha="left", fontsize=8.5, color=MUTED)
        diff = group2[i] - group1[i]
        ax.text(group2[i] + 0.03, i + offset,
                f"{group2[i]:.2f}（{diff:+.2f}）",
                va="center", ha="left", fontsize=8.5, color=PRIMARY)

    ax.set_yticks(y)
    ax.set_yticklabels(labels, fontsize=9.5)
    ax.set_xlim(0, 5.0)
    ax.set_xlabel("スコア（5段階）", fontsize=8.5, color=MUTED, labelpad=8)
    ax.tick_params(axis="x", length=0)
    ax.tick_params(axis="y", length=0, pad=4)
    clean_spines(ax)
    add_vgrid(ax)
    ax.invert_yaxis()
    ax.legend(loc="upper right", bbox_to_anchor=(1.0, -0.18),
              fontsize=8.5, frameon=False, ncol=2, labelcolor=TEXT)
    plt.tight_layout(pad=0.5)
    save(fig, "group_comparison")
```

**落とし穴**:
- 凡例がデータラベルと重なりやすい。`bbox_to_anchor` でグラフ外（下部）に出す
- ギャップの大小でソートする場合はコメントに `# Sorted by gap descending` と明記する
- 凡例の系列名が曖昧にならないよう、「在籍者」「回答者」等の主語を含める

---

## 3. 横棒（積み上げ）

**用途**: 構成比の可視化、Likert 尺度（賛成〜反対）

**使い分け**: 各カテゴリの内訳を 100% や合計値で比較するとき。セグメントごとの割合が伝えたいメッセージに直結する場合に使う。

```python
def chart_stacked():
    labels = ["項目A", "項目B", "項目C", "項目D"]
    seg1 = [52, 37, 20, 11]  # 強い肯定
    seg2 = [42, 49, 70, 41]  # 肯定
    seg3 = [4,  14, 10, 41]  # 否定
    seg4 = [1,   0,  0,  7]  # 強い否定

    fig, ax = plt.subplots(figsize=(7, 2.8))
    y = np.arange(len(labels))
    bar_h = 0.5

    b1 = ax.barh(y, seg1, height=bar_h, color=PRIMARY, edgecolor="none", zorder=2)
    left1 = np.array(seg1)
    b2 = ax.barh(y, seg2, height=bar_h, left=left1, color=GRAY, edgecolor="none", zorder=2)
    left2 = left1 + np.array(seg2)
    b3 = ax.barh(y, seg3, height=bar_h, left=left2, color=GRAY_LIGHT, edgecolor="none", zorder=2)
    left3 = left2 + np.array(seg3)
    b4 = ax.barh(y, seg4, height=bar_h, left=left3, color="#E8E8E8", edgecolor="none", zorder=2)

    for i in range(len(labels)):
        if seg1[i] >= 15:
            ax.text(seg1[i] / 2, i, f"{seg1[i]}%", va="center", ha="center",
                    fontsize=8, color=WHITE, fontweight="bold")
        if seg2[i] >= 15:
            ax.text(left1[i] + seg2[i] / 2, i, f"{seg2[i]}%", va="center",
                    ha="center", fontsize=8, color=TEXT)

    ax.set_yticks(y)
    ax.set_yticklabels(labels, fontsize=9.5)
    ax.set_xlim(0, 100)
    ax.set_xlabel("回答割合（%）", fontsize=8.5, color=MUTED, labelpad=8)
    ax.xaxis.set_major_locator(ticker.MultipleLocator(25))
    ax.tick_params(axis="x", length=0)
    ax.tick_params(axis="y", length=0, pad=4)
    clean_spines(ax)
    add_vgrid(ax)
    ax.invert_yaxis()
    ax.legend([b1, b2, b3, b4],
              ["強い肯定", "肯定", "否定", "強い否定"],
              loc="upper right", bbox_to_anchor=(1.0, -0.18),
              fontsize=7.5, frameon=False, ncol=4, labelcolor=TEXT)
    plt.tight_layout(pad=0.5)
    save(fig, "stacked")
```

**落とし穴**:
- `left` の累積計算を間違えやすい。`np.array` で管理し、`left1 = seg1`, `left2 = left1 + seg2` のように積む
- セグメントが狭い（15% 未満）とき、内部にラベルを入れると読めない。狭いセグメントはラベルを省略する
- 凡例は 4 列横並び（`ncol=4`）でグラフ下部に置くと省スペース

---

## 4. 横棒（レンジ）

**用途**: 年収帯・価格帯・信頼区間の範囲表示

**使い分け**: 各項目が「点」ではなく「区間」を持つとき。自社ポジションの可視化に有効。

```python
def chart_range():
    items = [
        ("企業A",  1400, 1800, "other"),
        ("企業B",  1100, 1500, "other"),
        ("企業C",  1000, 1300, "other"),
        ("自社 PM", 900, 1300, "self"),
    ]
    items.reverse()

    fig, ax = plt.subplots(figsize=(8, 3.5))
    for i, (name, lo, hi, kind) in enumerate(items):
        color = PRIMARY if kind == "self" else GRAY_LIGHT
        h = 0.55 if kind == "self" else 0.4
        ax.barh(i, hi - lo, left=lo, height=h, color=color, edgecolor="none", zorder=2)
        ax.text(hi + 15, i, f"{lo:,}〜{hi:,}", va="center", ha="left",
                fontsize=8, color=PRIMARY if kind == "self" else TEXT)

    ax.set_yticks(range(len(items)))
    ax.set_yticklabels([it[0] for it in items], fontsize=9)
    ax.set_xlim(min(lo for _, lo, _, _ in items) * 0.9,
                max(hi for _, _, hi, _ in items) * 1.1)
    comma_fmt(ax, "x")
    ax.tick_params(axis="x", length=0)
    ax.tick_params(axis="y", length=0, pad=4)
    ax.set_xlabel("推定年収レンジ（万円）", fontsize=8.5, color=MUTED, labelpad=8)
    clean_spines(ax)
    add_vgrid(ax)
    plt.tight_layout(pad=0.5)
    save(fig, "range")
```

**落とし穴**:
- `barh(y, width, left=lo)` であって `barh(y, hi)` ではない。`width = hi - lo`
- Tier 区切り線を入れる場合は `axhline` で追加する
- 自社を他社より太い棒（`height=0.55`）にすると視線を集めやすい

---

## 5. 縦棒（複数系列）

**用途**: カテゴリ横断で 3 グループ以上を比較する

**使い分け**: 横棒 2 系列では収まらない 3 系列以上の比較。カテゴリ名が短い場合に適する（長い場合は横棒にする）。

```python
def chart_vertical_grouped():
    labels = ["カテゴリA", "カテゴリB", "カテゴリC", "カテゴリD"]
    grp1 = [54, 51, 41, 28]
    grp2 = [31, 50, 44, 12]
    grp3 = [85, 54, 62, 62]

    fig, ax = plt.subplots(figsize=(8, 4))
    x = np.arange(len(labels))
    w = 0.22

    ax.bar(x - w, grp1, width=w, color=GRAY, edgecolor="none",
           label="グループ1", zorder=2)
    ax.bar(x,     grp2, width=w, color=PRIMARY, edgecolor="none",
           label="グループ2", zorder=2)
    ax.bar(x + w, grp3, width=w, color=GRAY_LIGHT, edgecolor="none",
           label="グループ3", zorder=2)

    for i in range(len(labels)):
        ax.text(i - w, grp1[i] + 1.5, f"{grp1[i]}%", ha="center",
                fontsize=7.5, color=MUTED)
        ax.text(i,     grp2[i] + 1.5, f"{grp2[i]}%", ha="center",
                fontsize=7.5, color=PRIMARY)
        ax.text(i + w, grp3[i] + 1.5, f"{grp3[i]}%", ha="center",
                fontsize=7.5, color=MUTED)

    ax.set_xticks(x)
    ax.set_xticklabels(labels, fontsize=9)
    ax.set_ylim(0, 100)
    ax.set_ylabel("選択率（%）", fontsize=8.5, color=MUTED, labelpad=8)
    ax.tick_params(axis="x", length=0, pad=6)
    ax.tick_params(axis="y", length=0)
    clean_spines(ax, left=True)
    ax.spines["left"].set_color(BORDER)
    add_hgrid(ax)
    ax.legend(loc="upper right", fontsize=8.5, frameon=False, labelcolor=TEXT)
    plt.tight_layout(pad=0.5)
    save(fig, "vertical_grouped")
```

**落とし穴**:
- 縦棒では `clean_spines(ax, left=True)` にして左スパインを表示する
- グリッドは `add_hgrid` (横線) を使う（横棒と逆）
- カテゴリ名に改行 `\n` を入れられるが、2 行を超えると読みづらい

---

## 6. レーダー（極座標）

**用途**: 多軸プロフィール比較（満足度指標、コンピテンシー等）

**使い分け**: 4〜6 軸の多角形プロフィールを 2〜3 系列で重ねて比較するとき。7 軸以上は読みづらいので棒に切り替える。

```python
def chart_radar():
    labels = ["軸1", "軸2", "軸3", "軸4"]
    series_a = [3.90, 3.77, 3.72, 3.08]
    series_b = [3.31, 2.88, 3.12, 2.94]

    angles = np.linspace(0, 2 * np.pi, len(labels), endpoint=False).tolist()
    angles += angles[:1]
    series_a += series_a[:1]
    series_b += series_b[:1]

    fig, ax = plt.subplots(figsize=(5, 5), subplot_kw=dict(polar=True))
    ax.plot(angles, series_a, "o-", color=GRAY, linewidth=1.5, markersize=4,
            label="グループA")
    ax.fill(angles, series_a, alpha=0.05, color=GRAY)
    ax.plot(angles, series_b, "o-", color=PRIMARY, linewidth=2, markersize=5,
            label="グループB")
    ax.fill(angles, series_b, alpha=0.1, color=PRIMARY)

    ax.set_xticks(angles[:-1])
    ax.set_xticklabels(labels, fontsize=10, color=TEXT)
    ax.set_ylim(2.0, 4.5)
    ax.set_yticks([2.5, 3.0, 3.5, 4.0])
    ax.set_yticklabels(["2.5", "3.0", "3.5", "4.0"], fontsize=7.5, color=MUTED)
    ax.tick_params(pad=12)
    ax.spines["polar"].set_color(BORDER)
    ax.grid(color=BORDER, linewidth=0.5)
    ax.legend(loc="upper right", bbox_to_anchor=(1.25, 1.1), fontsize=9,
              frameon=False, labelcolor=TEXT)
    plt.tight_layout(pad=1.0)
    save(fig, "radar")
```

**落とし穴**:
- `angles` リストの末尾に `angles[:1]` を追加して多角形を閉じる。データ系列も同様
- `ylim` の下限を 0 にすると形状の差が潰れる。最小値付近に下限を設定する
- ラベルが長い場合は `\n` で 2 行にするか、省略形にする

---

## 7. 2パネル横棒

**用途**: Before/After、入社前後の重視要素変化、2 段階の評価比較

**使い分け**: 同じカテゴリセットを 2 つの異なる観点で並べて、優先順位の変化を見せるとき。

```python
def chart_two_panel():
    # 両パネルでカテゴリの並び順を揃える
    left_labels  = ["業務内容", "年収", "キャリア", "WLB", "チーム"]
    left_values  = [108, 95, 74, 47, 31]
    left_colors  = [PRIMARY, GRAY, GRAY, GRAY, GRAY]

    right_labels = ["事業成長性", "年収", "キャリア", "WLB", "チーム"]
    right_values = [182, 239, 45, 92, 91]
    right_colors = [GRAY, PRIMARY, GRAY, GRAY, GRAY]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(9, 3.5))
    bar_h = 0.5

    # 左パネル
    y1 = np.arange(len(left_labels))
    ax1.barh(y1, left_values, height=bar_h, color=left_colors,
             edgecolor="none", zorder=2)
    for i, v in enumerate(left_values):
        c = PRIMARY if left_colors[i] == PRIMARY else TEXT
        ax1.text(v + 1.5, i, str(v), va="center", ha="left",
                 fontsize=9, fontweight="bold", color=c)
    ax1.set_yticks(y1)
    ax1.set_yticklabels(left_labels, fontsize=9.5)
    ax1.set_xlim(0, max(left_values) * 1.25)
    ax1.set_xlabel("左パネルの軸ラベル", fontsize=8.5, color=MUTED, labelpad=8)
    ax1.tick_params(axis="x", length=0)
    ax1.tick_params(axis="y", length=0, pad=4)
    clean_spines(ax1)
    add_vgrid(ax1)
    ax1.invert_yaxis()

    # 右パネル
    y2 = np.arange(len(right_labels))
    ax2.barh(y2, right_values, height=bar_h, color=right_colors,
             edgecolor="none", zorder=2)
    for i, v in enumerate(right_values):
        c = PRIMARY if right_colors[i] == PRIMARY else TEXT
        ax2.text(v + 3, i, str(v), va="center", ha="left",
                 fontsize=9, fontweight="bold", color=c)
    ax2.set_yticks(y2)
    ax2.set_yticklabels(right_labels, fontsize=9.5)
    ax2.set_xlim(0, max(right_values) * 1.2)
    ax2.set_xlabel("右パネルの軸ラベル", fontsize=8.5, color=MUTED, labelpad=8)
    ax2.tick_params(axis="x", length=0)
    ax2.tick_params(axis="y", length=0, pad=4)
    clean_spines(ax2)
    add_vgrid(ax2)
    ax2.invert_yaxis()

    plt.tight_layout(pad=0.8)
    save(fig, "two_panel")
```

**落とし穴**:
- 左右でカテゴリの並び順を必ず揃える。`sharey=True` は `invert_yaxis` との相性が悪いので、独立した y 軸にして同じ順序を明示的に設定する
- ハイライト色は各パネルで異なるトップ項目に付けてよい（「入社前は業務内容が 1 位 → 検討段階では年収が 1 位」のように変化を強調）
- `xlim` は左右で独立。データレンジが大きく異なる場合でも無理に揃えなくてよい
