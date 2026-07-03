---
name: html-artifact
description: >-
  Markdown を業務文書スタイルの自己完結 HTML アーティファクトに変換するスキル。コンサルティングファームの
  社内文書のような上品で構造的なデザイン（紙質クリーム背景・Noto Sans JP 統一フォント・テラコッタアクセント）で、
  企画書・提案書・報告書・調査レポート・戦略メモ・意思決定文書・議事メモ・社内通達・3 案比較・実装計画・
  業務プロセス文書を生成する。
  21 種の構造化コンポーネント（Cover, TOC, Section Head, KPI Row, State Grid, Scope Panel, Report Table,
  Rating Dots, Insight Callout, Priority List, Budget Grid, Q&A Card, Roadmap, Proposal Card, Flow with Margin,
  Summary 他）に 4 種の拡張コンポーネント（Eyebrow Bar, Hero Number, Takeaway Strip, Annotation Pointer）
  と、Slide Deck × Mono テーマ専用の 5 種の参照デザインコンポーネント（Filled-Header Card, Value Bar,
  Icon Chip, Pill Tag, Expansion Pills）を加えた合計 30 種、さらに 8 種の構造化図解（概念フロー、
  2x2 マトリクス、ピラミッド、ファネル、サイクル、ベン図、組織図、レイヤー積層図）を
  インライン HTML+CSS で文書内に埋め込める。
  同じデザインシステムで 16:9 HTML スライドデッキ（Slide Deck format, 1280×720）の生成にも対応し、
  ブラウザでめくれる投影資料を 1 枚 1 メッセージ単位で出力できる（単スライド表示・キーボード送り・
  サムネイル一覧・URL ハッシュ深リンク・印刷時 1 ページ 1 スライド対応）。
  「Markdown を HTML に」「ブラウザで開ける形式に」「HTML 化」「自己完結 HTML」「企画書を HTML にして」
  「報告書を HTML で作って」「議事メモを HTML にまとめて」「調査結果を HTML レポートに」「業務文書 HTML にして」
  「社内向けの説明資料を作って」「ちゃんとした体裁のドキュメントにして」「3 案比較を作って」
  「実装計画を作って」「16:9 のスライドにして」「ブラウザでめくれるプレゼンを作って」
  「HTML スライドデッキを作って」「投影資料を作って」「文書に図解を入れて」「概念フロー図を作って」
  「4 象限マトリクスで整理して」「ピラミッド図にして」「ファネルで可視化して」「ベン図で表現して」などの
  リクエスト時に使用する。既存 Markdown ファイルがある場合も、対話的にゼロから作る場合も対応する。
  Markdown を Single Source of Truth として保持し、HTML は派生物として再生成できる。
  生成した HTML を共有 URL として公開したい場合は `html-publish` スキルに出力パスを渡す（本スキルは生成のみ）。
  マガジン風・編集デザイン風・派手な装飾のリクエストには使用しない。
---

# html-artifact

Markdown を業務文書スタイルの自己完結 HTML に変換する（生成専用）。生成した HTML を Cloudflare Pages で共有 URL 化する公開フローは別スキル `html-publish` に分離されている。

業務文書（コンサルティングファームの社内資料）として違和感のない、紙質クリーム背景＋Noto Sans JP 統一フォントの上品で実務的なドキュメントを生成する。Markdown は読み切りの「レポート」、HTML は継続的に使える「インターフェース」として運用する（Thariq Shihipar「Using Claude Code: The Unreasonable Effectiveness of HTML」, 2026-05-08 の思想を踏襲）。

本スキルの設計は **3 軸の直交した選択** で成り立つ。混同しないこと：

| 軸 | 選択肢 | 何を決めるか |
|---|---|---|
| **1. Content Recipe**（内容レシピ） | A〜F の 6 種 | どの章構成テンプレートを使うか（企画書 / 調査 / 戦略メモ / 意思決定 / 議事 / 通達） |
| **2. Output Format**（出力形式） | Vertical Document / Slide Deck | 縦長文書として読ませるか、16:9 スライドで投影するか |
| **3. Theme**（テーマ） | Terracotta / Navy / Forest / Charcoal / Mono | 配色・トーン（コンテンツとは独立） |

例：「企画書を投影資料にしたい・コンサル提案書らしい見た目で」→ Content Recipe A × Slide Deck × Mono テーマ。

## 上流・下流スキル（ワークフロー上の位置）

- **上流**：`slide-structure-designer`（スライド構成を MD で設計）→ その構成 MD を本スキルに渡して Slide Deck format で HTML スライド化できる。
- **下流（公開）**：生成 HTML を共有 URL にしたい場合は `html-publish` スキルに出力パスを渡す（Cloudflare Pages デプロイ・manifest 管理・機密確認は html-publish が担う）。
- **下流（PPTX）**：生成した Slide Deck HTML を「デザイン見本」として、ブランド pptx スキル（`pptx` をラップしたブランド版ラッパー。「html-artifact 参照モード」を持つもの）でデザイン・レイアウトを再現した PPTX を作成できる。

