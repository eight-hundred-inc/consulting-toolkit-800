# build.py 実装ガイド（deck_kit API）

`scripts/deck_kit.py` は python-pptx の薄いラッパ。**参照デッキをテンプレートとして開き、
既存スライドだけを捨てる**ことで、テーマ配色・フォントスキーム・スライドマスター・
レイアウト・スライドサイズ・マスター上のロゴ／フッタ／ページ番号を無傷で引き継ぐ。
色やフォントを自前で定義し直すのではなく、**テンプレートから継承させるのが原則**。

---

## 1. 骨格

```python
import sys; sys.path.insert(0, "<skill>/scripts")
from deck_kit import *

st  = load_style("deck-spec.json")          # 抽出済みの配色・フォント・レイアウト名
prs = open_template("<skill>/reference-decks/base.pptx")   # 既存スライドは削除済み
W, H = st.canvas                            # 例: (13.333, 7.5)

s = add_slide(prs, "1_本文")                # レイアウト名は部分一致で可
set_placeholder(s, "TITLE", "見出し")        # 書式はレイアウトから継承される
drop_empty_placeholders(s)                  # 未使用プレースホルダを消す（必須）

save(prs, "output.pptx")
```

`load_style()` が返す `Style` の中身:

| 属性 | 内容 |
|---|---|
| `st.canvas` | `(幅, 高さ)` インチ |
| `st.latin` / `st.ea` | テーマの欧文／日本語フォント名 |
| `st.theme_colors` | `{"accent1": "1B3928", "dk1": ..., ...}` |
| `st.used_colors` | 参照デッキで実際に使われていた色（頻度順） |
| `st.layouts` | レイアウト名のリスト |
| `st.sizes` | 実使用フォントサイズ（頻度順） |

---

## 2. API 一覧

### デッキ
| 関数 | 用途 |
|---|---|
| `open_template(path, keep_slides=False)` | 参照 pptx をテンプレートとして開く |
| `new_from_scratch(w, h)` | 参照デッキが無いときの退避用 |
| `list_layouts(prs)` / `layout_by_name(prs, name)` | レイアウト取得（完全一致→部分一致→index） |
| `add_slide(prs, layout)` | スライド追加 |
| `save(prs, path)` | 保存 |

### プレースホルダ
| 関数 | 用途 |
|---|---|
| `set_placeholder(slide, key, text, size=…, bold=…, color=…)` | `key` は `idx`(int) か型名の部分文字列（`"TITLE"`, `"CENTER_TITLE"`, `"SUBTITLE"`, `"BODY"`） |
| `drop_empty_placeholders(slide)` | 空プレースホルダを削除。**全スライドで必ず呼ぶ** |
| `set_slide_background(slide, color)` | 背景色の上書き |

書式引数を省略すればレイアウト／マスターの継承書式がそのまま効く。**極力省略する**。

### テキスト
```python
add_text(slide, text, x, y, w, h, *, size=14, bold=None, color="404040",
         align="l"|"c"|"r"|"j", anchor="t"|"m"|"b", latin=…, ea=…,
         line_spacing=None, space_after=0, margin=0.0, shrink=False)
```
- `text` は文字列、または run 単位の dict リスト。部分強調はこちら:
  ```python
  add_text(s, [{"text": "判断業務のデジタル化", "bold": True, "color": st.theme_colors["accent1"]},
               {"text": "が効率化の鍵を握る"}], 0.37, 0.95, 12.6, 0.35, size=16)
  ```
- `"\n"` で段落が分かれる。dict に `size`/`bold`/`color`/`align`/`space_after` を個別指定可。
- `shrink=True` で枠に収まるサイズへ自動縮小（`fit_size()` の概算）。

```python
add_bullets(slide, items, x, y, w, h, *, size=14, bullet_char="・", indent_in=0.22,
            line_spacing=1.3, space_after=4)
```
`items` は `"文字列"` / `(level, "文字列")` / `{"text":…, "level":…, "bullet":"－", "bold":True}`。
PowerPoint の自動 bullet ではなく**行頭文字を直接置く**方式（日本語で崩れにくい）。

### 図形・表
```python
add_rect(slide, x, y, w, h, *, fill=None, line=None, line_w=0.75,
         shape=MSO_SHAPE.ROUNDED_RECTANGLE, text=…, size=12, align="c", anchor="m")
add_line(slide, x1, y1, x2, y2, *, color="D0D0D0", width=0.75)
add_table(slide, data, x, y, w, h, *, col_widths=[…], header=True,
          header_fill=…, header_color="FFFFFF", band_fill=None, border_color="D9D9D9", size=11)
add_picture(slide, path, x, y, w=None, h=None)
```
- `add_rect` は影を**構造的に**落とす（`no_shadow()` を内部で呼ぶ）。`shadow=True` は `ValueError`。
- `add_table` は `data[0]` をヘッダ行として扱い、PowerPoint 既定の青い表スタイルを外して
  `No Style, Table Grid` に固定する。

### 採寸ユーティリティ
| 関数 | 用途 |
|---|---|
| `text_width_em(text)` | 全角=1.0em / 半角=0.55em で概算幅 |
| `fit_size(text, w_in, h_in, base_pt, min_pt=8)` | 枠に収まる最大サイズの概算 |
| `rgb("1B3928")` | `RGBColor` へ変換（`#` 有無どちらも可） |
| `no_shadow(shape)` | 影・光彩を落とす。`add_rect`／`add_line`／`add_picture` は内部で自動適用 |

