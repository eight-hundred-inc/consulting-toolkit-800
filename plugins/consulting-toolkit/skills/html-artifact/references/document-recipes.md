# Document Recipes — ドキュメント種別ごとの章構成

本ファイルは **Content Recipe（内容レシピ A〜F）** の章構成テンプレートと、それを **Output Format（Vertical Document / Slide Deck）** にどう載せるかを定義する。

判定は **2 段（内容 → 形式）+ テーマ選択** の順で行う。Theme（Terracotta / Navy / Forest / Charcoal / Mono）は内容レシピ・出力形式と直交した独立軸（詳細は `references/design-system.md`）。

## 判定フロー

### Step 1: Content Recipe（内容レシピ A〜F）を選ぶ

```
├─ 「提案」「PoC」「企画」「新規事業」「導入を検討」「計画」「Plan」「実装」
│  → 企画書・提案書（Recipe A）
│
├─ 「調査結果」「分析」「市場」「競合」「ベンチマーク」「報告」「Report」「Summary」
│  → 調査レポート（Recipe B）
│
├─ 「戦略」「方針」「論点整理」「検討事項」
│  → 戦略メモ・検討メモ（Recipe C）
│
├─ 「決定」「選択肢」「比較検討」「承認」「A案/B案」「3案比較」「Options」「Plan A/Plan B」
│  → 意思決定文書（Recipe D）
│
├─ 「議事録」「ミーティング」「打ち合わせ」「合意事項」「フロー」「プロセス」「手順」「Workflow」
│  → 議事メモ / プロセス文書（Recipe E）
│
└─ 「通達」「お知らせ」「変更案内」「制度説明」
   → 社内通達・説明資料（Recipe F）
```

迷ったときは **Recipe A（企画書）** をベースにする。最も汎用性が高い。

### Step 2: Output Format（出力形式）を選ぶ

```
ユーザーが「スライド」「プレゼン」「16:9」「ブラウザでめくる」「投影資料」「HTML デッキ」「コンサル提案書」「投資家ピッチ」を求めているか？

├─ Yes → Slide Deck format（1280×720 16:9 HTML スライド）
│        詳細仕様は references/slide-deck.md、テンプレートは assets/template-slides.html
│
└─ No  → Vertical Document（縦長文書、デフォルト）
         テンプレートは assets/template.html
```

Slide Deck format でも内容構成は Step 1 で決めた Content Recipe をそのまま使う（例：Content Recipe A × Slide Deck format）。

### Step 3: Theme（テーマ）を選ぶ

5 テーマから 1 つ。1 ドキュメントに 1 テーマだけ。

| Theme | 主な使い分け |
|---|---|
| Terracotta（デフォルト） | warm consulting — 迷ったらこれ |
| Navy | 金融・大企業・通達 |
| Forest | 調査・ESG・学術 |
| Charcoal | テクニカル・議事メモ |
| **Mono** | **投資家ピッチ・コンサル提案書（旧 Pitch Mode 相当）** |

詳細は `references/design-system.md` を参照。

## エイリアス（後方互換）

| 旧表現 | 現在の表現 |
|---|---|
| Recipe G | Slide Deck format |
| Pitch Mode / Mode B / Consulting Pitch | Slide Deck format × Mono テーマ |
| Mode A / Business Document | Slide Deck format × Terracotta/Navy/Forest/Charcoal のいずれか |

旧表現でリクエストされた場合は現在の表現に正規化する。

## 旧テンプレートからの対応マップ

過去 `assets/templates/*.html` で 4 種の軽量テンプレを使っていた経緯がある。同じ用途のリクエスト（「3 案比較」「実装計画」「フロー図」等）には以下の Content Recipe を当てる。

