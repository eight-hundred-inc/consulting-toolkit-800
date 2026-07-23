---
name: slide-pattern-creator
description: パターンライブラリの保守用スキル（低頻度・明示起動のみ。ライブラリ本体は html-artifact / image-creator が実行時に参照する現役資産）。スライドの画像・ファイルからレイアウトパターンを抽出し、SLIDE-PATTERN-{name}.mdとスケルトンHTMLを生成する。「スライドパターンを抽出して」「スライドパターンを作って」「SLIDE-PATTERNを生成して」「slide-pattern-creator」と言われたときに使用する。パターンライブラリ（SLIDE-PATTERN-INDEX.md と各パターン一式）はプラグインに同梱されており、実行時はプラグインcache側を参照する。新規パターンはワークスペースのソース側 library に書き込み、/release-toolkit で配布する。
---

# slide-pattern-creator

スライドの画像・PowerPointファイル・テキスト説明からレイアウト構造を解析し、AIが再現できるようパターンを言語化した `SLIDE-PATTERN-{name}.md` と、グレースケールのスケルトンHTMLサンプルを生成する。

このスキルはスライド生成4層アーキテクチャの **2層＝レイアウトパターン** を担う。1枚のスライドのコンテンツエリア構造の唯一の正本であり、パターンの選定は下流の実装スキルが行う — `html-artifact` が Slide Deck 生成時のレイアウト割付（html-artifact SKILL.md step 5）で `SLIDE-PATTERN-INDEX-COMPACT.md` を読んで各スライドに割り付ける（構成MDに `パターン指定: SLIDE-PATTERN-{name}` が書かれていればそれを優先する後方互換も維持）。下流は **パターン名＋構成MDの図版指示** で構造に従うのが既定で、スケルトンHTMLは列比・固定幅などの **比率採寸に迷うときの任意参照** とする（優先順位＝構成MD構図 ＞ 図版指示 ＞ HTML寸法採寸）。

パターンは、表紙・タイトル行・フッター・配色を規定する **スライドマスター（branded-pptx のマスター定義 / html-artifact のテーマ）** と組み合わせて使う。パターン（コンテンツエリアの構造）とスライドマスター（枠・装飾・配色）を別レイヤーとして分離し、AIツールに両方を渡すことでデザインとレイアウトを揃えたスライドを生成できる。

## STEP 1：入力の受け取り

スキル起動時、ユーザーが以下のいずれかを提供しているか確認する：

- スライドの画像・スクリーンショット（主な入力）
- PowerPointファイル（.pptx）
- テキストによるレイアウト構造の説明

**何も提供されていない場合**、以下のように尋ねる：

> 「スライドの画像やファイルを渡してください。PowerPointファイル（.pptx）や、テキストでレイアウト構造を説明していただくことも可能です。なお、Google Slidesは直接受け付けできないため、スクリーンショットまたはPowerPoint形式でエクスポートしてください。」

複数の画像・スライドが渡された場合はすべてを受け取り、STEP 2の分析に使用する。

## STEP 2：パターンの検出と分類

受け取った入力を解析し、異なるレイアウト構造を検出する。

### 分析する観点

- **カラム構成**：1カラム・2カラム・3カラム・グリッド等
- **主要エリアの配置**：画像・テキスト・アイコン・チャートがどこにあるか
- **コンテンツの種類**：見出し・箇条書き・引用・データ・図解 等
- **強調の仕方**：フルスクリーン要素・中央配置・左右分割 等

### 分析対象外（スライドマスターで定義）

以下の要素は **スライドマスター（branded-pptx のマスター定義 / html-artifact のテーマ）** で一括管理されるため、パターン分析には含めない：

- タイトルエリア（スライドタイトルの位置・フォント・装飾）
- ページ番号・フッター（位置・スタイル）
- スライド全体の背景色・共通装飾（アクセントバー・装飾図形等）
- **ルック語彙**（hex 色・px 指定・border・背景色指定・チップ/ラベルの見た目様式・マーカー色・フォント指定・shadow 等、描画に属する記述）— 見た目は選択マスターのトークン＋ベースライン規範（`_shared/slide-body-principles.md`）が決めるため、パターン定義には書かない

