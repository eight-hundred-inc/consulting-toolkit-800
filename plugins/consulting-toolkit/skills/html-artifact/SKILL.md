---
name: html-artifact
description: >-
  Markdown を業務文書スタイルの自己完結 HTML アーティファクトに変換するスキル。コンサルティングファームの
  社内文書のような上品で構造的なデザイン（紙質クリーム背景・Noto Sans JP 統一フォント）で、
  企画書・提案書・報告書・調査レポート・戦略メモ・意思決定文書・議事メモ・社内通達・3 案比較・実装計画・
  業務プロセス文書を生成する。29 種の構造化コンポーネント（基本 21＋拡張 4＋Slide Deck 統一シャシ 4）と
  8 種の構造化図解（概念フロー、2x2 マトリクス、ピラミッド、ファネル、サイクル、ベン図、組織図、
  レイヤー積層図）をインライン HTML+CSS で埋め込め、同じデザインシステムで 16:9 HTML スライドデッキ
  （Slide Deck format, 1280×720。単スライド表示・キーボード送り・サムネイル一覧・URL ハッシュ深リンク・
  印刷対応）も生成できる。
  「HTML 化・HTML にして・HTML で作って」「ブラウザで開ける形式に」「自己完結 HTML」
  「企画書／報告書／議事メモ／調査結果／業務文書を HTML に」「社内向けの説明資料を作って」
  「ちゃんとした体裁のドキュメントにして」「3 案比較を作って」「実装計画を作って」「16:9 のスライドにして」
  「ブラウザでめくれるプレゼン」「HTML スライドデッキ」「投影資料を作って」「文書に図解を入れて」
  「概念フロー図」「4 象限マトリクスで整理して」「ピラミッド図」「ファネルで可視化」「ベン図で表現して」
  などのリクエスト時に使用する。生成した 16:9 デッキを見本に pptx へ変換する前提がある場合は
  PPTX 変換セーフモード（references/pptx-safe.md）を適用して崩れない HTML を生成する。既存 Markdown がある場合も対話的にゼロから作る場合も対応し、
  Markdown を Single Source of Truth として HTML を派生物として再生成できる。
  共有 URL 公開は `html-publish` スキルへ（本スキルは生成のみ）。
  マガジン風・編集デザイン風・派手な装飾のリクエストには使用しない。
---

# html-artifact

Markdown を業務文書スタイル（紙質クリーム背景＋Noto Sans JP 統一フォント）の自己完結 HTML に変換する（生成専用。公開フローは別スキル `html-publish`）。Markdown は読み切りの「レポート」、HTML は継続的に使える「インターフェース」として運用する。

本スキルの設計は **3 軸の直交した選択** で成り立つ。混同しないこと：

| 軸 | 選択肢 | 何を決めるか |
|---|---|---|
| **1. Content Recipe**（内容レシピ） | A〜F の 6 種 | どの章構成テンプレートを使うか（企画書 / 調査 / 戦略メモ / 意思決定 / 議事 / 通達） |
| **2. Output Format**（出力形式） | Vertical Document / Slide Deck | 縦長文書として読ませるか、16:9 スライドで投影するか |
| **3. Theme**（テーマ） | Terracotta / Navy / Forest / Charcoal / Mono / EightHundred | 配色・トーン（コンテンツとは独立） |

例：「企画書を投影資料にしたい・コンサル提案書らしい見た目で」→ Content Recipe A × Slide Deck × Mono テーマ。

## 上流・下流スキル（ワークフロー上の位置）

- **上流**：`slide-structure-designer`（スライド構成を MD で設計）→ その構成 MD を本スキルに渡して Slide Deck format で HTML スライド化できる。
- **下流（公開）**：生成 HTML を共有 URL にしたい場合は `html-publish` スキルに出力パスを渡す（Cloudflare Pages デプロイ・manifest 管理・機密確認は html-publish が担う）。
- **下流（PPTX）**：生成した Slide Deck HTML を「デザイン見本」として、ブランド pptx スキル（`pptx` をラップしたブランド版ラッパー。「html-artifact 参照モード」を持つもの）、または slide_generator の `make run_image_slide` でデザイン・レイアウトを再現した PPTX を作成できる。**この下流を通す前提がある場合は生成時に `references/pptx-safe.md`（PPTX 変換セーフ規約）を適用する**（変換器は HTML を読むのではなくブラウザ描画後の実 DOM 実測値だけを使うため、疑似要素の装飾・1 行を分けた横並び・`transform: scale` は必ず崩れる）。

## 読み込み順序（必須）

| 順序 | ファイル | 内容 |
|------|---------|------|
| 1 | 本ファイル（SKILL.md） | 全体方針・トリガー条件・ワークフロー・Guardrails |
| 2 | [references/document-recipes.md](references/document-recipes.md) | Content Recipe A〜F（章構成）と Output Format（Vertical Document / Slide Deck）の判定フロー。**種別判定はここから始める** |
| 3 | [references/design-system.md](references/design-system.md) | カラー・タイポグラフィ・6 テーマ（Terracotta / Navy / Forest / Charcoal / Mono / EightHundred）・印刷対応の CSS 仕様 |
| 4 | `${CLAUDE_PLUGIN_ROOT}/skills/_shared/slide-body-principles.md` | **ボディ（コンテンツエリア）のベースライン規範**（5 原則＋例外 2 つ＋数値換算表）。**Slide Deck format のみ必読**（Vertical Document は対象外） |
| 5 | [references/components.md](references/components.md) | 29 種のコンポーネント仕様（基本 21 種＋拡張 4 種＋Slide Deck 統一シャシ 4 種。HTMLスニペット付き）。**末尾に付録「Markdown → HTML マッピング」**（旧 markdown-html-mapping.md を統合） |
| 6 | [references/diagram-components.md](references/diagram-components.md) | **図解の統合リファレンス**：固定 8 図解（概念フロー・2x2・ピラミッド・ファネル・サイクル・ベン図・組織図・レイヤー）＋**リッチ判定**（作り込み図版を既定とする条件）＋**レイアウトパターン**（スイムレーン/マトリクス/カード/ステップ/タイムライン。image-generator-guide 取り込み）＋**作り込み図版**（`.fig-NN` per-figure。exemplar 方式・トークン化注意を含む）。図解が必要なときに参照 |
| 7 | [references/slide-deck.md](references/slide-deck.md) | Slide Deck format 専用。16:9 スライドシェル仕様（1280×720・5 種スライド型・プレゼンチャーム CSS/JS 完成形・印刷対応） |
| 8 | [assets/template.html](assets/template.html) | Vertical Document 用スケルトンテンプレート（プレースホルダー付き。必ず複製してから編集） |
| 9 | [assets/template-slides.html](assets/template-slides.html) | Slide Deck format 用テンプレート（5 枚スケルトン＋プレゼンモード CSS/JS＋図解スキャフォルド（fig-canvas / dgram-* / 高さ補正）） |
| 10 | [assets/examples/travel_ai_poc.html](assets/examples/travel_ai_poc.html) | 全コンポーネントを使った完成形のサンプル（参考用） |
| 11 | [references/pptx-safe.md](references/pptx-safe.md) | **PPTX 変換前提のときのみ必読**（Slide Deck format 限定）。ネイティブ pptx へ変換する見本として使う HTML の追加規約（疑似要素の装飾禁止・1 行を分けない・`transform: scale` 禁止・面は直角（2 色構成カードの角丸禁止）・表罫線の統一・折り返し余白・機械検査コマンド） |

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
- **あとで pptx に変換する見本として** 16:9 スライド HTML を作りたい（Slide Deck format × PPTX 変換セーフモード。`references/pptx-safe.md`）
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
- **任意**: クライアント名、Content Recipe（A〜F）、Output Format（Vertical Document / Slide Deck）、テーマ（Terracotta / Navy / Forest / Charcoal / Mono / EightHundred）、**PPTX 変換セーフモード**（この HTML を見本に pptx へ変換する予定があるか。既定はオフ）