| 旧テンプレ名 | 新 Content Recipe | 補足 |
|---|---|---|
| `implementation-plan` | Recipe A（企画書・提案書） | フェーズ計画 → Roadmap コンポーネント |
| `3-way-comparison` | Recipe D（意思決定文書）または Recipe A 章 3〜6 | 3 案並列 → Report Table + Rating または Proposal Card × 3 |
| `report` | Recipe B（調査レポート） | Executive Summary → 1章で `.lede + .kpi-row + .insight` |
| `annotated-flow` | Recipe E + FlowWithMargin コンポーネント | 業務プロセス可視化 → `components.md` の FlowWithMargin |

## Recipe A：企画書・提案書

**用途**：PoC企画、新規事業企画、システム提案、コンサルティング提案、実装計画

**章構成（8〜12章）**

| 章 | 内容 | 推奨コンポーネント |
|---|------|------------------|
| 1 | 企画背景 / Background | `.lede`, `.kpi-row` |
| 2 | 全体方針 / Approach | `.body lists`, `.insight` |
| 3 | テーマ・選択肢一覧 / Overview | `.report-table` + `.rating` |
| 4〜6 | 各テーマ詳細（複数章） | `.state-grid`, `.scope-panel`, `.report-table` |
| 7 | 優先順位 / Priority | `.prio-list` |
| 8 | 予算別の進め方（あれば） | `.budget-grid` |
| 9 | 推奨提案パッケージ | `.proposal-card` |
| 10 | 商談確認事項 | `.qa-grid` |
| 11 | ロードマップ | `.roadmap-bar` + `.roadmap-detail` |
| 12 | まとめ | `.summary` |

**Cover メタ例**：
```
Document Type / Themes / Budget / Issued
```

## Recipe B：調査レポート・分析資料

**用途**：市場調査、競合分析、技術調査、ベンチマーク報告、週次/月次進捗レポート、振り返り

**章構成（6〜10章）**

| 章 | 内容 | 推奨コンポーネント |
|---|------|------------------|
| 1 | エグゼクティブサマリー | `.lede`, `.kpi-row`, `.insight` |
| 2 | 調査背景・目的 | `.body lists` |
| 3 | 調査手法・対象 | `.scope-panel`, `.report-table` |
| 4〜6 | 調査結果（複数章。論点別） | `.report-table`, `.state-grid` |
| 7 | 比較分析 | `.report-table` + `.rating`, `.budget-grid`（2案比較として） |
| 8 | 示唆・考察 | `.insight`, `.prio-list`（重要示唆の順位） |
| 9 | 提言・次のアクション | `.proposal-card`, `.qa-grid`（検討論点として） |
| 10 | まとめ | `.summary` |

**Cover メタ例**：
```
Report Type / Survey Period / Sample Size / Issued
```

## Recipe C：戦略メモ・検討メモ

**用途**：戦略検討、論点整理、方針提案、内部討議資料

**章構成（4〜8章）**

| 章 | 内容 | 推奨コンポーネント |
|---|------|------------------|
| 1 | 課題認識 / Context | `.lede`, `.insight` |
| 2 | 現状分析 | `.state-grid`（As-Is中心）, `.report-table` |
| 3 | 論点整理 | `.prio-list`（論点の優先度）, `.qa-grid`（論点別の問い） |
| 4 | 検討した選択肢 | `.report-table`, `.budget-grid` |
| 5 | 推奨方針 | `.scope-panel`, `.insight` |
| 6 | 次のステップ | `.roadmap-bar`（簡略版・3〜4フェーズ） |
| 7 | まとめ | `.summary`（短め） |

**Cover メタ例**：
```
Memo Type / Owner / Status / Issued
```

注意：戦略メモは**短く・要点だけ**が原則。冗長な背景説明は避ける。

## Recipe D：意思決定文書

**用途**：経営判断資料、ベンダー選定、選択肢比較、承認依頼、3 案比較

**章構成（4〜6章）**