**パターンとして定義するのは、タイトル行より下のコンテンツエリアの構造のみ（ルックは含めない）とする。**

### 検出結果の提示

**1パターンの場合：**

> 「1種類のレイアウトパターンを検出しました。
> 構造：[構造の簡単な説明]
> パターン名の候補：`[proposed-name]`
> このパターン名でよいですか？別の名前にしたい場合はお知らせください。」

→ ユーザーが承認すればSTEP 4へ、別名を希望すればSTEP 3へ

**複数パターンの場合：**

> 「X種類のレイアウトパターンを検出しました：
>
> 1. [構造の説明] → 候補名：`[name-1]`
> 2. [構造の説明] → 候補名：`[name-2]`
> 3. [構造の説明] → 候補名：`[name-3]`
>
> すべてのパターンのファイルを生成しますか？
> 生成するパターンを選びたい場合は番号で教えてください。」

→ ユーザーの回答に応じて対象パターンを確定し、STEP 3へ

## STEP 3：パターン名の確認

STEP 2で提示した命名候補をユーザーが承認していない場合、このSTEPで確定する。

### 命名ルール

- 英小文字・ハイフン区切りのみ使用する
- 構造が一目でわかる名前にする
- 命名例：
  - `title-center` — 中央にタイトルのみ
  - `image-left-text-right` — 左に画像・右にテキスト
  - `three-column-icons` — 3カラムにアイコンと説明
  - `full-image-overlay` — 全面画像にテキストオーバーレイ
  - `bullet-list` — 見出し＋箇条書き
  - `data-chart` — 見出し＋グラフ・表
  - `quote-statement` — 引用・インパクト文字
  - `summary-grid` — まとめのカードグリッド

### 確認の進め方

複数パターンが対象の場合、1パターンずつ確認する：

> 「パターン1の名前：`image-left-text-right` でよいですか？」

ユーザーが承認したら次のパターンの確認へ、または変更を希望する場合は指定の名前を受け取る。

全パターンの名前が確定したらSTEP 4へ進む。

## STEP 4：SLIDE-PATTERN-{name}.mdの生成

確定したパターン名でフォルダとファイルを生成する。

### 保存先の決定

**デフォルトはプラグインのソース側ライブラリ**に保存する。ライブラリに置くとどのプロジェクトからでも `slide-structure-designer` と下流実装スキル（html-artifact / image-creator / branded-pptx）が自動で見つけられる：

    <プラグインソースの checkout>/plugins/consulting-toolkit/skills/slide-pattern-creator/library/SLIDE-PATTERN-{name}/

（例: `~/Workspace/consulting-toolkit/plugins/consulting-toolkit/skills/slide-pattern-creator/library/SLIDE-PATTERN-{name}/`。プラグインソースの checkout が存在しない環境では、保存先 2（カレントディレクトリ）を選ぶ）

> **重要（cache と source の使い分け）**：実行時にパターンを**参照**するのはプラグインcache側（`${CLAUDE_PLUGIN_ROOT}/skills/slide-pattern-creator/library/`）だが、**新規パターンの書き込みは必ずワークスペースのソース側（上記 `~/Workspace/...` パス）に行う**。cache側（`~/.claude/plugins/cache/...`）への書き込みは PreToolUse hook でブロックされ、プラグイン更新で上書きされる。ソース側に書き込んだ後、`/release-toolkit` で配布する（配布して初めて cache 側にも反映される）。

特定プロジェクト専用として保存したい場合はカレントディレクトリを選択できる。ユーザーに以下を確認する（未指定ならソース側ライブラリを使う）：

