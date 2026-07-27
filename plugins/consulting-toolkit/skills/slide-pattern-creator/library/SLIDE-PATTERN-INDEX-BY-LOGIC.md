# SLIDE-PATTERN-INDEX-BY-LOGIC

**「何を言いたいか」からパターンを引く索引。** `SLIDE-PATTERN-INDEX.md`（正本）と `SLIDE-PATTERN-INDEX-COMPACT.md` は**視覚形式**（表紙／目次／リスト／フロー／図解／カード／グラフ／表）で分類しているため、「この主張をしたい」から引けない。本ファイルはその逆引きを提供する。

## 使い方

1. そのスライドの**メッセージ行（主張文）を先に確定する**
2. メッセージの**述語**を見て下の「述語 → 論理型」で型を判定する
3. 型の行から候補パターンを取り、`SLIDE-PATTERN-INDEX.md` で概要・適したシーンを確認して 1 つ選ぶ
4. 構成 MD に `パターン指定:` がある場合、または図版指示が具体的な場合は**そちらが優先**。本索引は「なぜその配置か」の検算に使う

> 論理型は `slide-structure-designer/references/message-logic.md` の 4 型（消去法／MECE／時系列／軸比較）を**配置を選べる粒度まで細分**したもので、競合する分類ではない。対応は各行の「上位型」列に示す。

## 述語 → 論理型

| メッセージの述語 | 論理型 |
|---|---|
| 「〜が論点だ」「答えるべき問いは」 | L1 論点提示 |
| 「問い X の答えは Y」 | L2 問い→答え |
| 「A は…だが B は…」「従来は…今は…」 | L3 二項対比 |
| 「n 社（n 案）を同じ軸で見ると」 | L4 多対象比較 |
| 「n 案のうち X を採る」「A でも B でもなく C」 | L5 選択肢評価→推奨 |
| 「X は A〜E の n 層／要素からなる」 | L6 構造分解 |
| 「要点は n 個ある」（順序なし） | L7 並列列挙 |
| 「X は n ステップで進める」 | L8 プロセス |
| 「いつ何をやるか」「スケジュールは」 | L9 日程・計画 |
| 「X だから Y になる」「循環している」 | L10 因果・循環 |
| 「X は 2 軸で見るとここに位置する」 | L11 位置づけ |
| 「データは X を示す」 | L12 定量根拠 |
| 「勝ち筋／KSF は n 個で、根拠はこれ」 | L13 主張＋根拠列挙 |
| 「現場はこう言っている」 | L14 一次情報 |
| 「全体はこうで、いまここ」 | L15 全体像・現在地 |
| 「したがって〜すべき」（章末・締め） | L16 結論 |

## 論理型 → パターン候補