入力が不足している場合は最大 2 問だけ質問する（テーマ、用途）。用途の質問で「pptx にも展開する」旨が示された場合は PPTX 変換セーフモードをオンにする。

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

   2b-2. **PPTX 変換セーフモードの判定**（Slide Deck format のときのみ）
   - この HTML を**見本としてネイティブ pptx へ変換する予定**（`make run_image_slide` に渡す／ブランド pptx スキルの html-artifact 参照モードに渡す／「pptx にも展開したい」「PowerPoint 版も要る」等）があるなら **PPTX 変換セーフモードをオン**にし、`references/pptx-safe.md` を読み込んで以降の全工程に適用する
   - ブラウザ投影で完結する通常のデッキでは**オフのまま**にする（表現の幅が狭くなるため、必要でないときは適用しない）
   - 判定が曖昧なときはオフを既定とし、その旨を 1 行で伝える（あとからオンにして作り直すより、用途を確認するほうが早い）

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
   - **レイアウト割付（Slide Deck format では必須の先行工程）**：スライドを組み始める前に、`${CLAUDE_PLUGIN_ROOT}/skills/slide-pattern-creator/library/SLIDE-PATTERN-INDEX-COMPACT.md`（1 行/パターンの軽量インデックス）を読み、全スライドの割付表（# / タイトル / 内容構造 1 行 / 割付 / 理由 1 行）を作ってから実装に入る。スライドごとに：①**構造翻訳を先に行う** — ボディの内容構造（対比／分類／フロー／表／並列強調 等）を 1 行で言語化する。テーブル記法だからテーブル系、箇条書きだからリスト系、と**記法に引きずられない**（内容が対構造なら並置系、流れならフロー系を優先検討）。**この構造翻訳と候補出しには同ディレクトリの `SLIDE-PATTERN-INDEX-BY-LOGIC.md`（メッセージの述語 → 論理型 → パターン候補の逆引き）を使う**——COMPACT は視覚形式で並んでいるため「言いたいこと」からは引けない。②割付は (a) **ライブラリの実在パターン名**（インデックスから verbatim コピー。**名前の発明・改変は禁止**）を既定とし、構造化図版が主役のスライドは (b) `fig-slide`、どのパターンにも合わない場合のみ (c) `自由記述`＋理由 1 行（無理に当てはめて情報を落とすくらいなら (c) を選ぶ）。構成MDに `パターン指定:` が既にあるスライドはそれを優先する。割付表は完了報告に含める（別ファイルにはしない）
   - **割付の 3 規範（割付と不可分。これを守らない割付は自由記述に劣る＝実測）**：(1) **パターンは出発点であって上限ではない** — 列数の増減・ピル/バッジ追加など内容に合わせた拡張は可。禁止は「見出し＋箇条書き素組み」への退行のみ。full/light のような 2 値属性はテキストでなくピル（黒塗り/白抜き）で可視化する。(2) **縦充填** — コンテンツエリア（タイトル行下〜フッター上、約 560px）を使い切る。パターン既定寸法が小さければ行高・パディング・フォント・要素間マージンをスケールアップし、下部に約 120px 超の空白を残さない（表紙・まとめも中央寄せ等で上重心を避ける。並置カード内部の上寄り・中空きも直す）。スケールアップ後に残る縦の余りは、テンプレ標準搭載の `.slide.vfill`＋`.vgrow`（縦中央/均等配分。slide-deck.md「非図版スライドの縦充填」）で吸収する（図版スライドは `fig-slide`）。(3) **意味の忠実性** — 手順でない項目（性質・補足・横断的な話）をステップに混ぜず、注記・コールアウトに分離する。並列カードの見出し帯の色・濃度は揃える（濃淡ランプは段階・進行など意味のある差にのみ使う）。表紙はサブタイトルとカバーメタで同じ情報を二重に書かない。**単調性ガード**：非図版コンテンツスライドで同一構図を 3 枚以上連続させない／body-list 素組みは非図版コンテンツスライドの半数以下
   - > 根拠：盲検レビュー実験（2026-07-17）で、素朴なパターン当てはめは自由記述に敗れたが、3 規範を加えた本ルールは自由記述を上回った。3 規範は割付の付属品ではなく勝敗を分けた本体
   - **パターン指定の解釈（スケルトンHTMLは任意採寸）**：入力の構成MDに `パターン指定: SLIDE-PATTERN-{name}` がある場合、まず **パターン名と構成MDの図版指示から** コンテンツエリア構造（エリア分割・要素配置）を組む。**構造の決定権は「構成MDのパターン指定＋図版指示」が正本**であり、`${CLAUDE_PLUGIN_ROOT}/skills/slide-pattern-creator/library/` のスケルトンHTMLは **既定では開かない**。列比・固定幅・多段の高さ配分など **比率の採寸に迷うときだけ**、該当スケルトンHTMLを採寸源として任意参照する（高密度パターン＝references-table / stacked-bar 60/40 / two-lane-pipeline 等）。優先順位は **構成MD構図 ＞ 図版指示 ＞ HTML寸法採寸**（slide-pattern-creator の正本ルールと同じ）。部品の実装は components.md / diagram-components.md から充当する。パターン指定がないスライドは、上記レイアウト割付で決めた割付（実在パターン名／fig-slide／理由付き自由記述）に従って組む
   - > 根拠：実験4で、スケルトンHTMLを読まずに構成MDのパターン指定＋図版指示だけで組んでも品質差は僅差で入力トークンは約半減だったため、必須参照から任意採寸に格下げした
   - 各章の内容に最適なコンポーネントを `references/components.md` の 29 種（基本 21 種＋拡張 4 種＋Slide Deck 統一シャシ 4 種）から選ぶ
   - **拡張コンポーネント（22〜25：Eyebrow Bar / Hero Number / Takeaway Strip / Annotation Pointer）**：Slide Deck format × Mono テーマで最も映えるが、他のテーマや Vertical Document でも使ってよい
   - **統一シャシ 4 種（#26 Filled-Header Card / #27 Value Bar / #29 Pill Tag / #30 Expansion Pills。#28 Icon Chip は廃止）**：**Slide Deck 全 6 テーマ共通**（`--accent` に自動追従）。参照デザイン（AI Biz Ops Partner / VisasQ figures）踏襲時の主役コンポーネント。Vertical Document には適用しない。**#26 Filled-Header Card はカード内カード構造のため、図版の見せ場（ベースライン規範 例外①）としてのみ主役に使う**（components.md #26 のルール参照）
   - **構造化図解の積極利用**：章内容が図解向きならまず `references/diagram-components.md` の 8 種（概念フロー・2x2 マトリクス・ピラミッド・ファネル・サイクル・ベン図・組織図・レイヤー積層図）を検討する。テキスト＋表だけで埋めない
   - **作り込み図版（Slide Deck format・リッチ判定で既定）**：Slide Deck では、①ノードが属性を 2 つ以上持つ（名称＋役割＋正本/状態 等）②辺・受け渡しに意味のあるラベルが付く ③レーン・時間軸・2 軸など次元が 2 つ以上 ④ 1 要素だけを強調するヒーロー対比 — のいずれかに当てはまるメッセージは、**固定 8 図解で形式上表現できても作り込み図版を既定**とする（判定の詳細は `references/diagram-components.md`「図解の 3 層」）。組み方は diagram-components.md 後半のレイアウト原則（**構造型で選ぶ**：並置・ステップ・マトリクス等は flow、関係図・アーキ・ハブ&スポーク・レーン跨ぎ曲線は absolute＋SVG 第一候補。image-generator-guide 踏襲）／作図文法に従い、**出来の良い既存図版があれば exemplar として参照する**（同「exemplar 方式」。型に当てはめて情報を落とさない）。配色は `--fig-accent` 由来 + `--good`/`--warn` に限定（テーマ追従・**多色禁止は維持**）。固定 8 図解は単一関係・単一次元の概念図に限って使う。**Slide Deck format では、固定 8 図解か作り込み図版かに関わらず、すべての構造化図版を step 9.5 で専用ワーカー `slide-figure-creator` に委譲する**（リッチ判定はここでは図のレイヤーを決める設計ガイドであって、委譲するか否かのゲートではない。レイヤーの最終判断はワーカーが 3 層ルールで行う）
   - **図解密度ガイド**（議事メモ・通達・短文の速報系を除く全ドキュメントに適用）：
     - 章数 5 以下 → **最低 1 個** の構造化図解を含める
     - 章数 6〜10 → **2〜3 個** を目安
     - 章数 11+ → **3〜5 個** を目安
     - **Slide Deck format**：1 スライド 1 メッセージの原則に従い、**メッセージが構造的（フロー／対比／階層／サイクル等）なら原則として図解化**する。テキスト箇条書きで終わらせない
     - 議事メモ・通達など短文/速報系は **無理に入れない**（合意事項やプロセスが図解向きなら 1 個まで）
   - Markdown パターンから自動で割り当てる場合は `references/components.md` 末尾の付録「Markdown → HTML マッピング」を参照（章内容が図解向きと判定されたら原則として図解に置換する）