> 「スライドパターンの保存先はどちらにしますか？
> 1. プラグインのソース側ライブラリ（他プロジェクトから再利用可能／/release-toolkit で配布）【デフォルト】
> 2. カレントディレクトリ（このプロジェクト専用）」

カレントディレクトリを選んだ場合の保存先：

    ./SLIDE-PATTERN/SLIDE-PATTERN-{name}/

以降このスキル内では、確定した保存先を `{OUTPUT_ROOT}` と表記する。作成する .md ファイルのパス：

    {OUTPUT_ROOT}/SLIDE-PATTERN-{name}/SLIDE-PATTERN-{name}.md

### SLIDE-PATTERN-{name}.mdの出力形式（schema v2＝構造のみ）

以下の4セクション構成で出力する。各 `[　]` に解析・確認で得た実際の値を入れる。

**schema v2 の記述規則**：パターン定義に書くのは**構造のみ**——ゾーン分割（role・幅比率・配置）・読み順・要素の役割/種類/数（「リスト3〜4項目」「番号バッジ＋短文」等）。**ルック語彙（hex色・px・border・背景色指定・チップ/ラベルの見た目様式・マーカー色・フォント指定・shadow 等）は一切書かない**。ルックでしか表現できない気がする要素は役割語に正規化する（例：「背景#F0F0F0のラベル」→「ゾーン見出しラベル」、「× マーカー #888」→「負の側のマーカー」）。見た目は選択マスターのトークン＋ベースライン規範（`_shared/slide-body-principles.md`）が決める。

---
出力ファイル：{OUTPUT_ROOT}/SLIDE-PATTERN-{name}/SLIDE-PATTERN-{name}.md

# SLIDE-PATTERN-{name}

このファイルはスライドのコンテンツエリア（タイトル行より下の領域）のレイアウトパターン定義書です。スライドマスター（branded-pptx のマスター定義 / html-artifact のテーマ）と組み合わせてAIツールに渡すことで、このパターンのスライドを生成できます。タイトルエリア・ページ番号・フッター・装飾はスライドマスターで定義されるため、このファイルには含みません。プレビュー .html は生成当時の見本であり非規範。見た目は選択マスターが決めます。

## Overview

**パターン名：** {name}
**概要：** [パターンの一言説明（例：左半分に画像、右半分に見出しと本文を配置する2カラムレイアウト）]
**適したシーン：** [どんな内容のスライドに向いているか（例：製品・事例紹介、ビフォーアフター、具体例の提示）]
**対応する図解指名：** [構成MDの図解指名（自由記述）で使われる語彙（例：左右2カラム / 概念フロー / 2x2マトリクス / ピラミッド / ファネル 等）。html-artifact のレイアウト割付が図解指名の語彙からパターンを引けるようにする。該当なしなら「―」]
**下流実装ヒント：** html-artifact: [使用コンポーネントの目安（例：State Grid、2カラム flow）]／pptx: [プレースホルダ配置・図形の目安（例：左に画像プレースホルダ、右にテキストボックス2つ）]

## Structure（構造）

[コンテンツエリアの構造を1〜3文で説明する。タイトル行より下のエリアがどう分割されているかを記述する。タイトル・ページ番号・フッター・装飾・ルックは含めない。]

    layout: {name}
    zones:
      - role: [ゾーンの役割語（例: before / steps / summary / main-visual）]
        width: [幅比率（例: 42%。縦分割なら height。自明な均等分割は省略可）]
        content: [要素の種類と数（例: リスト 3〜4項目（負の側のマーカー）、番号バッジ＋短文 ×4）]
      - role: transition
        width: 8%
        content: 変化の方向を示す矢印（縦中央）
      - role: [...]
        width: [...]
        content: [...]
    reading_order: [読み順（例: 左 → 中央 → 右 / 上段 → 下段）]
    notes: [構造上の注意（例: Before と After の項目数は揃え、対応関係が分かる順に並べる）]

（ゾーン数・キーはレイアウト構造に応じて増減する。入れ子構造が必要な場合のみ zone 内に `elements:` リストを持たせる）