## 読み込み順序（必須）

| 順序 | ファイル | 内容 |
|------|---------|------|
| 1 | 本ファイル（SKILL.md） | 全体方針・トリガー条件・ワークフロー・Guardrails |
| 2 | [references/document-recipes.md](references/document-recipes.md) | Content Recipe A〜F（章構成）と Output Format（Vertical Document / Slide Deck）の判定フロー。**種別判定はここから始める** |
| 3 | [references/design-system.md](references/design-system.md) | カラー・タイポグラフィ・5 テーマ（Terracotta / Navy / Forest / Charcoal / Mono）・印刷対応の CSS 仕様 |
| 4 | [references/components.md](references/components.md) | 30 種のコンポーネント仕様（基本 21 種＋拡張 4 種＋Slide Deck × Mono 参照デザイン 5 種。HTMLスニペット付き）。**末尾に付録「Markdown → HTML マッピング」**（旧 markdown-html-mapping.md を統合） |
| 5 | [references/diagram-components.md](references/diagram-components.md) | **図解の統合リファレンス**：固定 8 図解（概念フロー・2x2・ピラミッド・ファネル・サイクル・ベン図・組織図・レイヤー）＋**リッチ判定**（作り込み図版を既定とする条件）＋**レイアウトパターン**（スイムレーン/マトリクス/カード/ステップ/タイムライン。image-generator-guide 取り込み）＋**作り込み図版**（`.fig-NN` per-figure。exemplar 方式・トークン化注意を含む）。図解が必要なときに参照 |
| 6 | [references/slide-deck.md](references/slide-deck.md) | Slide Deck format 専用。16:9 スライドシェル仕様（1280×720・5 種スライド型・プレゼンチャーム CSS/JS 完成形・印刷対応） |
| 7 | [assets/template.html](assets/template.html) | Vertical Document 用スケルトンテンプレート（プレースホルダー付き。必ず複製してから編集） |
| 8 | [assets/template-slides.html](assets/template-slides.html) | Slide Deck format 用テンプレート（5 枚スケルトン＋プレゼンモード CSS/JS＋図解スキャフォルド（fig-canvas / dgram-* / 高さ補正）） |
| 9 | [assets/examples/travel_ai_poc.html](assets/examples/travel_ai_poc.html) | 全コンポーネントを使った完成形のサンプル（参考用） |

生成した HTML を共有 URL として公開する場合は、本スキルの完了後に `html-publish` スキルへ出力パスを渡す（公開フローの詳細は html-publish 側のドキュメントを参照）。

## Triggers

### 使う

業務文書スタイルの HTML（縦長文書 / 16:9 スライド）を生成する：

- Markdown を HTML アーティファクトに変換したい
- 「ブラウザで開いて使える」資料を作りたい
- 企画書・提案書・報告書・調査レポート・戦略メモ・意思決定文書・議事メモ・社内通達を HTML にしたい
- 3 案比較／実装計画／業務プロセス文書を作りたい
- 「ちゃんとした体裁のドキュメント」を作りたい
- Markdown または既存資料を 16:9 HTML スライドにしたい（Slide Deck format）
- ブラウザでめくれるプレゼン資料・社内投影資料が欲しい（Slide Deck format）
- 投資家ピッチ・コンサル提案書スタイルの 16:9 スライドが欲しい（Slide Deck format × Mono テーマ）
- 文書内に **構造化図解**（概念フロー・2x2 マトリクス・ピラミッド・ファネル・サイクル・ベン図・組織図・レイヤー図）を埋め込みたい
- **明示的な図解指示がなくても**、章内容が構造的（フロー／対比／階層／サイクル／関係性）なら積極的に図解を入れる方針で動く（密度ガイドは Phase 1-5 参照）

### 使わない

- HTML を共有 URL として公開・Cloudflare Pages にデプロイ → `html-publish`（本スキルは生成のみ）
- 派手なマガジン風・編集デザイン・装飾過多のビジュアル → 別アプローチで対応
- note 記事を書く → `note-article-writer`（外部スキル・インストールされていれば）
- 記事内の図解 PNG を作る → `html-diagram-generator`（外部スキル・インストールされていれば）
- 調査結果の統合分析・最終報告書の内容そのものを作成する → `integrated-analysis-creator`（内容確定後の HTML 化は本スキル）
- 会議メモから議事録の文章を生成する（HTML 化までは不要） → `meeting-minutes-creator`
- プロダクション級のアプリ UI、インタラクティブなダッシュボード → `frontend-design`
- ネイティブ PowerPoint（.pptx）ファイルとして納品が必要なプレゼン → ブランド pptx スキル（本スキルの Slide Deck format は HTML で完結する社内・ブラウザ投影プレゼン用途。生成した HTML をデザイン見本に PPTX 化する連携は上記「下流（PPTX）」参照）