6. **テーマ選択**
   - **既定はすべて Mono**（Vertical Document / Slide Deck format 共通）。Slide Deck format は 6 テーマ共通の統一シャシ（構造色・カード装飾は不動）で、`--accent` / `--accent-soft` / `--accent-bg` の 3 変数＋帯・マーカー 3 トークン（`--band-bg` / `--band-ink` / `--marker-bg`）が palette 差分になる（Terracotta を選べば同じ Filled-Header Card がテラコッタ帯で描画され、Mono では薄グレー帯＋黒文字＋蛍光黄マーカーになる）。他 5 テーマ（Terracotta / Navy / Forest / Charcoal / EightHundred）は色味を変えたい場合の任意の代替パレット。用途に応じた使い分けは規定しない。**EightHundred のみ `--font-jp` も切り替わり、本文・見出しフォントが Meiryo UI になる**（クライアントブランド固有テーマ。詳細は design-system.md「Theme 6」）
   - **EightHundred は Slide Deck format のフレーム（Cover・title-bar・footer・ロゴ）も実クライアント PPTX に準拠する唯一のテーマ**：他 5 テーマは配色のみの差分だが、EightHundred は Cover の全面ダークグリーン化・title-bar の日本語アイブロウラベル・footer のコピーライト表記・砦ロゴマーク（`.eh-logo` / `.eh-logo-badge`）まで上書きする。トークン・マークアップ例は design-system.md「EightHundred のフレーム仕様」、スライド型ごとの差分は slide-deck.md の該当節（1. Cover / 4. Content）を参照。Vertical Document では対象外（配色とフォントのみ反映）
   - 1 ドキュメント 1 テーマ

7. **テンプレート複製**
   - **Vertical Document**：`assets/template.html` を出力先ディレクトリ（入力 MD と同じディレクトリがデフォルト）にコピー
   - **Slide Deck format**：`assets/template-slides.html` を同じくコピーし、`references/slide-deck.md` のスライド型ガイドに従ってスライドを増減する
   - `{{プレースホルダー}}` を実際のコンテンツに置換
   - 不要なセクションは削除、必要に応じて components.md からコンポーネントを追加
   - **PPTX 変換セーフモードがオンの場合**：コンポーネントをそのまま貼らず、`references/pptx-safe.md` の変換セーフ形に直してから貼る（`li::before` のマーカーは行のテキストへ、行頭の ✓・章番号は本文と同じテキストノードへ、カードは `background-color` ＋ `border` の両方を持たせる、角丸カードは部分丸め＋重ね合わせをやめて 1 要素・4 隅同一半径にする、report-table 等の表はセルごとの罫線差を無くして統一する）