> 記述するのは構造のみ。幅比率は非自明なもの（40/60 等）だけ書き、px・色・装飾はどこにも書かない。プレビュー .html（STEP 5）は見本であって正本ではない。

## Elements（各要素の役割）

※ タイトル（H1）はスライドマスターで定義されるため、この表には含めない。コンテンツエリアの要素のみを記述する。

| 要素 | 配置 | 役割 |
|---|---|---|
| [要素名（例：画像）] | [配置場所（例：左カラム全体）] | [この要素が担う意味・機能（例：メッセージを補強するビジュアル）] |
| [要素名（例：見出し H2）] | [配置場所（例：右カラム上部）] | [役割（例：スライドの主張・サブタイトル）] |
| [要素名（例：本文）] | [配置場所（例：右カラム中央）] | [役割（例：見出しを支える説明文（2〜4行））] |

## Usage Guide（AIへの使い方）

このパターンをAIに指示する際のプロンプト例：

> 「SLIDE-PATTERN-{name}のレイアウトで、[各エリアに入れる内容を指定]してください。デザインはスライドマスター（branded-pptx のマスター定義 / html-artifact のテーマ）に従ってください。」

**注意点：**
- [このパターン特有の注意点や代替案（例：画像がない場合は左カラムをカラーブロックで代替できる）]
---

## STEP 5：SLIDE-PATTERN-{name}.htmlの生成

STEP 4と同じフォルダ内にスケルトンHTMLを生成する。

> **プレビューの位置づけ（非規範の見本）**：スケルトンHTMLは、そのパターンの標準的な構造を体現した**見本（プレビュー）であって正本ではない**。構造（ゾーン分割・幅比率・要素の役割と数・読み順）の正本は STEP 4 の定義MD（schema v2）にあり、見た目（色・装飾・フォント・余白の実値）は下流の選択マスターのトークン＋ベースライン規範（`_shared/slide-body-principles.md`）が決める。プレビューのグレースケール配色・px 値は見本を成立させるための便宜であり、下流が従うルックではない。
>
> **下流での優先順位（重要）**：段組・カード数・グリッド形（2×2 か 1×4 か）・ステップ数といった意味構造は **schema v2 が正本**であり、その上位に**構成MDの構図指定**が立つ。プレビューHTMLの具体形がこれらを上書きしてはならない。**優先順位＝ 構成MDの構図指定 ＞ schema v2 ＞ HTML寸法採寸（非自明な比率に迷うときの任意参照）**。したがってスケルトンHTMLは、そのパターンの**標準的な意味構造をそのまま体現する一例**として作り（schema v2 と段数・カード数を一致させる）、恣意的な簡略化・別解を混ぜない。

### 出力先

    {OUTPUT_ROOT}/SLIDE-PATTERN-{name}/SLIDE-PATTERN-{name}.html

### HTMLの実装方針

- **色**：グレースケールのみ（背景：#FFFFFF、ボーダー：#CCCCCC、エリア背景：#F0F0F0、テキスト：#333333）
- **フォント**：システムデフォルト（font-family: sans-serif）
- **サイズ**：960px × 540px固定（16:9）
- **各エリアにラベル表示**：`font-size: 11px; color: #999; text-transform: uppercase;` で何のエリアか明示
- **コンテンツ**：ダミーテキスト（「見出しが入ります」「本文テキストが入ります。2〜4行程度の説明文が配置されます。」「キャプション」等）
- **JavaScriptは使用しない**
- **外部リソース不要**（フォントCDN等は使わない）
- **タイトルエリアのプレースホルダーを必ず上部に配置する**：薄いグレーで "Title Area — スライドマスター参照" とラベル表示し、このエリアがスライドマスター（branded-pptx のマスター定義 / html-artifact のテーマ）で定義されることを明示する。タイトルより下がコンテンツエリア（このパターンが定義する領域）となる。
- **スライド全体は `display:flex; flex-direction:column;` で構成する**：タイトルエリアを `flex-shrink:0` で固定し、コンテンツエリアを `flex:1` で残りを埋める。