## Inputs

- **必須**: Markdown ファイルパス、または対話的ブリーフ（トピックのみ）
- **任意**: クライアント名、Content Recipe（A〜F）、Output Format（Vertical Document / Slide Deck）、テーマ（Terracotta / Navy / Forest / Charcoal / Mono）

入力が不足している場合は最大 2 問だけ質問する（テーマ、用途）。

生成後に共有 URL 公開まで行いたい指示（「公開して」「URL を発行して」「Cloudflare に上げて」等）があった場合は、本スキルで HTML を生成・目視確認したうえで、出力パスを `html-publish` スキルに渡す。

## Steps

### Phase 1: HTML 生成

1. **入力判定**
   - 既存 Markdown を読み込むか、ブリーフから新規作成するかを決める
   - frontmatter があれば抽出（title / date / client / confidential / tags）

2. **3 軸の判定**（Content Recipe → Output Format → Theme の順で決める）

   2a. **Content Recipe（内容レシピ A〜F）を決める**
   - `references/document-recipes.md` の判定フローチャートで A〜F のいずれかに分類する
   - 旧 4 テンプレ名（implementation-plan / 3-way-comparison / report / annotated-flow）でリクエストされた場合は document-recipes.md の対応マップで Recipe に変換

   2b. **Output Format（出力形式）を決める**
   - ユーザーが「スライド」「プレゼン」「16:9」「ブラウザでめくれる」「投影資料」「HTML デッキ」等を指示している場合は **Slide Deck format**
   - それ以外は **Vertical Document**（縦長文書、デフォルト）
   - Slide Deck format でも内容構成は 2a で決めた Content Recipe をそのまま使う（例：Content Recipe A × Slide Deck format）

   2c. **エイリアス検出（後方互換）**
   - 「Recipe G」「Pitch Mode」「Mode A / Mode B」等の旧表現は、`references/document-recipes.md`「エイリアス（後方互換）」の対応表で現在の 3 軸表現に正規化する（例：Pitch Mode → Slide Deck format × Mono テーマ）

   迷う場合は判断結果と理由を 1-2 行で示し、ユーザーが上書きできるようにする

3. **モード確認**（ユーザーがコンテンツを提供している場合のみ）
   - **忠実再現モード**：提供内容をそのまま反映（割愛・要約・文言変更を最小化）
   - **柔軟再構成モード**：章立て・表現・構成を文書として最適化
   - トピックのみ与えられた場合（ブリーフ）はこの確認は不要

4. **章構成の設計**
   - 該当 Recipe の章テーブルを参照して章立てを決める
   - 章数の目安：MD 1000 字未満→3〜5 章（TOC 省略可）、5000 字以下→5〜8 章、15000 字以下→8〜12 章