8. **デザインシステム適用**
   - `references/design-system.md` の配色・タイポ・スペーシング仕様に従う
   - 背景は `#fafaf6`（Mono テーマでは `#ffffff`）、本文は `#1a1c20`、アクセントは 1 色のみ
   - **フォント：本文・見出しすべて Noto Sans JP / 数値・章番号・コード JetBrains Mono**
   - 絵文字は使わない

9. **Markdown → HTML 変換**
   - `references/components.md` 末尾の付録「Markdown → HTML マッピング」に従い、MD ブロックを HTML コンポーネントに割り当てる
   - AI らしい強い表現（「革新的な」「画期的な」等）を自動で中立化
   - 章番号・小番号を自動付与（01, 02 / 1.1, 1.2 …）

9.5 **図版の委譲生成（Slide Deck format・全構造化図版）**

    Slide Deck format の**すべての構造化図版**（固定 8 図解～作り込み図版まで、リッチ判定に関わらず）は、**必ず 1 図 1 体の専用ワーカー `slide-figure-creator`（agent）に委譲する**（例外は下記 1 つのみ）。デッキ全体を組みながら親が片手間に直組みすると、1 図あたりの注意が希釈され、図が縦領域を使い切れず（上 1/3 に縮こまり下半分が空白）品質が明確に落ちる（実測。図単位の設計・クロップ検証・反復を委譲で担保する）。図のレイヤー（固定 8 図解／レイアウトパターン／作り込み図版）はワーカーが 3 層ルールで判断する。

    - (a) **委譲対象の確定**：step 5 で選定した全構造化図版（固定 8 図解を含む）を列挙し、`fig-NN` を**親が事前採番**する（SVG marker id `figNN-ah` の一意性も担保。単純な固定 8 図解にも採番する）
    - (b) **ハーネス生成（1 回）**：`assets/template-slides.html` の `<style>` **全体をそのまま用いる**（`:root` 全トークン＋`.fig-wrap`/`.fig-canvas`（`--fa-*` ランプ含む）＋**固定 8 図解・レイアウトパターン・コンポーネントの CSS** を含む。確定テーマで `--accent` / `--accent-soft` / `--accent-bg` の 3 変数＋非 Mono なら帯・マーカー 3 トークン（`--band-bg:var(--accent); --band-ink:#fff; --marker-bg:var(--accent-bg);`）を上書き（EightHundred のみ `--font-jp` も上書き）。Slide Deck は 6 テーマ共通の統一シャシなので、それ以外の変数の差し替えは不要）＋Google Fonts link＋Content スライド枠（title-bar＋message＋図版スロット）を含む単一スライド HTML を `/tmp/slide-figs-<id>/harness.html` に書く。**8 図解 CSS を含めることで、単純な固定 8 図解を割り当てられたワーカーもハーネス内で検証できる**（全図版委譲の前提）。Content スライド枠の `<section>` には **`fig-slide` クラスを付ける**（図が縦領域を使い切れているかをワーカーが正しく検証できる）。**ハーネスの body は `padding:0`** にする（padding があると 1280px の `.slide` が viewport からはみ出し、`overflow:hidden` が図版の両端を切る「偽クリップ」が出る。検証済みの落とし穴）。**テンプレ等から既存の `<style>…</style>` を流用する場合、それをさらに `<style>` で再ラップしない**（二重 `<style>` は `:root` トークンブロックを丸ごと無効化し、図が無配色で崩れる。検証済みの落とし穴）
    - (c) **ブリーフ書き出し**：図ごとに `/tmp/slide-figs-<id>/fig-NN/brief.json` を保存（フィールドは `agents/slide-figure-creator.md` の入力仕様：figId / slideTitle / slideMessage / figureContent（MD から忠実転記）/ structureType / richTrigger（該当条件。単純な図で該当なしなら `none` を渡す＝ワーカーは固定 8 図解レイヤーを想定）/ layoutHint / themeName / accentValue / harnessPath / **diagramComponentsPath（絶対パス必須）** / screenshotScriptPath / fragmentOutPath / cropPngPath / workDir（図ごと分離）/ exemplarPaths（あれば））
    - (d) **並列起動**：1 メッセージで N 体の `slide-figure-creator` を同時に起動する
    - (e) **回収と統合**：各ワーカーの fragmentPath の内容を**丸ごと**対応スライドの図版スロットに貼る（フラグメントは `.fig-NN` スコープの `<style>`＋`.fig-wrap` の自己完結形式）。貼り先スライドの `<section class="slide">` には **`fig-slide` クラスを付ける**（縦中央・高さ充填。slide-deck.md「図版スライドは fig-slide で縦領域を使い切る」）。直組みで使っていた**旧 per-figure `.fig-NN` CSS は head から削除**しフラグメントに一本化する（プロパティ混線・class/SVG marker id 衝突の防止）。`effectiveHeight` が図版領域（≈440px）を大きく超える図は step 11 で重点確認する
    - (f) **フォールバック**：status が incomplete / failed のワーカー、またはサブエージェント起動不可の環境では、親が `references/diagram-components.md` に従って当該図を直組みする（従来パス）
    - (g) **PPTX 変換セーフモードがオンの場合**：ブリーフに `pptxSafe: true` と `references/pptx-safe.md` の絶対パスを含め、ワーカーに同規約の適用を指示する（agent にはスキル参照ファイルが自動プリロードされないため diagramComponentsPath と同様に絶対パスで渡す）。図版で特に効くのは、**作り込み図版を `transform: scale` ではなく 1152px ネイティブで組むこと**（scale は矩形だけ縮み文字は縮まないため pptx で文字が溢れる）と、**辺・矢印を 1 枚のオーバーレイ SVG にまとめず 1 本ずつ独立要素にすること**（1 本ずつなら pptx のコネクタへ変換される）
    - 完了後、`/tmp/slide-figs-<id>/` は親が一括クリーンアップする

    **委譲をスキップしてよい例外は、サブエージェントを起動できない環境の 1 つのみ**。「シンプルでよい／軽くで」「図が少ない・単純だから」を理由に親が直組みすることはしない（全構造化図版をワーカーに委譲する）。「シンプルでよい」の要望は、委譲をスキップする理由ではなく、ワーカーが 3 層ルールで軽いレイヤー（固定 8 図解）を選ぶ設計上の指示として扱う。スキップ時（＝技術的フォールバック）も 1 図 1 サイクル（図単位で組んで都度検証）と `fig-slide` による縦充填は守る。