---

## 3. 実装規約

| 規約 | 理由 |
|---|---|
| **座標は参照デッキの実測値を使う** | `deck-spec.md` の「反復要素」「スライド別 実測ダンプ」に x/y/w/h がインチで出ている。目分量で置かない |
| **左右マージン・本文開始 y を全スライドで統一する** | 実測値から定数（`M`, `TOP`, `BODY_W`）を 1 箇所に定義し、全スライドで使い回す |
| **色は `st.theme_colors` / `st.used_colors` から取る** | 参照デッキに無い色を持ち込まない。`404040` 等の一般値も参照側に無ければ使わない |
| **日本語は必ず `ea=` を通す** | `run.font.name` は `a:latin` しか書かないため、指定しないと日本語が欧文フォントにフォールバックする。`deck_kit` の各関数は `ea` 引数で `a:ea` を明示する |
| **プレースホルダを優先し、無い場合だけテキストボックス** | レイアウト由来の書式・位置が自動で効く |
| **`drop_empty_placeholders(slide)` を全スライドで呼ぶ** | 「クリックしてテキストを入力」が残ると提出事故になる |
| **影は禁じ手（付ける手段を持たない）** | `add_rect(shadow=True)` は `ValueError`。自前で `slide.shapes.add_shape()` を呼ぶ場合は **必ず `no_shadow(sp)` を通す**。`shape.shadow.inherit = False` だけでは不十分（下記 §5 参照） |
| **グラデーション・絵文字は使わない** | 参照デッキの様式から外れる |
| **HEX に `#` は付けなくてよい**（付けても可） | `rgb()` が両対応 |

## 4. よく使うレイアウトパターン

参照デッキから採寸した値に置き換えて使うこと（以下の数値は 13.333×7.5 デッキの例）。

```python
M, TOP = 0.37, 1.15                 # 左右マージン / 本文開始 y
BODY_W = W - M * 2
ACC = st.theme_colors["accent1"]

# キーメッセージ（タイトル直下の主張文）＋区切り線
add_text(s, msg, M, 0.90, BODY_W, 0.38, size=16, ea=st.ea, latin=st.latin)
add_line(s, M, TOP + 0.10, W - M, TOP + 0.10, color="D0D0D0", width=1.0)

# 2 カラム
half = (BODY_W - 0.30) / 2
add_bullets(s, left_items,  M,              TOP + 0.3, half, 3.2)
add_rect(s, M + half + 0.30, TOP + 0.3, half, 3.2, fill="F2F2F2",
         text=[{"text": "期待効果\n", "bold": True, "color": ACC, "size": 13},
               {"text": body, "size": 12}], align="l", anchor="t")

# 横並び 3 ステップ
n, gap = 3, 0.22
cw = (BODY_W - gap * (n - 1)) / n
for i, (head, body) in enumerate(steps):
    x = M + i * (cw + gap)
    add_rect(s, x, TOP + 0.3, cw, 0.42, fill=ACC, text=head, color="FFFFFF", size=13, bold=True)
    add_text(s, body, x, TOP + 0.82, cw, 1.6, size=12, ea=st.ea, latin=st.latin)

# 表
add_table(s, rows, M, TOP + 0.3, BODY_W, 1.2, col_widths=[2.0, 8.6, 2.0],
          header_fill=ACC, band_fill="F7F9F8", size=12)

# 出所注記
add_text(s, "出所: …", M, H - 0.62, 5.0, 0.25, size=9, color=st.theme_colors.get("dk2", "919191"))
```

---

## 5. 影を消すには 2 系統を潰す必要がある

pptx の効果指定は 2 箇所にある。**片方だけでは影が残る**。

| # | 指定箇所 | 意味 |
|---|---|---|
| 1 | `<p:spPr><a:effectLst>` | 図形に直接付いた効果 |
| 2 | `<p:style><a:effectRef idx="N">` | テーマ `effectStyleLst` の N 番を参照 |

python-pptx の `shape.shadow.inherit = False` は **1 に空要素を書くだけ**で、2 の
`effectRef` は残る。PowerPoint は空の `effectLst` を優先するので影は出ないが、
**LibreOffice 等は `effectRef` を拾って影を描く**（PNG QA で影付きに見える原因）。
`no_shadow()` は 1 を空にし、2 を `idx="0"` に倒すため、どのレンダラでも影が出ない。

`verify_deck.py` は影を検出する:

- `effectLst` 配下に影要素 → **ERROR**（禁じ手が混入している）
- `effectRef idx != 0` が残存 → **WARN**（PowerPoint では出ないが他レンダラで出る）

---

## 6. LibreOffice レンダリングの注意

`render_pptx.sh` の PNG は **LibreOffice による近似描画**。次の差分は PowerPoint では出ない:

- Meiryo UI / Century Gothic が未インストールの環境では別フォントに置換され、字幅と行数がずれる
- 太字が合成ボールドになり、実際より太く見える
- 行間・段落後アキが数 px ずれる

したがって PNG QA は**レイアウト崩れ・はみ出し・重なり・空欄の検出**に使い、
字形の細部を根拠に微調整しない。最終確認は PowerPoint で行う。