5. **コンポーネント選択**
   - **パターン指定の優先参照**：入力の構成MDに `パターン指定: SLIDE-PATTERN-{name}` がある場合、${CLAUDE_PLUGIN_ROOT}/skills/slide-pattern-creator/library/ の該当スケルトンHTMLを開き、そのスライドのコンテンツエリア構造（エリア分割・比率・要素配置）をスケルトンに合わせる。構造はパターンが正本、部品の実装は components.md / diagram-components.md から充当する。パターン指定がないスライドは従来どおり
   - 各章の内容に最適なコンポーネントを `references/components.md` の 30 種（基本 21 種＋拡張 4 種＋Slide Deck 統一シャシ 5 種）から選ぶ
   - **拡張コンポーネント（22〜25：Eyebrow Bar / Hero Number / Takeaway Strip / Annotation Pointer）**：Slide Deck format × Mono テーマで最も映えるが、他のテーマや Vertical Document でも使ってよい
   - **統一シャシ 5 種（26〜30：Filled-Header Card / Value Bar / Icon Chip / Pill Tag / Expansion Pills）**：**Slide Deck 全 5 テーマ共通**（`--accent` に自動追従）。参照デザイン（AI Biz Ops Partner / VisasQ figures）踏襲時の主役コンポーネント。Vertical Document には適用しない
   - **構造化図解の積極利用**：章内容が図解向きならまず `references/diagram-components.md` の 8 種（概念フロー・2x2 マトリクス・ピラミッド・ファネル・サイクル・ベン図・組織図・レイヤー積層図）を検討する。テキスト＋表だけで埋めない
   - **作り込み図版（Slide Deck format・リッチ判定で既定）**：Slide Deck では、①ノードが属性を 2 つ以上持つ（名称＋役割＋正本/状態 等）②辺・受け渡しに意味のあるラベルが付く ③レーン・時間軸・2 軸など次元が 2 つ以上 ④ 1 要素だけを強調するヒーロー対比 — のいずれかに当てはまるメッセージは、**固定 8 図解で形式上表現できても作り込み図版を既定**とする（判定の詳細は `references/diagram-components.md`「図解の 3 層」）。組み方は diagram-components.md 後半のレイアウト原則（**構造型で選ぶ**：並置・ステップ・マトリクス等は flow、関係図・アーキ・ハブ&スポーク・レーン跨ぎ曲線は absolute＋SVG 第一候補。image-generator-guide 踏襲）／作図文法に従い、**出来の良い既存図版があれば exemplar として参照する**（同「exemplar 方式」。型に当てはめて情報を落とさない）。配色は `--fig-accent` 由来 + `--good`/`--warn` に限定（テーマ追従・**多色禁止は維持**）。固定 8 図解は単一関係・単一次元の概念図に限って使う。**opt-out**：「シンプルでよい／作り込み不要」の指示があれば 8 図解・コンポーネントにフォールバックする
   - **図解密度ガイド**（議事メモ・通達・短文の速報系を除く全ドキュメントに適用）：
     - 章数 5 以下 → **最低 1 個** の構造化図解を含める
     - 章数 6〜10 → **2〜3 個** を目安
     - 章数 11+ → **3〜5 個** を目安
     - **Slide Deck format**：1 スライド 1 メッセージの原則に従い、**メッセージが構造的（フロー／対比／階層／サイクル等）なら原則として図解化**する。テキスト箇条書きで終わらせない
     - 議事メモ・通達など短文/速報系は **無理に入れない**（合意事項やプロセスが図解向きなら 1 個まで）
   - Markdown パターンから自動で割り当てる場合は `references/components.md` 末尾の付録「Markdown → HTML マッピング」を参照（章内容が図解向きと判定されたら原則として図解に置換する）

6. **テーマ選択**
   - **Vertical Document の既定**：Terracotta（warm consulting）。各テーマは独自の背景・ink 等を持ち視覚言語も異なる
   - **Slide Deck format の既定**：**Mono**。5 テーマ共通の統一シャシ（構造色・カード装飾・段階濃度は不動）で、`--accent` / `--accent-soft` / `--accent-bg` の 3 変数だけが palette 差分になる。Terracotta を選べば同じ Filled-Header Card がテラコッタ帯で描画される
   - その他：Navy（金融・大企業・通達）／ Forest（調査・ESG・学術）／ Charcoal（テクニカル・議事メモ）
   - 1 ドキュメント 1 テーマ

7. **テンプレート複製**
   - **Vertical Document**：`assets/template.html` を出力先ディレクトリ（入力 MD と同じディレクトリがデフォルト）にコピー
   - **Slide Deck format**：`assets/template-slides.html` を同じくコピーし、`references/slide-deck.md` のスライド型ガイドに従ってスライドを増減する
   - `{{プレースホルダー}}` を実際のコンテンツに置換
   - 不要なセクションは削除、必要に応じて components.md からコンポーネントを追加

8. **デザインシステム適用**
   - `references/design-system.md` の配色・タイポ・スペーシング仕様に従う
   - 背景は `#fafaf6`（Mono テーマでは `#ffffff`）、本文は `#1a1c20`、アクセントは 1 色のみ
   - **フォント：本文・見出しすべて Noto Sans JP / 数値・章番号・コード JetBrains Mono**
   - 絵文字は使わない

9. **Markdown → HTML 変換**
   - `references/components.md` 末尾の付録「Markdown → HTML マッピング」に従い、MD ブロックを HTML コンポーネントに割り当てる
   - AI らしい強い表現（「革新的な」「画期的な」等）を自動で中立化
   - 章番号・小番号を自動付与（01, 02 / 1.1, 1.2 …）