### CSSの基本構造

    body {
      background: #E8E8E8;
      display: flex;
      flex-direction: column;
      align-items: center;
      padding: 40px 20px;
      font-family: sans-serif;
    }

    .slide {
      width: 960px;
      height: 540px;
      background: #FFFFFF;
      border: 1px solid #CCCCCC;
      position: relative;
      overflow: hidden;
      margin-bottom: 8px;
    }

    .area-label {
      font-size: 11px;
      color: #999999;
      text-transform: uppercase;
      letter-spacing: 0.08em;
      margin-bottom: 6px;
    }

    .placeholder-box {
      background: #F0F0F0;
      border: 1px dashed #CCCCCC;
      display: flex;
      align-items: center;
      justify-content: center;
      color: #AAAAAA;
      font-size: 13px;
    }

### HTMLの構成例（image-left-text-rightの場合）

パターンの構造に応じてHTMLを生成する。以下は2カラム（左画像・右テキスト）の構成例：

    <p class="slide-label">[{name}]</p>
    <div class="slide" style="display:flex; flex-direction:column;">
      <!-- タイトルエリア（スライドマスターで定義） -->
      <div style="padding:14px 40px 12px; border-bottom:1px dashed #CCCCCC; flex-shrink:0; background:#FAFAFA;">
        <div class="area-label">Title Area — スライドマスター参照</div>
        <div style="font-size:16px; color:#CCCCCC; margin-top:4px;">スライドタイトルが入ります</div>
      </div>
      <!-- コンテンツエリア（このパターンが定義する領域） -->
      <div style="display:flex; flex:1; overflow:hidden;">
        <div style="width:50%; padding:24px 32px; display:flex; flex-direction:column; justify-content:center; border-right:1px solid #CCCCCC;">
          <div class="area-label">Image Area</div>
          <div class="placeholder-box" style="flex:1;">[IMAGE]</div>
        </div>
        <div style="width:50%; padding:24px 32px; display:flex; flex-direction:column; justify-content:center;">
          <div class="area-label">Heading (H2)</div>
          <div style="font-size:20px; font-weight:bold; color:#333; margin-bottom:12px;">見出しが入ります</div>
          <div class="area-label">Body Text</div>
          <div style="font-size:13px; color:#555; line-height:1.7; margin-bottom:12px;">本文テキストが入ります。2〜4行程度の説明文が配置されます。ここにメッセージの詳細を記述します。</div>
          <div class="area-label">Caption (optional)</div>
          <div style="font-size:11px; color:#999;">補足・注釈テキスト</div>
        </div>
      </div>
    </div>

### 生成時の注意

- パターンの構造（カラム数・配置）に合わせてHTMLを柔軟に組み立てる
- ラベルは必ずすべてのエリアに表示する
- ダミーテキストは日本語で記述する

## STEP 6：繰り返し・完了通知

### 複数パターンの繰り返し

対象パターンが複数ある場合、STEP 3〜5を1パターンずつ繰り返す：

1. パターン名を確認（STEP 3）
2. SLIDE-PATTERN-{name}.md を生成（STEP 4）
3. SLIDE-PATTERN-{name}.html を生成（STEP 5）
4. 次のパターンへ

## STEP 7：SLIDE-PATTERN-INDEX.md の更新

全パターンの生成が完了したら、`{OUTPUT_ROOT}/SLIDE-PATTERN-INDEX.md` を更新する（ソース側ライブラリなら `<プラグインソースの checkout>/plugins/consulting-toolkit/skills/slide-pattern-creator/library/SLIDE-PATTERN-INDEX.md`（例: `~/Workspace/consulting-toolkit/...`）、カレントディレクトリなら `./SLIDE-PATTERN/SLIDE-PATTERN-INDEX.md`）。ソース側に書き込んだ場合は `/release-toolkit` で配布する。