10. **ファイル書き出し**
    - **Vertical Document**：`<英語snake_case>_document.html` または `_report.html` 形式で保存
    - **Slide Deck format**：`<英語snake_case>_slides.html` 形式で保存
    - 出力先は **入力 MD と同じディレクトリがデフォルト**。それ以外はユーザーに確認
    - `{name}.md` — 新規生成時のみ作成（既存 MD は触らない）

11. **ビジュアル検証（必須）**

    生成後に Claude 側で以下を確認してから「完了」と宣言する。

    - **レンダリング確認**: 同梱の `image-generator-guide/scripts/screenshot.py` でレンダリングし、レイアウト崩れ・色違い・はみ出し・重なりがないか目視する。縦長文書・デッキ全体は `--pdf` で print CSS 適用の PDF に変換して確認（Slide Deck は `@media print` で 1 スライド 1 ページに展開される）、単一スライド・図版は `--selector`/`--out` で PNG 化して確認する
    - **コントラスト実測（必須。目視だけで済ませない）**: レンダリング後の DOM で全テキストノードの前景色と実効背景色を取り、コントラスト比が **3.0 未満**の箇所がゼロであることを機械的に確認する。**目視・スクリーンショットでは「地と同色で消えたテキスト」を見落とす**（消えている以上そこに文字があると気づけない）。CSS を静的に読む方式も DOM の入れ子を追えず取りこぼす（親の背景を誤って拾う）ため、**必ずレンダリング後の実測**で行う。実効背景は「不透明な背景色を持つ最も近い祖先」まで遡り、`color-mix()` の計算値（`color(srgb r g b)` 形式で返る）も解釈する。比 1.0 付近が出たら地と文字が同色＝判読不能なので必ず直す。原因の大半はテーマトークンの取り違えなので、`design-system.md`「`--accent-bg` の契約」を確認する
      ```python
      # Playwright での実測（要点。全スライドに .current を順に当てて評価する）
      # 1) 各要素の直下テキストノードだけを対象にする（親要素の重複計上を避ける）
      # 2) 実効背景 = alpha > 0.5 の背景色を持つ最も近い祖先（無ければ #fff）
      # 3) rgb()/rgba() に加えて color(srgb r g b) も parse する（color-mix の計算値）
      # 4) 相対輝度から比を出し、3.0 未満を列挙する
      ```
    - **縦充填・単調性の確認**（Slide Deck format）: 非図版スライドでコンテンツ下端とフッターの間に約 120px 超の空白が残っていないか、同一構図が 3 枚以上連続していないかを確認する（step 5「割付の 3 規範」）。違反は調整して再撮影
    - **図解の接続・整列**（Slide Deck の作り込み図版）: はみ出しゼロだけで合格にしない。辺の両端がノード縁に接続しているか・注釈/バッジがアンカーに隣接しているか・図が図版領域を使い切っているかまで見る（チェックリストは diagram-components.md「検証」）
    - **委譲時の役割分担**（step 9.5 を使った場合）: 図版単体の検証はワーカーが完了済みなので親は再検証しない。親は**統合検証**を担う — スライド全景のサンプリング、プレゼンチャーム/カウンタ/サムネイル、`scrollWidth`/`clientWidth` による横はみ出し機械測定、図版とテキスト（message / body-list）の重なり、`fig-NN`・SVG marker id の重複が組み上がったデッキ内でゼロであること
    - **PPTX 変換セーフ検査**（PPTX 変換セーフモードがオンの場合・必須）: slide_generator が入っている環境では `cd <slide_generator>/app/core && make run_html_pptx_lint SAMPLE_DIR=<出力HTMLのあるディレクトリ>` を実行し、**error 0 件**にしてから完了宣言する（同じ検査は `make run_image_slide` の実行時にも自動で走る）。slide_generator が無い環境では `references/pptx-safe.md` の「チェックリスト」を手で確認する。目視では気づけない崩れ（疑似要素のマーカー・1 行を分けた横並び・`transform: scale`）が対象で、**ブラウザ上は正しく見えていても pptx 化で必ず崩れる**ため、レンダリング確認では代替できない
    - **元との比較**（PPTX 再現・既存 HTML 改修など、元レイアウトがある場合）: 元画像・元期待値と並べて差分を確認
    - **インタラクション確認**（Slide Deck format の場合）: ページ送り、文字選択、ハイライト、サムネイル一覧、URL ハッシュ深リンクが意図通りに動くか
    - **修正サイクルでも同様**: 「ズレを修正しました」と宣言する前に再レンダリングして確認。修正→検証はペアで実行
    - **大量生成（10 章/10 スライド以上）**: 先頭・中央・末尾＋目立つ図のあるページのサンプリングでよい
    - **提出前最終検査からの再検証**: クライアント提出直前の検査は quality-reviewer エージェントの提出前最終検査モードが担う。同モードは本スキルの生成 HTML を screenshot.py の `--pdf`（print CSS 適用）で PDF 化してレイアウト崩れ（はみ出し・見切れ・重なり・図解の矢印崩れ）を確認する際、本 step 11「ビジュアル検証」の観点をそのまま検証基準として使う。文言側の検査（出典照合・断定トーン・メタ言及・AI臭表現）も同モードが同時に担う
    - 問題があれば修正してから完了宣言。ユーザーへの `open {name}.html` 案内はそのうえで行う

12. **公開への引き渡し（任意）**
    - ユーザーが共有 URL 公開まで望む場合は、出力 HTML パスを `html-publish` スキルに渡す（`--html {path}` ほか）。本スキルでは公開（Cloudflare Pages デプロイ・manifest 更新・機密二段階確認）は行わない。
    - 本スキルの HTML 出力規約（下記 Guardrails の「HTML 出力規約」）を守って生成すれば、`html-publish` 側の HTML 静的検証はそのまま通る。

## Outputs

- `{name}.html` — 自己完結 HTML アーティファクト（業務文書スタイル）
- `{name}.md` — Markdown ソース（新規生成時のみ作成、既存は保持）