9.5 **作り込み図版の委譲生成（Slide Deck format・リッチ判定該当図のみ）**

    リッチ判定に該当する作り込み図版は、**必ず 1 図 1 体の専用ワーカー `slide-figure-creator`（agent）に委譲する**（強い既定。スキップは下記 2 例外のみ）。デッキ全体を組みながら親が片手間に直組みすると、1 図あたりの注意が希釈され、図が縦領域を使い切れず（上 1/3 に縮こまり下半分が空白）品質が明確に落ちる（実測。図単位の設計・クロップ検証・反復を委譲で担保する）。

    - (a) **委譲対象の確定**：step 5 でリッチ判定に該当し opt-out でない図版を列挙し、`fig-NN` を**親が事前採番**する（SVG marker id `figNN-ah` の一意性も担保）
    - (b) **ハーネス生成（1 回）**：`assets/template-slides.html` の `:root` 全トークン（確定テーマで `--accent` / `--accent-soft` / `--accent-bg` の 3 変数のみ上書き。Slide Deck は 5 テーマ共通の統一シャシなので、非 Mono テーマでも他変数の差し替えは不要）＋`.fig-wrap`/`.fig-canvas`（`--fa-*` ランプ含む）＋Google Fonts link＋Content スライド枠（title-bar＋message＋図版スロット）を含む単一スライド HTML を `/tmp/slide-figs-<id>/harness.html` に書く。Content スライド枠の `<section>` には **`fig-slide` クラスを付ける**（図が縦領域を使い切れているかをワーカーが正しく検証できる）。**ハーネスの body は `padding:0`** にする（padding があると 1280px の `.slide` が viewport からはみ出し、`overflow:hidden` が図版の両端を切る「偽クリップ」が出る。検証済みの落とし穴）。**テンプレ等から既存の `<style>…</style>` を流用する場合、それをさらに `<style>` で再ラップしない**（二重 `<style>` は `:root` トークンブロックを丸ごと無効化し、図が無配色で崩れる。検証済みの落とし穴）
    - (c) **ブリーフ書き出し**：図ごとに `/tmp/slide-figs-<id>/fig-NN/brief.json` を保存（フィールドは `agents/slide-figure-creator.md` の入力仕様：figId / slideTitle / slideMessage / figureContent（MD から忠実転記）/ structureType / richTrigger / layoutHint / themeName / accentValue / harnessPath / **diagramComponentsPath（絶対パス必須）** / screenshotScriptPath / fragmentOutPath / cropPngPath / workDir（図ごと分離）/ exemplarPaths（あれば））
    - (d) **並列起動**：1 メッセージで N 体の `slide-figure-creator` を同時に起動する
    - (e) **回収と統合**：各ワーカーの fragmentPath の内容を**丸ごと**対応スライドの図版スロットに貼る（フラグメントは `.fig-NN` スコープの `<style>`＋`.fig-wrap` の自己完結形式）。貼り先スライドの `<section class="slide">` には **`fig-slide` クラスを付ける**（縦中央・高さ充填。slide-deck.md「図版スライドは fig-slide で縦領域を使い切る」）。直組みで使っていた**旧 per-figure `.fig-NN` CSS は head から削除**しフラグメントに一本化する（プロパティ混線・class/SVG marker id 衝突の防止）。`effectiveHeight` が図版領域（≈440px）を大きく超える図は step 11 で重点確認する
    - (f) **フォールバック**：status が incomplete / failed のワーカー、またはサブエージェント起動不可の環境では、親が `references/diagram-components.md` に従って当該図を直組みする（従来パス）
    - 完了後、`/tmp/slide-figs-<id>/` は親が一括クリーンアップする

    **委譲をスキップしてよい例外**（親が直組み）：① ユーザーが「シンプルでよい／軽くで」と指示（既存 opt-out と整合）② サブエージェントを起動できない環境、の 2 つのみ。「図が少ない・単純だから親が直組み」はしない（注意が希釈され縦が空く＝品質が落ちるため）。スキップ時も 1 図 1 サイクル（図単位で組んで都度検証）と `fig-slide` による縦充填は守る。

10. **ファイル書き出し**
    - **Vertical Document**：`<英語snake_case>_document.html` または `_report.html` 形式で保存
    - **Slide Deck format**：`<英語snake_case>_slides.html` 形式で保存
    - 出力先は **入力 MD と同じディレクトリがデフォルト**。それ以外はユーザーに確認
    - `{name}.md` — 新規生成時のみ作成（既存 MD は触らない）

11. **ビジュアル検証（必須）**

    生成後に Claude 側で以下を確認してから「完了」と宣言する。

    - **レンダリング確認**: ブラウザでスクリーンショットを撮影（Playwright/Puppeteer 等）し、レイアウト崩れ・色違い・はみ出し・重なりがないか目視
    - **図解の接続・整列**（Slide Deck の作り込み図版）: はみ出しゼロだけで合格にしない。辺の両端がノード縁に接続しているか・注釈/バッジがアンカーに隣接しているか・図が図版領域を使い切っているかまで見る（チェックリストは diagram-components.md「検証」）
    - **委譲時の役割分担**（step 9.5 を使った場合）: 図版単体の検証はワーカーが完了済みなので親は再検証しない。親は**統合検証**を担う — スライド全景のサンプリング、プレゼンチャーム/カウンタ/サムネイル、`scrollWidth`/`clientWidth` による横はみ出し機械測定、図版とテキスト（message / body-list）の重なり、`fig-NN`・SVG marker id の重複が組み上がったデッキ内でゼロであること
    - **元との比較**（PPTX 再現・既存 HTML 改修など、元レイアウトがある場合）: 元画像・元期待値と並べて差分を確認
    - **インタラクション確認**（Slide Deck format の場合）: ページ送り、文字選択、ハイライト、サムネイル一覧、URL ハッシュ深リンクが意図通りに動くか
    - **修正サイクルでも同様**: 「ズレを修正しました」と宣言する前に再レンダリングして確認。修正→検証はペアで実行
    - **大量生成（10 章/10 スライド以上）**: 先頭・中央・末尾＋目立つ図のあるページのサンプリングでよい
    - **提出前最終検査（`/final-check`）からの再検証**: クライアント提出直前に本スキルの生成 HTML を検査する場合も、レイアウト崩れ（はみ出し・見切れ・重なり・図解の矢印崩れ）の確認は本 step 11 の手順をそのまま再実行する。文言側の検査（出典照合・断定トーン・メタ言及・AI臭表現）は quality-reviewer が担うため、ここでは行わない
    - 問題があれば修正してから完了宣言。ユーザーへの `open {name}.html` 案内はそのうえで行う