| 型 | 上位型 | 第一候補 | 他の候補 |
|---|---|---|---|
| **L1 論点提示** | — | `numbered-question-list` | `qa-cards`（優先順位を付けるとき）／`recognition-cards-issues`（前提確認から絞り込むとき） |
| **L2 問い→答え** | — | `diagram-with-callout` | `two-column-compare`（左に状況・右に結論＋根拠の非対称対比） |
| **L3 二項対比** | 軸比較型 | `two-column-compare` | `two-panel-background-purpose`（対等な 2 観点）／`before-after-two-col`・`problem-solution`（変化・対応関係）／`two-col-icon-list-comparison`／`two-column-split-boxes` |
| **L4 多対象比較** | 軸比較型 | `comparison-matrix` | `comparison-matrix-table`（列を 1 つ強調）／`case-study-table`（事例を密度高く）／`aligned-content-table`（5〜6 列の複合情報）／`metric-definition-table` |
| **L5 選択肢評価→推奨** | 消去法型 | `comparison-table-with-highlight` | `proposal-cards-duo`（2 案対比）／`plan-comparison-pricing`・`pricing-comparison-table`（金額を伴う）／`stage-table-with-points`（段階モデル上の到達点） |
| **L6 構造分解** | MECE型 | `layer-detail-split` | `goal-kgi-kpi-dashboard`（目標→KGI→KPI の階層）／`framework-inputs-outputs`（入力→処理→出力）／`org-chart-tree`・`org-chart`（組織）／`three-tier-segment-list` |
| **L7 並列列挙** | MECE型 | `numbered-two-col-row` | 3 件 `three-column-icon-card`・`three-col-large-icon-card`／4 件 `four-card-2x2`／6 件 `six-card-two-column`／8 件 `eight-card-2x4-grid`／`numbered-row-full-width`（4〜6 件を等価に） |
| **L8 プロセス** | 時系列型 | `phase-flow` | `four-step-flow`・`horizontal-timeline-cards`（4 段）／`circle-node-step-flow`（5 段）／`vertical-step-flow`・`vertical-step-three-col`（縦・段数が多い）／`three-column-vertical-flow`（並走する 3 系統）／`two-lane-pipeline`（上流／下流の 2 レーン） |
| **L9 日程・計画** | 時系列型 | `timeline-gantt` | `swimlane-schedule`（複数ワークストリームの並走）／`milestone-timeline`／`phase-roadmap`（フェーズ×レイヤーの複層）／`staircase-roadmap`系（成長段階）／`roadmap-3step` |
| **L10 因果・循環** | — | `cycle-diagram-annotated` | `pdca-cycle-diagram`・`cycle-diagram-with-labels`（4 局面の定型サイクル）／`two-feature-with-result`（要因→結果）／`two-circle-bilateral-flow`（相互作用）／`hub-spoke-diagram` |
| **L11 位置づけ** | — | `risk-matrix-2x2` | `four-quadrant-center-circle`（中心概念＋4 象限）／`four-card-2x2`（象限の中身を語る）／`stage-table-with-points`（1 次元の段階上の現在地） |
| **L12 定量根拠** | — | `chart-with-commentary` | `chart-left-text-right`（系列ごとの解説）／`stacked-bar-hero-numbers`（内訳＋際立った値）／`bar-chart-full`・`kpi-bar-chart`（推移を主役に）／`three-col-kpi-with-chart`（異種指標の並列）／`two-col-list-and-chart` |
| **L13 主張＋根拠列挙** | — | `numbered-two-col-row` | `points-with-quotes`（根拠が一次情報）／`three-col-large-icon-card`（3 件で根拠が箇条書き） |
| **L14 一次情報** | — | `points-with-quotes` | `quote-large-center`（1 件を印象づける）／`case-study-visual`（1 件を要点＋画で）／`attribute-rows-profile`（1 対象を固定観点で） |
| **L15 全体像・現在地** | — | `phase-roadmap` | `stage-table-with-points`（成熟度上の現在地）／`framework-inputs-outputs`（機能の全体像）／`center-illustration-spoke`（統合の全体像）／`agenda-current-highlight`（章の現在地） |
| **L16 結論** | — | `key-message-single` | `summary-three-points`（3 点でまとめる）／`action-items-list`（次アクションに落とす）／`three-kpi-big-number`（成果を数値で） |

## 使うときの注意

- **1 枚に主構図は 1 つ**。補助ゾーン（下部の示唆帯・右レール）を足してもゾーンは 2〜3 まで、ネストしない（`_shared/slide-body-principles.md` 原則 2）
- **同じ型が連続するときは候補を変える**。L7 が 3 枚続いたら 3 枚とも `numbered-two-col-row` にしない（金太郎飴回避）
- **件数で選ぶ**。L7・L8 は件数で候補が決まる。件数に合わないパターンを無理に使わない（4 件しかないのに 8 カードグリッドを使わない）
- **候補に無い場合**は視覚形式側の `SLIDE-PATTERN-INDEX.md` を直接探すか、自由設計する。自由設計したものが再利用に値するなら slide-pattern-creator でパターン化して library に登録する
- デッキ全体を貫く約束事（識別子の貫通・現在地・確度表示・引用の器）は `_shared/deck-rhetoric.md`

## 保守

パターンを library に追加したら、**3 ファイル**を同期する: `SLIDE-PATTERN-INDEX.md`（正本）→ `SLIDE-PATTERN-INDEX-COMPACT.md`（軽量版）→ 本ファイル（該当する論理型の行に追記。どの型にも当てはまらないなら型の追加を検討する）。書き込みは必ずプラグインのソース側（`~/Workspace/consulting-toolkit/...`）に行い、`/release-toolkit` で配布する。
