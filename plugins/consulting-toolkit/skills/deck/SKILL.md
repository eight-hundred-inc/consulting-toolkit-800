---
name: deck
description: スライド構成 MD（または素材）から、16:9 の HTML デッキと編集可能な PPTX を一気通貫で作るスキル。html-artifact を PPTX 変換セーフモードで呼んでデッキ HTML を生成し、続けて html-to-deck でテンプレート pptx の部品に組み直した PPTX へ変換する。「デッキを作って pptx にして」「構成 MD から PowerPoint まで一気に作って」「HTML と pptx を両方作って」「投影用と納品用をまとめて作って」「一気通貫でスライドを作って」などのリクエスト時に使用する。HTML デッキだけでよい場合は html-artifact、HTML が既にある場合は html-to-deck、Markdown から中間形式を挟まず pptx を作る場合は pptx-from-reference を直接使う。
---

# デッキ一気通貫（構成 MD → HTML デッキ → PPTX）

**このスキル自体は生成も変換も行わない。** 既存の 2 スキルを決められた順と設定で
つなぎ、途中で崩れが判明したときの戻り先を固定するのが役割。

| 工程 | 担当 | 出力 |
|---|---|---|
| 1. デッキ HTML の生成 | [html-artifact](../html-artifact/SKILL.md)（**PPTX 変換セーフモード必須**） | `<名前>_slides.html` |
| 2. PPTX への変換 | [html-to-deck](../html-to-deck/SKILL.md) | `output.pptx` ＋ `report.md` |

## 前提

| 前提 | 無いとき |
|---|---|
| テンプレート pptx（変換先のテーマ・マスター） | パスを尋ねる。推測で探さない |
| `slide-generator` MCP サーバーの登録 | [セットアップ手順](../../../../README.md#slide-generator見本-html--pptx-html-to-deck-利用時に必須)を案内する。登録前に工程 1 だけ進めてはいけない（後で全部やり直しになる） |
| スライド構成 MD | 無ければ [slide-structure-designer](../slide-structure-designer/SKILL.md) で先に作る |

## 入力

| 入力 | 指定方法 | 必須 |
|---|---|---|
| 構成 MD（または素材） | 引数（例: `/consulting-toolkit:deck docs/報告会.md --template ~/templates/800.pptx`） | 必須 |
| テンプレート pptx | 引数 `--template <path>` | 必須 |
| 出力先 | 引数 `--out-dir <dir>`。省略時は構成 MD と同じディレクトリの下に `deck/` を作る | 任意 |
| HTML 段階での確認 | 引数 `--review`。指定時は工程 1 の後で止まる | 任意 |
| 崩れる書き方の扱い | 引数 `--force`。変換セーフ検査の error を無視して変換する | 任意 |

## 手順

### 0. 見積もりを伝える

着手前に「HTML 生成 → 変換」の 2 段で、**変換はスライド枚数に比例して数分〜数十分**
かかることを 1 行で伝える。枚数が多い（目安 15 枚超）場合は、分割して進めるか確認する。

### 1. デッキ HTML を作る（html-artifact）

html-artifact を次の指定で呼ぶ。

- **Output Format は Slide Deck format**
- **PPTX 変換セーフモードをオン**（この後 pptx に変換するため。判定を委ねず明示する）
- **出力先は専用ディレクトリ**（`--out-dir`、省略時は `<構成MDのディレクトリ>/deck/`）

専用ディレクトリにするのは、**見本ディレクトリに `.html` が複数あると最初の 1 つしか
見本として使われない**ため。構成 MD と同じ場所に別の HTML があると取り違える。

html-artifact 側の完了条件（セーフモード時は変換セーフ検査の **error 0 件**）を
満たすまでは工程 2 へ進まない。検査が未実施なら次を回す。

```bash
cd <slide_generator>/app/core
make run_html_pptx_lint SAMPLE_DIR=<出力先ディレクトリ>
```

### 2. 確認（`--review` 指定時のみ）

デッキ HTML のパスとスライド枚数を提示し、**承認を待つ**。承認なしに工程 3 へ進まない。
指定が無ければ止まらずに進む。

### 3. PPTX へ変換する（html-to-deck）

html-to-deck を、工程 1 の出力ディレクトリとテンプレート pptx を渡して呼ぶ。
`--force` / `--rebuild` が指定されていればそのまま引き継ぐ。変換セーフ検査で
error があれば中断する（`--force` 指定時を除く）。

### 4. 結果をまとめて渡す

最終メッセージに次を含める。

1. **デッキ HTML のパス**（ブラウザで開く用）
2. **PPTX のパス**（複数スライドの場合は枚数と置き場所）
3. `report.md` から読み取った検証結果の要点を 3〜5 行（未再現の要素・座標のずれ・欄外はみ出し）

## 崩れが見つかったときの戻り先

**pptx 側では直さない。HTML に戻って直す。**

| 症状 | 戻る先 | 再開方法 |
|---|---|---|
| 一部のスライドだけ失敗した（一時的な失敗） | **戻らない** | `retry_image_slide` で失敗した枚だけ流し直す（html-to-deck の手順に従う） |
| 変換セーフ検査の error で中断した | 工程 1（html-artifact） | 該当ルールに沿って HTML を直し、工程 3 を `--rebuild` 付きで再実行 |
| 変換は通ったが `report.md` に未再現・はみ出しが並ぶ | 工程 1（html-artifact） | 同上。pptx を手で直すと次回の生成で消える |
| 文字が溢れる・図が消える | 工程 1（html-artifact の [pptx-safe.md](../html-artifact/references/pptx-safe.md)） | 同上 |

**HTML を直したときのやり直しは工程 1 から**で、工程 3 は `--rebuild` を付けて再実行する
（付けないと分割済みの見本が再利用され、HTML の修正が反映されないことがある）。
HTML に問題が無く、数枚がたまたま落ちただけなら `retry_image_slide` で済む。

## 関連スキル

| スキル | 使い分け |
|---|---|
| [html-artifact](../html-artifact/SKILL.md) | HTML デッキだけでよいとき（投影・共有用） |
| [html-to-deck](../html-to-deck/SKILL.md) | HTML が既にあり、変換だけしたいとき |
| [slide-structure-designer](../slide-structure-designer/SKILL.md) | 構成 MD がまだ無いとき（本スキルの前段） |
| [pptx-from-reference](../pptx-from-reference/SKILL.md) | HTML を経由せず、MD と参照 pptx から直接 pptx を作るとき |