12. **公開への引き渡し（任意）**
    - ユーザーが共有 URL 公開まで望む場合は、出力 HTML パスを `html-publish` スキルに渡す（`--html {path}` ほか）。本スキルでは公開（Cloudflare Pages デプロイ・manifest 更新・機密二段階確認）は行わない。
    - 本スキルの HTML 出力規約（下記 Guardrails の「HTML 出力規約」）を守って生成すれば、`html-publish` 側の HTML 静的検証はそのまま通る。

## Outputs

- `{name}.html` — 自己完結 HTML アーティファクト（業務文書スタイル）
- `{name}.md` — Markdown ソース（新規生成時のみ作成、既存は保持）

出力ファイルパスを明確に最終メッセージに含める。共有 URL が必要な場合は `html-publish` に引き渡す。

## アウトプットの命名規則

`<内容を表す英語snake_case>_document.html` または `_report.html` 形式。

**例**：
- `travel_ai_poc_proposal.html`（提案書）
- `q3_market_analysis_report.html`（調査レポート）
- `org_change_announcement.html`（社内通達）
- `2026_strategy_memo.html`（戦略メモ）
- `vendor_selection_decision.html`（意思決定文書）
- `kickoff_meeting_notes.html`（議事メモ）

**Slide Deck format の例**：`<英語snake_case>_slides.html`
- `kickoff_meeting_slides.html`（キックオフ投影資料）
- `2026_strategy_memo_slides.html`（戦略メモのプレゼン版）
- `vendor_review_slides.html`（ベンダー選定報告のスライド）
- `investor_pitch_slides.html`（投資家ピッチ：Slide Deck × Mono テーマ）

## Guardrails

### HTML 出力規約

- **`<link rel="stylesheet">` は原則禁止**。**ただし Google Fonts（`fonts.googleapis.com`）に限り例外で許可**（Noto Sans JP / JetBrains Mono の読み込みのため）
- `<script src="https://...">` は font 系（fonts.googleapis.com）以外禁止
- `font-family` は **Noto Sans JP（本文・見出しすべて）／ JetBrains Mono（数値・章番号・コード・ID）**。Noto Serif JP・Meiryo 等の追加フォントは使わない
- 背景は **Vertical Document 非 Mono = `#fafaf6`（紙質クリーム） / Vertical Document Mono と Slide Deck 全テーマ = `#ffffff`（純白）**。上記以外で純白を使わない（パネル要素のみ可）
- 本文色は **Vertical Document 非 Mono = `#1a1c20`（チャコール） / Vertical Document Mono と Slide Deck 全テーマ = `#1a1a1a`（純黒に近い）**。純黒 `#000000` は使わない
- アクセントは 1 色のみ。区別は罫線・配置・ラベルで行う
- `@media print` を必ず定義する（sticky 解除、page-break-inside avoid）
- アクセシビリティ：`lang="ja"`、見出しレベル順守、リンクテキストが意味を持つ
- 絵文字は一切使わない（記号は `●■◆＋×✓` 等のみ）

**Google Fonts 例外規約の正本は `references/design-system.md`**（「オフライン擬似自己完結」）。本ファイルのリストは要約。この例外は公開スキル `html-publish` の検証実装（`scripts/publish.sh` の正規表現＋`references/publish-flow.md` の HTML 検証表）と同期しているため、**文言を変更する場合は design-system.md と html-publish 側を必ず同期**する。

### 文体

- Markdown の論点・主張・事実関係・数字を改変しない
- AI らしい強い表現（「革新的な」「画期的な」「飛躍的に」等）は中立表現に置換
- 著者の意図したセクション順序を保つ
- 編集的なキャッチコピーは避け、「〜である」「〜する」の業務文体を維持