| 章 | 内容 | 推奨コンポーネント |
|---|------|------------------|
| 1 | 意思決定の論点 | `.lede`, `.kpi-row`（決定に必要な数値） |
| 2 | 選択肢の整理 | `.report-table` + `.rating`（評価軸での比較） |
| 3 | 各選択肢の詳細 | `.state-grid`（メリット/デメリット）, `.budget-grid`（2案比較）, `.proposal-card`（3 案並列） |
| 4 | 推奨案と根拠 | `.scope-panel`, `.insight`, `.prio-list`（判断基準の順位） |
| 5 | リスクと対応 | `.report-table`（リスク表・3列）, `.qa-grid`（承認時の確認事項） |
| 6 | まとめ・決裁依頼事項 | `.summary` |

**Cover メタ例**：
```
Decision Type / Approver / Deadline / Issued
```

ポイント：「**何を、誰が、いつまでに決めるか**」を冒頭で明示する。

## Recipe E：議事メモ / プロセス文書

**用途**：重要会議の議事録、討議サマリ、ワークショップ記録、業務プロセスの可視化、ユーザーフロー、システム間データフロー、意思決定フロー

**章構成（3〜5章・TOC省略可）**

| 章 | 内容 | 推奨コンポーネント |
|---|------|------------------|
| 1 | 会議概要・参加者・アジェンダ（または プロセス概要） | `.kpi-row`（日時・参加者数・所要時間）, `.body lists` |
| 2 | 主要な討議内容（または プロセス本体） | `.body lists`, `.insight`（重要発言）, **`.flow-margin`**（FlowWithMargin。プロセス可視化時のみ） |
| 3 | 決定事項 | `.scope-panel`（決定事項を箱で強調）, `.prio-list` |
| 4 | ToDo・アクションアイテム | `.report-table`（担当者・期日付き） |
| 5 | 次回までの確認事項 | `.qa-grid`（オプション） |

**Cover メタ例**：
```
Meeting Type / Date / Attendees / Issued
```

注意：議事メモは**TOCとSummary sectionを省略**してよい。短く読めることが重要。
**プロセス文書**（旧 annotated-flow 用途）の場合は、章 2 で `FlowWithMargin` コンポーネントを使い、本体ステップ＋右側マージン注釈を配置する。

## Recipe F：社内通達・説明資料

**用途**：制度説明、組織変更通知、新方針案内、ガイドライン共有

**章構成（3〜6章）**

| 章 | 内容 | 推奨コンポーネント |
|---|------|------------------|
| 1 | 通達の趣旨・背景 | `.lede`, `.insight`（最重要メッセージ） |
| 2 | 変更内容 / 新ルール | `.state-grid`（変更前/変更後）, `.scope-panel` |
| 3 | 影響範囲・対象者 | `.report-table`, `.kpi-row`（対象人数等） |
| 4 | スケジュール | `.roadmap-bar`（施行までのステップ）, `.flow-margin`（手順詳細時のみ） |
| 5 | FAQ・問い合わせ先 | `.qa-grid`（FAQ用途） |
| 6 | まとめ・行動要請 | `.summary` |

**Cover メタ例**：
```
Notice Type / Effective Date / Target / Issued
```

ポイント：受け手の行動が明確になるよう、**「何を、いつまでに、誰がやるか」**を明示。

## Output Format：Slide Deck（16:9 HTML スライド）

**用途**：ブラウザでめくれるプレゼン資料、社内投影資料、キックオフ資料、報告会資料、説明会資料、投資家ピッチ、コンサル提案書。`.pptx` 納品が不要で「ブラウザで開けば動く」プレゼンを求められた場合に使う。

**他の Content Recipe との関係**：Slide Deck format は **出力形式（16:9 スライドデッキ）** を規定するもので、**内容構成は Content Recipe A〜F のいずれかをそのまま流用**する。例：「キックオフ資料を HTML スライドで」→ Content Recipe A × Slide Deck format、「議事メモを 16:9 スライドにして」→ Content Recipe E × Slide Deck format、「投資家ピッチを作って」→ Content Recipe A × Slide Deck format × Mono テーマ。