出力ファイルパスを明確に最終メッセージに含める。共有 URL が必要な場合は `html-publish` に引き渡す。

## アウトプットの命名規則

`<内容を表す英語snake_case>_document.html` または `_report.html` 形式（例：`travel_ai_poc_proposal.html`、`q3_market_analysis_report.html`）。

**Slide Deck format**：`<英語snake_case>_slides.html`（例：`kickoff_meeting_slides.html`）

## Guardrails

### HTML 出力規約

- **`<link rel="stylesheet">` は原則禁止**。**ただし Google Fonts（`fonts.googleapis.com`）に限り例外で許可**（Noto Sans JP / JetBrains Mono の読み込みのため）
- `<script src="https://...">` は font 系（fonts.googleapis.com）以外禁止
- `font-family` は **`var(--font-jp)`（本文・見出しすべて。既定 Noto Sans JP）／ JetBrains Mono（数値・章番号・コード・ID）**。Noto Serif JP 等の追加フォントは使わない。**唯一の例外は EightHundred テーマ**で、`--font-jp` を Meiryo UI に切り替える（design-system.md「Theme 6: EightHundred」参照。Google Fonts 追加読み込みは不要）
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
- 見出し・リード文を新たに起こす場合は `${CLAUDE_PLUGIN_ROOT}/skills/_shared/writing-principles.md` の原則7（NG語彙・言い換え辞書）・原則8（メッセージ・クリスタライズ規範）に従う。Slide Deck のメッセージ行は単一主張の1文にし、辞書のNG語彙を避ける

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
| **塗り面だけで意味を伝える装飾アイコン**（1 文字コードの塗りチップ、テキストで足りる円形の番号・記号バッジ。旧 Icon Chip #28・旧 `.vb-icon` が該当） | 読み手に情報を足さず、pptx 変換では本文と別図形に分解されて縦位置が合わない（薄い塗りは色味も再現されない）。番号・記号・コードは**同じ行のテキスト**として直接書く。図解のノード番号・タイムラインのマーカー・凡例ドット・レーティングドットのように、位置や大小そのものが意味を持つ図形要素は対象外 |
| 面（カード・パネル・帯・バー）の角丸。とくに 2 色構成（塗りヘッダー帯＋本文）のカードの角丸 | 角丸と直角が混在して見え、pptx 変換では専用シェイプに分割される。面は直角（`border-radius:0`）。円・ピル形のチップのみ例外 |
| 表のゼブラストライプ（行交互の塗り分け） | Web UI 的に見える。罫線のみで区切る |
| 最終セクションのダーク背景（Web のフッター風） | 業務文書では紙面のトーンを最後まで保つ。Summary もクリーム背景 |
| **対称的な並列対比でのダーク背景**（買い手 vs 買われ側、メリット vs デメリット、A案 vs B案 等） | 両側を読み比べる文脈ではダーク側の可読性が落ちる。両側ともライト背景（`--bg-alt` / `--panel`）に統一し、強調はアクセントボーダーで行う。<br>**例外**：State Grid #11 の As-Is → To-Be のように「現状 vs 目指す姿」で **To-Be 側にだけ重みを置きたい非対称な比較**は `.state-box.target` のダーク使用可 |
| **1 つの `<ul>`/`<ol>` を `display:grid`（`grid-template-columns` 2 列以上）や `column-count` で多段組にする**（Scope Panel #12 等） | 同一オブジェクトの箇条書きが横並びに分断され、文単位の項目は読み順が縦→横で乱れ、丈が不揃いだと段ズレする。**箇条書きは常に単一列で縦積み**（`display:block` の既定フロー。項目間は `li{margin-bottom}` で確保）。項目を意味のある単位で 2 列に「並べたい」場合は 1 つの `<ul>` を割らず、**独立した `<ul>` を 2 つ並べる**（Two Column Compare 等、別オブジェクトとして扱う） |
| **面（カード・パネル・見出し）の辺の一部だけをアクセント色にする**（`border-left` / `border-top` 等、1 辺だけ `var(--accent)` にする「アクセント縦線・横線」。minor-head・insight・lede・qa-card・flow-note・dq-cell.accent・summary で過去に使用） | 装飾的な色付き罫線があちこちに増殖し「アクセントは 1 色・意味の区別にのみ」の原則が崩れる。**強調は罫線ではなく面全体のティント**（`background:var(--accent-bg)`）か**全周同色の中立罫線**（`border:1px solid var(--rule)`）で行う。カードの縁取りとして全周を `var(--accent)` にする（対称的な強調）のは可。意味のある警告表示（`--warn`）を辺の一部に使うのは例外として許可する |

### ボディのベースライン規範（Slide Deck format のみ）

Slide Deck format のボディ（タイトル行・メッセージ行より下のコンテンツエリア）は**ベースライン規範**に従う。正本は `${CLAUDE_PLUGIN_ROOT}/skills/_shared/slide-body-principles.md`（8 原則＋例外 2 つ＋数値換算表。読み込み順序表の 4 番）。

- 規範は**最低保証ライン（床）であって表現の上限ではない**。1 枚に部品 7 種・入れ子カード・強調 3 箇所のような散らかりを防ぐのが目的で、床の上に作り込むのは自由
- **例外①（図版の見せ場）**は `references/diagram-components.md` の**リッチ判定**と接続する：リッチ判定に該当する作り込み図版が主役のスライドでは原則 1（部品 3〜4 種）・原則 2（ネスト禁止）を適用せず、図版内部は diagram-components.md の規範に従う
- **例外②（ブランド禁則）**：テーマのアクセント運用（アクセントは 1 色・意味の区別にのみ）は原則 5 の「濃淡で階層を作る」より常に優先する
- **統一シャシ #26 Filled-Header Card**（`.phase-card` ＞ `.section` のカード内カード構造）は原則 2 のネスト禁止に該当するため、**例外①（図版の見せ場）としてのみ主役に使う**（components.md #26）
- **Vertical Document は本規範の対象外**（縦長文書のコンポーネント運用は components.md / design-system.md の規定のみ）

### Slide Deck format 出力時