### デザイン禁止パターン（マガジン化・装飾化の排除）

| 禁止事項 | 理由 |
|---------|------|
| 巨大な装飾数字（200px超） | 編集デザイン化する。最大 46px（cover-title）まで |
| イタリック装飾フォント | 業務文書には不要 |
| 章タイトル内の単語色分けの多用 | アクセントは控えめに |
| アシンメトリックなレイアウト | 整然としたグリッドのみ |
| 背景画像・グラデーション | 単色のみ |
| 回転・斜め配置・浮遊要素 | すべて水平・垂直配置 |
| 派手なホバーアニメーション | リンク色変更程度に留める |
| 複数のアクセント色 | 1 色のみ |
| 表のゼブラストライプ（行交互の塗り分け） | Web UI 的に見える。罫線のみで区切る |
| 最終セクションのダーク背景（Web のフッター風） | 業務文書では紙面のトーンを最後まで保つ。Summary もクリーム背景 |
| **対称的な並列対比でのダーク背景**（買い手 vs 買われ側、メリット vs デメリット、A案 vs B案 等） | 両側を読み比べる文脈ではダーク側の可読性が落ちる。両側ともライト背景（`--bg-alt` / `--panel`）に統一し、強調はアクセントボーダーで行う。<br>**例外**：State Grid #11 の As-Is → To-Be のように「現状 vs 目指す姿」で **To-Be 側にだけ重みを置きたい非対称な比較**は `.state-box.target` のダーク使用可 |

### Slide Deck format 出力時

- **キャンバスは 1280×720 px 固定**（HD 16:9）。テーマや内容によらず変えない
- **1 スライド 1 メッセージを厳守**する。1280×720 に対して情報量を詰めすぎない（メッセージは 17px、本文リストは 14.5px 目安）
- 縦長スクロールを意図したコンポーネント（Roadmap 詳細を 12 行、Flow with Margin 全体など）は **複数スライドに分割**する
- スライド外背景（ビューポート余白）は **5 テーマ共通で `#e5e5e5` 薄グレー**（統一シャシではスライド内が純白のため、暗地との過剰コントラストを避ける）
- 印刷時に「1 スライド = 1 ページ」が崩れないこと（`@page size: 1280px 720px` と `page-break-after: always` を維持）
- プレゼンチャーム（カウンタ・操作ヒント・トグル・サムネイル）は印刷時に必ず `display: none`
- サムネイルパネルはスライドを `cloneNode(true)` で生成するため、`id` 属性の重複が発生しないよう **クローン時に `id` を全削除**する
- 詳細仕様と完成 JS は `references/slide-deck.md` を参照

### Slide Deck format のテーマ選定ガイド

Slide Deck format は **5 テーマ共通の統一シャシ**を使う。テーマ切替は `:root` の `--accent` / `--accent-soft` / `--accent-bg` の 3 変数のみで完結する（構造色・カード装飾・段階濃度は 5 テーマ共通で不動）。**既定は Mono**。

| テーマ | accent 値 | 主用途 |
|---|---|---|
| **Mono（既定）** | `#1a1a1a` | **投資家ピッチ、コンサル提案書、外部向けハイステークス資料、投影用スライド全般。参照デザイン（AI Biz Ops Partner / VisasQ figures）踏襲** |
| Terracotta | `#9d3617` | 社内提案・企画書・議事メモのスライド版（温かみを出したい場合） |
| Navy | `#1e3a5f` | 金融系・大企業向け正式報告、規程・通達のスライド |
| Forest | `#2a4f3a` | 調査結果報告、ESG・サステナビリティ系の説明会 |
| Charcoal | `#2d2d33` | テクニカル文書、システム提案、議事メモのスライド（Mono とほぼ同じ見た目、ごく僅かに暖色寄り） |

**Mono テーマと拡張コンポーネント（22〜25）の組み合わせ**：

コンサルピッチ・投資家ピッチの見え方は、**Slide Deck format × Mono テーマ × 拡張コンポーネント**で構成する。

- **Eyebrow Bar**（タイトル直上のメタラベル「SLIDE 05 / Competitive Positioning」）
- **Hero Number**（巨大数字の KPI showcase。「2,760 万円」「40%」を構図の主役に）
- **Takeaway Strip**（スライド最下部の結論バー。テーマ accent 色の帯。Mono テーマでは黒帯反転）
- **Annotation Pointer**（図解への矢印付き注釈「★ WHITE SPACE」等）

これらは他テーマでも使えるが、Mono テーマと組み合わせた時に最も映える。Vertical Document でも使用可。

**Mono テーマ使用時の注意**：
- `--accent-bg` が黒なので、Insight 等が反転表示になる。読みづらければ `.insight.flat` を使う
- Hero Number と KPI Row は併用しない（情報密度が重複する）
- Takeaway Strip は 1 スライド 1 つ、`.slide-foot` の直上に配置
- Annotation Pointer のアンカーは `position: relative` の図解要素内に配置すること