**シェル仕様**：1280×720 の単スライド表示、キーボード送り、左サイドサムネイル、URL ハッシュ深リンク、印刷時 1 ページ 1 スライド。詳細は `references/slide-deck.md` を参照し、テンプレートは `assets/template-slides.html` を使う。

**標準スライド構成（最小：5 枚〜）**

| スライド | 内容 | 推奨コンポーネント |
|---|------|------------------|
| 1 | Cover — タイトル / サブタイトル / 4 項目メタ | `.cover-title`, `.cover-sub`, `.cover-meta` |
| 2 | TOC — 章一覧（4〜8 項目） | `.toc-grid` |
| 3〜 | Section Divider — 章扉（章番号＋章名＋章リード） | `.divider`, `.lede` |
| 4〜N | Content — 1 スライド 1 メッセージ | `.title-bar`＋`.message`、加えて `.body-list` / `.insight` / `.scope-panel` / `.fact-list` / `.kpi-row` のいずれか 1〜2 個 |
| 終 | Summary — クロージング | `.summary` |

**スライド枚数の目安**

| 内容の規模 | スライド枚数 | 構成 |
|---|---|---|
| 短い議事メモ・1 トピックの説明 | 5〜10 枚 | Cover + Content 3〜7 枚 + Summary（TOC 省略可、Divider 省略可） |
| 標準的な提案・報告 | 12〜20 枚 | Cover + TOC + Divider × 2〜3 + Content 7〜12 枚 + Summary |
| 大型の調査報告・キックオフ | 25〜40 枚 | Cover + TOC + Divider × 3〜5 + Content 18〜30 枚 + Summary |

**Cover メタ例**：
```
Document Type / Client / Date / Doc ID
```

**1 スライドの情報密度ガイド**

- 1 スライドに入れるコンポーネントは **原則 1〜2 個**まで（メッセージ＋本文系 1 つが標準）
- 本文リストは **1 スライドあたり 6 項目以内**を目安に分割
- 表は **5 行 × 4 列以内**を目安に分割
- 入りきらない場合は、複数スライドに分けて「(続き)」付きの `.title-bar` で連結する

**書き出し命名**：`<英語snake_case>_slides.html`

ポイント：「**プレゼン本番で投影する**」前提で、文字サイズはスライド向けに少し大きめ（`.message` 17px / `.body-list` 14.5px）に上書きする。詳細は `references/slide-deck.md` のタイポグラフィ調整節を参照。

## レシピ選択の判断基準

ドキュメント種別が**複合的**な場合（例：「調査結果を踏まえた提案書」）：

- 重点を置きたい方を主軸にする（提案重視ならRecipe A、調査結果重視ならRecipe B）
- レシピを混ぜるよりは、主軸のレシピに従い、補助章として他のレシピの章を追加する

**章数の目安**（Recipe A〜F）：

- 提供されたコンテンツが**1000字未満** → 3〜5章（TOC省略）
- **1000〜5000字** → 5〜8章
- **5000〜15000字** → 8〜12章
- **15000字超** → 12章を超える場合は内容を絞るか、複数ドキュメントに分割を提案する

**Slide Deck format を併用する場合**：上記の章を、章 1 つあたり「章扉 + Content 数枚」に展開する。1000 字 ≒ Content 3〜5 スライドが目安。総スライド数が 40 を超える場合は、複数デッキへの分割を検討する。

## 共通：最初と最後の作り方

どのレシピでも、**最初の章（背景・前提）と最後の章（まとめ）**は省略せず必ず置く。

- **最初の章**：読者が「なぜこの文書を読むべきか」を理解できるようにする
- **最後の章**：読者が「結局何を覚えればよいか」を持ち帰れるようにする

これだけ守れば、どの種別でも業務文書として機能する。