- **キャンバスは 1280×720 px 固定**（HD 16:9）。テーマや内容によらず変えない
- **1 スライド 1 メッセージを厳守**する。1280×720 に対して情報量を詰めすぎない（メッセージは 17px、本文リストは 14.5px 目安）
- 縦長スクロールを意図したコンポーネント（Roadmap 詳細を 12 行、Flow with Margin 全体など）は **複数スライドに分割**する
- スライド外背景（ビューポート余白）は **6 テーマ共通で `#e5e5e5` 薄グレー**（統一シャシではスライド内が純白のため、暗地との過剰コントラストを避ける）
- 印刷時に「1 スライド = 1 ページ」が崩れないこと（`@page size: 1280px 720px` と `page-break-after: always` を維持）
- プレゼンチャーム（カウンタ・操作ヒント・トグル・サムネイル）は印刷時に必ず `display: none`
- サムネイルパネルはスライドを `cloneNode(true)` で生成するため、`id` 属性の重複が発生しないよう **クローン時に `id` を全削除**する
- 詳細仕様と完成 JS は `references/slide-deck.md` を参照

### PPTX 変換セーフモード（Slide Deck format のみ・任意）

生成 HTML を**見本としてネイティブ pptx へ変換する**予定があるときだけ適用する追加規約。正本は `references/pptx-safe.md`（読み込み順序表の 11 番）。ブラウザ投影で完結するデッキには適用しない。

規約が要る理由は 1 つで、**変換器は HTML を読まずブラウザ描画後の実 DOM 要素だけを実測する**ため、実測に載らない表現は pptx で必ず崩れる。守るべき骨子は 6 つ：

| 禁止 | 代わりに | 崩れ方 |
|---|---|---|
| `::before` / `::after` で描く箇条書きマーカー・罫線・矢印 | マーカーは行のテキストに直接書く（`● …`）／罫線はその要素の `border-top` / `border-bottom` | マーカーが消える・位置が本文からずれる |
| 1 行を「マーカー要素＋本文要素」に分ける（`<span>✓</span><span>本文</span>`） | 行を包む要素が本文のテキストノードを**直接**持つ（`<span>✓</span>本文`） | pptx では上下 2 段に分解され、枠を超えた側が消える |
| `transform: scale` を掛けた図版領域 | 1152px ネイティブで組む（`font-size` を直接小さく書く） | 矩形は縮み文字は縮まないため、文字だけ拡大されて溢れる |
| グラデーション背景・`box-shadow` だけの境界・`clip-path` / `filter` | `background-color` 単色＋`border` | 無地になる・境界が消える |
| 行ごとのアンダーライン（`border-bottom`）／字下げを `margin-left` で作る | 区切りは**行間**で表現する（行の罫線は付けない）／字下げは `padding-left`＋負の `text-indent` | 行ごとに線シェイプが増え、長さ・位置がばらつく／`margin-left` は箱ごとずれて罫線・背景が本文左端からずれる |
| 面（カード・パネル・帯・バー）の角丸。とくに **2 色構成（塗りヘッダー帯＋本文）のカードの角丸** | 面は**直角**（`border-radius:0`）にする。円形（`border-radius:50%`）とピル形のチップ／バッジのみ例外 | 上 2 角／下 2 角だけ丸める専用シェイプに強制分割され、継ぎ目に線が入る・重ねた 2 枚がずれる |
| セルごとに罫線の色・太さ・実線/点線を変える | 表全体で罫線を統一し、強調は `background-color` の差で出す | セルは個別図形に分解され、上辺以外の差分辺ごとに線シェイプが追加される＝罫線を変えるほどオブジェクト数が増える |

加えて **1 行のテキストは枠内幅の 9 割まで**（PowerPoint のテーマフォントは Web フォントより 1〜2 割字幅が広い）、**フォントは 11px 以上**、**図版の矢印は 1 本ずつ独立要素**（1 枚のオーバーレイ SVG にまとめない）。

**検査は機械で行う**：`cd <slide_generator>/app/core && make run_html_pptx_lint SAMPLE_DIR=<出力先ディレクトリ>` で error 0 件にする（step 11 参照）。目視・スクリーンショットでは検出できない。

### Slide Deck format のテーマ選定ガイド

テーマの既定・切替方式は step 6 のとおり（Mono 既定・accent 3 変数＋帯・マーカー 3 トークンの palette 差分）。accent 値：Mono `#1a1a1a`／Terracotta `#9d3617`／Navy `#1e3a5f`／Forest `#2a4f3a`／Charcoal `#2d2d33`。Mono は帯・マーカーの既定が他と異なる：構造帯（thead・phase-header・value-bar 等）は薄グレー `#e4e4e4`＋黒文字、語句強調は `<mark>`（蛍光黄 `#ffff00`、1 スライド 1〜2 箇所まで）、黒塗りは強強調（takeaway-strip 等）のみ。非 Mono 4 テーマは `--band-bg:var(--accent); --band-ink:#fff; --marker-bg:var(--accent-bg);`（slide-deck.md「テーマ切替」）。

**Mono テーマと拡張コンポーネント（22〜25）の組み合わせ**：

コンサルピッチ・投資家ピッチの見え方は、**Slide Deck format × Mono テーマ × 拡張コンポーネント**で構成する。

- **Eyebrow Bar**（タイトル直上のメタラベル「SLIDE 05 / Competitive Positioning」）
- **Hero Number**（巨大数字の KPI showcase。「2,760 万円」「40%」を構図の主役に）
- **Takeaway Strip**（スライド最下部の結論バー。テーマ accent 色の帯。Mono テーマでは黒帯反転＝黒塗りを許すのはこうした強強調のみ）
- **Annotation Pointer**（図解への矢印付き注釈「★ WHITE SPACE」等）

これらは他テーマでも使えるが、Mono テーマと組み合わせた時に最も映える。Vertical Document でも使用可。

**Mono テーマ使用時の注意**：
- Hero Number と KPI Row は併用しない（情報密度が重複する）
- Takeaway Strip は 1 スライド 1 つ、`.slide-foot` の直上に配置
- Annotation Pointer のアンカーは `position: relative` の図解要素内に配置すること

### 配置

- 生成ファイルの保存先は **入力 MD と同じディレクトリがデフォルト**。それ以外はユーザーに確認する
- 既存 Markdown ソースは上書きしない（HTML 派生物のみ更新）

## トラブルシューティング