### 配置

- 生成ファイルの保存先は **入力 MD と同じディレクトリがデフォルト**。それ以外はユーザーに確認する
- 既存 Markdown ソースは上書きしない（HTML 派生物のみ更新）

## トラブルシューティング

- **章が多すぎて TOC が 3 列になりそう**：12 章を超えるなら、関連章を統合するか、第 2 目次（章内目次）を検討
- **コンポーネントが足りない**：components.md にない要素は既存 30 種の組み合わせで実現。新規 CSS は追加しない
- **色をもっと使いたい**：禁止。代わりに 5 テーマ（Terracotta / Navy / Forest / Charcoal / Mono）の切り替えを検討
- **派手にしてほしいと言われた**：本スキルは業務文書スタイル。マガジン風・装飾デザインは別アプローチで対応する
- **議事メモのような短い文書**：TOC と Summary を省略し、Cover→2〜4 章→Footer のシンプル構成にする
- **図解が単調な「箱の列」になる／元資料のようなリッチな図にしたい**：リッチ判定（diagram-components.md「図解の 3 層」）を確認し、作り込み図版（レイアウトパターン＋exemplar 方式）で組み直す
- **annotated-flow（縦長プロセス＋右側注釈）を作りたい**：Recipe E + Flow with Margin コンポーネント（components.md #21）
- **3 案比較を作りたい**：Recipe D + Proposal Card × 3、または Report Table + Rating Dots
- **実装計画を作りたい**：Recipe A + Roadmap + Proposal Card
- **公開したい / 共有 URL がほしい**：本スキルは生成のみ。出力 HTML パスを `html-publish` スキルに渡す

## References

詳細は以下を参照:
- `references/document-recipes.md` — Content Recipe A〜F（6 種の章構成）と Output Format（Vertical / Slide Deck）の判定フロー
- `references/design-system.md` — 配色・タイポ・5 テーマ（Terracotta / Navy / Forest / Charcoal / Mono）・印刷対応
- `references/components.md` — 30 種のコンポーネント仕様（基本 21 種＋拡張 4 種＋Slide Deck 統一シャシ 5 種）＋付録「Markdown → HTML マッピング」
- `references/diagram-components.md` — 図解の統合リファレンス（固定 8 図解＋リッチ判定＋レイアウトパターン 5 種＋作り込み図版 `.fig-NN`。exemplar 方式・濃淡ランプ・トークン化注意を含む）。**図版委譲時はワーカーにこのファイルの絶対パスを渡す**（agent にはスキル参照ファイルが自動プリロードされないため）
- `references/slide-deck.md` — Slide Deck format 専用。スライドシェル仕様・5 種スライド型・プレゼンチャーム CSS/JS 完成形
- `assets/template.html` — HTML スケルトン（Vertical Document 用。コピーして編集する）
- `assets/template-slides.html` — スライドデッキスケルトン（Slide Deck format 用。コピーして編集する）
- `assets/examples/travel_ai_poc.html` — 全コンポーネントを使った完成形のサンプル

公開フロー（Cloudflare Pages）は別スキル `html-publish` を参照。

## 関連スキルとの境界

| スキル | スコープ |
|--------|---------|
| `html-publish` | 本スキルが生成した HTML を Cloudflare Pages で共有 URL 化（HTML 静的検証・機密確認・manifest 管理。kono 私的インフラ専用） |
| `slide-structure-designer` | スライド構成を MD で設計（本スキルの上流。構成 MD を本スキルに渡して HTML スライド化） |
| `slide-figure-creator`（agent） | Slide Deck の作り込み図版を 1 図 1 エージェントで生成（本スキルの step 9.5 から並列起動。ブリーフ・ハーネスはファイル渡し） |
| `html-diagram-generator` | 記事用の図解 PNG 生成（外部スキル・用途が異なる） |
| `frontend-design` | アプリ UI（プロダクション級、本格的なフレームワーク利用） |
| `note-article-writer` | note.com 向け記事執筆（外部スキル） |
| `meeting-minutes-creator` | 会議メモから議事録の文章生成（HTML 化は本スキル） |
| ブランド pptx（`pptx` ラッパーのブランド版） | ネイティブ PowerPoint（.pptx）納品。本スキルが生成した Slide Deck HTML をデザイン見本に再現（外部スキル・インストールされていれば） |
| **本スキル（Vertical Document）** | 業務文書ドメイン（企画書・報告書・議事メモ・通達等）の縦長 HTML 化 |
| **本スキル（Slide Deck format）** | 同じデザインシステムで作る 16:9 HTML スライドデッキ（ブラウザ投影前提） |