### インデックスファイルが存在する場合

今回生成したパターンの内容（概要・適したシーン・対応する図解指名）をもとに、`{OUTPUT_ROOT}/SLIDE-PATTERN-INDEX.md` の**最も近いカテゴリの末尾**に追記する。あわせて、同ディレクトリの `SLIDE-PATTERN-INDEX-COMPACT.md`（html-artifact のレイアウト割付が読む軽量版）の同カテゴリにも 1 行（`- {name}: {概要の第 1 文・65 字以内}`）を追加して同期を保つ。

カテゴリは以下の12種類（ギャラリーと同じ順番）：
- 🎯 表紙・セクション
- 📋 目次
- ✏️ コンテンツ（本文）
- 📝 テキストリスト
- ➡️ フロー・ステップ
- 🔄 図解・ダイアグラム
- 🃏 カード・グリッド
- 📊 グラフ・データ
- 📑 テーブル・比較
- 🏆 KPI・まとめ
- ❓ Q&A・FAQ
- 👤 プロフィール

各カテゴリのテーブルは以下の4列で構成する：

    | パターン名 | 概要 | 適したシーン | 対応する図解指名 |
    |---|---|---|---|

追記する形式（該当カテゴリのテーブル末尾に1行追加）：

    | {name} | {概要の内容} | {適したシーンの内容} | {対応する図解指名の内容} |

どのカテゴリにも当てはまらない場合は、最も近いカテゴリを選んで追記する。
「パターン数：XX」の行も更新する（現在の件数＋追加件数に書き換える）。

### インデックスファイルが存在しない場合

`{OUTPUT_ROOT}/` 直下にある既存の `SLIDE-PATTERN-*/SLIDE-PATTERN-*.md` をすべて読み込み、各ファイルの `**概要：**`・`**適したシーン：**`・`**対応する図解指名：**` を抽出してインデックスを新規作成する。12カテゴリでグルーピングし、各カテゴリのテーブルを4列で作る。

作成するファイルの形式：

    # SLIDE-PATTERN-INDEX

    スライドパターンの一覧です。パターンの割付は `html-artifact` のレイアウト割付（SKILL.md step 5）が軽量版 `SLIDE-PATTERN-INDEX-COMPACT.md` を読んで行い、詳細確認に本ファイルを参照します。下流実装（html-artifact / image-creator / branded-pptx）は割付（または構成MDの `パターン指定:`）を受けて各フォルダの定義MD・スケルトンHTMLに従います。
    新しいパターンを追加した際は、このファイルの該当カテゴリに追記し、SLIDE-PATTERN-INDEX-COMPACT.md にも同じパターンの 1 行を追加してください。

    パターン数：XX

    ## 🎯 表紙・セクション

    | パターン名 | 概要 | 適したシーン | 対応する図解指名 |
    |---|---|---|---|
    | {name} | {概要} | {適したシーン} | {対応する図解指名} |

    （以下、12カテゴリ分を同じ4列テーブルで並べる。既存パターン＋今回生成したパターンをすべて含める）

### 完了通知

インデックス更新後、以下のようにユーザーに伝える：

> 「[X]件のスライドパターンファイルを生成し、SLIDE-PATTERN-INDEX.md を更新しました。
>
> [生成したフォルダ・ファイルの一覧]
> 例（ソース側ライブラリに保存した場合）：
> - ~/Workspace/consulting-toolkit/plugins/consulting-toolkit/skills/slide-pattern-creator/library/SLIDE-PATTERN-image-left-text-right/
>   - SLIDE-PATTERN-image-left-text-right.md
>   - SLIDE-PATTERN-image-left-text-right.html
>
> ソース側に保存したので、`/release-toolkit` で配布すると実行時（cache側）にも反映されます。スライドマスター（branded-pptx のマスター定義 / html-artifact のテーマ）とこれらのパターンファイルをAIツールに渡すことで、このデザインとレイアウトでスライドを生成できます。」
