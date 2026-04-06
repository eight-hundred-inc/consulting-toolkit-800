---
name: image-generator-guide
description: >-
  画像生成サブエージェント用のリファレンス。HTML+CSS／SVGによる構造化図解の
  設計ガイドラインとワークフローを提供する。イラスト・アート系リクエストには
  画像生成プロンプトを返却する。image-creator サブエージェントから読み込まれる。
---

# 画像生成ガイド

image-creator サブエージェント向けの作業手順書。

## 入出力

- **入力**: ソースドキュメント（図解対象の情報を含む文書）、リクエスト内容
- **出力**: PNG画像（HTML+CSS経由）、SVGファイル、または画像生成プロンプト（テキスト）

## ルーティング判断

リクエスト内容を分析し、以下の基準でアプローチを選択する。

### chart-generator-guide に委譲する条件（最初に判定）

以下のいずれかに該当する場合、このスキルではなく [chart-generator-guide](../chart-generator-guide/SKILL.md) を読み、そちらの手順に従う。

- 棒グラフ・折れ線・レーダー・散布図など、数値軸を持つデータチャートの作成
- サーベイ結果・統計データ・財務指標の可視化
- matplotlib による精密なグラフ描画が必要

該当しない場合は以下のルーティングに進む。

### コード生成を選ぶ条件（デフォルト）

以下のいずれかに該当する場合はコード生成（HTML+CSS / SVG）で実装する。

- 日本語テキストが主要な構成要素である
- 表・マトリクス・フローチャートなど構造化されたレイアウトが必要
- 数値・ラベルの正確な配置が求められる
- ブランドカラー・フォントの厳密な指定がある
- 同じ構造で変数だけ変えて再生成する可能性がある

**判断に迷う場合はコード生成を選ぶ。**

### プロンプト返却を選ぶ条件

以下のすべてに該当する場合は、画像生成プロンプト（テキスト）を作成して返却する。ユーザーが外部の画像生成ツール（DALL-E、Midjourney 等）で利用する想定。

- イラスト・写真・アート系のビジュアルが求められている
- テキスト要素が少ない、または正確な配置が不要
- コード生成では表現しにくい抽象的・感覚的なビジュアル

### コード生成内のフォーマット選択

コード生成を選んだ後、HTML+CSS と SVG のどちらで実装するかを決める。

**HTML+CSS を選ぶ:**
- Flexbox / Grid による複雑なレイアウト制御が必要
- 多数のカード・テーブル・マトリクスを含む
- screenshot.py で PNG 出力する前提

**SVG を選ぶ:**
- タイムライン・ロードマップ・ガントチャート型の図
- 矢印接続（marker）やグラデーションが中心の構成
- ベクター形式での出力が求められている
- レイアウトが座標ベースで制御しやすい構造

迷う場合は HTML+CSS を選ぶ。レイアウトの自由度が高い。

## コード生成ワークフロー

### Step 1: 設計

ソースドキュメントを読み、図解対象の構造を把握する。構造に応じたレイアウトパターンを選ぶ。パターンの詳細は [references/design-patterns.md](references/design-patterns.md) を参照。

### Step 2: コード実装

フォーマット選択の結果に応じて HTML+CSS または SVG で実装する。

#### HTML+CSS の場合

以下の CSS 設計ルールに従って HTML ファイルを作成する。

**キャンバス**
- `body` 要素に `width` を px 固定で指定する（例: 1200px）。高さは指定しない（コンテンツに合わせて自動）
- screenshot.py が `body` をセレクタとしてキャプチャするため、コンテンツぴったりにクロップされる
- `overflow: hidden` で枠外の描画を防ぐ

**フォント**
- `'Noto Sans JP', 'Meiryo UI', sans-serif` を指定
- Google Fonts から Noto Sans JP を `@import` で読み込む
- ウェイト: 300/400/500/600/700 を読み込む

**フォントサイズ目安**

| 要素 | サイズ |
|------|--------|
| メインタイトル | 24-28px, weight 700 |
| サブタイトル | 14-16px, weight 400 |
| フェーズ名・セクション名 | 16-18px, weight 700 |
| カード内テキスト | 13-15px, weight 400-500 |
| バッジ・ラベル | 10-12px, weight 600-700 |
| 注釈・凡例 | 9-11px |

**改行制御**
- 日本語テキスト要素には `white-space: nowrap` を設定し、自動改行を防ぐ
- 改行が必要な箇所は HTML 側で明示的に `<br>` を入れる
- 自然な単語の区切りで改行する。単語の途中で切らない

**レイアウト**
- flexbox ベースで構成する。float や position: absolute は最小限にする
- gap プロパティで要素間隔を制御する
- カラム幅は px 固定で指定し、メインコンテンツ領域のみ `flex: 1` にする