- **章が多すぎて TOC が 3 列になりそう**：12 章を超えるなら、関連章を統合するか、第 2 目次（章内目次）を検討
- **コンポーネントが足りない**：components.md にない要素は既存 29 種の組み合わせで実現。新規 CSS は追加しない
- **色をもっと使いたい**：禁止。代わりに 6 テーマ（Terracotta / Navy / Forest / Charcoal / Mono / EightHundred）の切り替えを検討
- **派手にしてほしいと言われた**：本スキルは業務文書スタイル。マガジン風・装飾デザインは別アプローチで対応する
- **議事メモのような短い文書**：TOC も省略し、Cover→2〜4 章→Footer のシンプル構成にする（まとめ節は Vertical Document では既定で置かない）
- **図解が単調な「箱の列」になる／元資料のようなリッチな図にしたい**：リッチ判定（diagram-components.md「図解の 3 層」）を確認し、作り込み図版（レイアウトパターン＋exemplar 方式）で組み直す
- **annotated-flow（縦長プロセス＋右側注釈）を作りたい**：Recipe E + Flow with Margin コンポーネント（components.md #21）
- **3 案比較を作りたい**：Recipe D + Proposal Card × 3、または Report Table + Rating Dots
- **実装計画を作りたい**：Recipe A + Roadmap + Proposal Card
- **公開したい / 共有 URL がほしい**：本スキルは生成のみ。出力 HTML パスを `html-publish` スキルに渡す
- **pptx に変換したら見た目が崩れた（章番号や箇条書きの点が消える／行が上下に分解される／文字が枠から溢れる）**：HTML 側が PPTX 変換セーフでないことが原因。`references/pptx-safe.md` の 1〜3 節（疑似要素・1 行の分割・`transform: scale`）を直し、`make run_html_pptx_lint` で error 0 件にしてから再変換する。変換器の設定ではなく見本 HTML の書き方の問題なので、pptx 側をいじっても直らない
- **pptx に変換したらカードの継ぎ目に線が入る／2 枚に分かれてずれる**：カード（とくに塗りヘッダー帯＋本文の 2 色構成）に角丸が付いている（`references/pptx-safe.md` 8 節）。面は直角（`border-radius:0`）にする
- **pptx に変換したら表のオブジェクト数が異常に多い／表が重い**：セルごとに罫線の色・太さ・実線/点線が違う（`references/pptx-safe.md` 9 節）。表全体で罫線を統一し、強調は `background-color` で出す

## References

詳細は以下を参照:
- `references/document-recipes.md` — Content Recipe A〜F（6 種の章構成）と Output Format（Vertical / Slide Deck）の判定フロー
- `references/design-system.md` — 配色・タイポ・6 テーマ（Terracotta / Navy / Forest / Charcoal / Mono / EightHundred）・印刷対応。EightHundred のみ Cover/title-bar/footer/ロゴのフレーム仕様も含む
- `references/components.md` — 29 種のコンポーネント仕様（基本 21 種＋拡張 4 種＋Slide Deck 統一シャシ 4 種）＋付録「Markdown → HTML マッピング」
- `references/diagram-components.md` — 図解の統合リファレンス（固定 8 図解＋リッチ判定＋レイアウトパターン 5 種＋作り込み図版 `.fig-NN`。exemplar 方式・濃淡ランプ・トークン化注意を含む）。**図版委譲時はワーカーにこのファイルの絶対パスを渡す**（agent にはスキル参照ファイルが自動プリロードされないため）
- `references/slide-deck.md` — Slide Deck format 専用。スライドシェル仕様・5 種スライド型・プレゼンチャーム CSS/JS 完成形
- `references/pptx-safe.md` — PPTX 変換セーフ規約（Slide Deck format × pptx 変換前提のときのみ）。変換器が実測する項目・しない項目の対応表、NG→OK の書き換え例、`make run_html_pptx_lint` による機械検査。**図版委譲時は diagramComponentsPath と同様に絶対パスでワーカーに渡す**
- `${CLAUDE_PLUGIN_ROOT}/skills/slide-pattern-creator/library/SLIDE-PATTERN-INDEX-COMPACT.md` — レイアウト割付用の軽量パターンインデックス（1 行/パターン。Slide Deck format の step 5 で必読。正本は同ディレクトリの SLIDE-PATTERN-INDEX.md）
- `${CLAUDE_PLUGIN_ROOT}/skills/slide-pattern-creator/library/SLIDE-PATTERN-INDEX-BY-LOGIC.md` — 論理型からの逆引き索引（メッセージの述語 → 論理型 → パターン候補）。step 5 の構造翻訳で使う
- `${CLAUDE_PLUGIN_ROOT}/skills/_shared/deck-rhetoric.md` — デッキ全体を貫く約束事（識別子の貫通・現在地・再掲・確度表示・引用の器）
- `assets/template.html` — HTML スケルトン（Vertical Document 用。コピーして編集する）
- `assets/template-slides.html` — スライドデッキスケルトン（Slide Deck format 用。コピーして編集する）
- `assets/examples/travel_ai_poc.html` — 全コンポーネントを使った完成形のサンプル

## 関連スキルとの境界

| スキル | スコープ |
|--------|---------|
| `html-publish` | 本スキルが生成した HTML を Cloudflare Pages で共有 URL 化（HTML 静的検証・機密確認・manifest 管理。kono 私的インフラ専用） |
| `slide-structure-designer` | スライド構成を MD で設計（本スキルの上流。構成 MD を本スキルに渡して HTML スライド化） |
| `slide-figure-creator`（agent） | Slide Deck の全構造化図版（固定 8 図解～作り込み図版）を 1 図 1 エージェントで生成（本スキルの step 9.5 から並列起動。全図版を委譲。ブリーフ・ハーネスはファイル渡し） |
| `html-diagram-generator` | 記事用の図解 PNG 生成（外部スキル・用途が異なる） |
| `frontend-design` | アプリ UI（プロダクション級、本格的なフレームワーク利用） |
| `note-article-writer` | note.com 向け記事執筆（外部スキル） |
| `meeting-minutes-creator` | 会議メモから議事録の文章生成（HTML 化は本スキル） |
| ブランド pptx（`pptx` ラッパーのブランド版） / slide_generator `make run_image_slide` | ネイティブ PowerPoint（.pptx）納品。本スキルが生成した Slide Deck HTML をデザイン見本に再現（外部スキル・外部リポジトリ）。**渡す HTML は `references/pptx-safe.md` 準拠で生成する** |
| **本スキル（Vertical Document）** | 業務文書ドメイン（企画書・報告書・議事メモ・通達等）の縦長 HTML 化 |
| **本スキル（Slide Deck format）** | 同じデザインシステムで作る 16:9 HTML スライドデッキ（ブラウザ投影前提） |