**色指定**
- ブランドカラーの指定がある場合はそれに従う
- 指定がなければ、ダークグリーン (#1B3928) をプライマリとする
- 背景色は白 (#FFFFFF) を基本とする
- アクセントカラーは用途で使い分ける（例: 積極=緑系、注意=黄系、抑制=グレー系）

#### SVG の場合

以下のルールに従って SVG ファイルを作成する。パターンの詳細は [references/design-patterns.md](references/design-patterns.md) のパターン 5 を参照。

**キャンバス**
- `viewBox="0 0 1200 820"` を基本とする（幅 1200、高さは内容に応じて調整）
- SVG ルート要素に `width` `height` 属性も明示する
- 背景は `<rect>` で描画する（SVG に background プロパティはない）

**フォント**
- `font-family="'Helvetica Neue', Arial, sans-serif"` を SVG ルート要素に指定
- Google Fonts の読み込みは不要（SVG ではシステムフォントを使う）

**フォントサイズ目安**

| 要素 | サイズ |
|------|--------|
| ヘッダータイトル | 18px, font-weight 600 |
| セクション見出し | 14px, font-weight 700 |
| カードヘッダー | 12-13px, font-weight 600 |
| 本文テキスト | 11px, font-weight 400 |
| バッジ・ラベル | 9-10px, font-weight 600 |
| 注釈・凡例 | 9-10px |

**日本語テキストの処理**

Write ツールで SVG を書き出すと日本語が文字化けする場合がある。以下のいずれかで対処する。

1. **HTML numeric character references で記述する（推奨）**
   - 日本語テキストを `&#x` 形式のエンティティに変換して記述する
   - 例: `業務` → `&#x696D;&#x52D9;`
   - Write ツールで直接書けるため、追加のスクリプト実行が不要

2. **Python 経由で UTF-8 書き出しする**
   - HTML にインライン SVG として記述し、Python で SVG 部分を抽出する
   - または Python スクリプトで直接 SVG ファイルを生成する

```bash
python3 -c "
import re
with open('input.html', 'r', encoding='utf-8') as f:
    content = f.read()
match = re.search(r'(<svg.*?</svg>)', content, re.DOTALL)
if match:
    svg = '<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n' + match.group(1)
    with open('output.svg', 'w', encoding='utf-8') as f:
        f.write(svg)
"
```

**レイアウト**
- `<g transform="translate(x, y)">` でグループを配置する
- 座標は px 固定で指定する（flexbox / grid は使えない）
- 矢印は `<marker>` 要素を `<defs>` に定義し、`marker-end` で参照する
- 影は `<filter>` の `feDropShadow` で実現する
- グラデーションは `<linearGradient>` を `<defs>` に定義する

**色指定**
- HTML+CSS と同じカラーパレットを使う
- ブランドカラー指定がなければダークグリーン (#1B3928) をプライマリとする
- 透明度は `opacity` 属性で制御する

### Step 3: 出力生成

#### HTML → PNG の場合

`scripts/screenshot.py` を使って HTML を高解像度 PNG に変換する。headless で実行され、ブラウザは表示されない。デフォルトで `body` 要素をキャプチャするため、コンテンツに合わせて自動クロップされ余白が発生しない。

**単体変換:**

```bash
python3 skills/image-generator-guide/scripts/screenshot.py \
  --html <HTMLファイルパス> \
  --out <出力PNGパス> \
  --width 1200 --scale 2
```

**バッチ変換（複数ファイルを1回のブラウザ起動で変換）:**

```bash
python3 skills/image-generator-guide/scripts/screenshot.py \
  --batch manifest.json
```

manifest.json の形式:
```json
[
  {"html": "file1.html", "png": "file1.png", "width": 1200},
  {"html": "file2.html", "png": "file2.png", "width": 960}
]
```

- `--selector body` がデフォルト。`--selector .slide` で特定要素のみキャプチャも可能
- `--scale 2` で 2x 解像度を生成する（デフォルト）
- `--height` の指定は不要。body セレクタでコンテンツ高さに自動フィットする

#### SVG の場合

SVG はそのままファイル出力する。screenshot.py は不要。

1. Write ツールで `.svg` ファイルを直接書き出す（日本語は entity 参照で記述）
2. 文字化けが発生した場合は HTML に SVG を埋め込んで書き出し、Python で抽出する（Step 2 の手順を参照）
3. ブラウザで表示を確認する（ローカルサーバー経由、または IDE のプレビュー機能）

### Step 4: 確認と調整

生成した PNG または SVG を確認し、以下をチェックする:
- テキストが意図しない位置で改行されていないか
- フォントサイズが読みやすいか
- 要素間の余白バランスが適切か
- 色の視認性が十分か

問題があればソースを修正して Step 3 を再実行する。

### Step 5: ファイル整理

- 最終 PNG / SVG と HTML ソースを `assets/` フォルダにまとめて格納する（元ドキュメントの近くに作成）
- SVG の場合、中間 HTML ファイルがあれば削除する

## プロンプト返却パス

プロンプト返却を選択した場合は、以下のガイドラインでプロンプトを構成し、親エージェントにテキストとして返す。ユーザーが DALL-E / Midjourney / Stable Diffusion 等の外部ツールに貼り付けて使用する。

**プロンプト構成**
1. 主題の明確な記述（何を描くか）
2. スタイル指定（illustration / photo-realistic / flat design / etc.）
3. 色調・雰囲気（warm, professional, minimal, etc.）
4. 構図の指示（centered, wide shot, close-up, etc.）
5. ブランドカラーがある場合は色の指定

**注意事項**
- プロンプトは英語で構成する（主要な画像生成ツールは英語プロンプトの精度が高い）
- 「このプロンプトを画像生成ツールに入力してください」と案内を添える
