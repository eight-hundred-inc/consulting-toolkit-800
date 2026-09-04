# workflow.html テンプレート（ポートフォリオ型）

継続クライアントエンゲージメントの初期化時、共通シェル [../assets/workflow-template.html](../assets/workflow-template.html) をプロジェクトルートに `workflow.html` としてコピーし、本ファイルの指定に従って節を埋める。

**作業状態の正本は `workflow.html` 一本**である。Markdown 版は作らない（本文一箇所ルール）。状態が変わったら HTML の該当節を Edit で直接書き換える。

## 適用条件

以下の特徴を持つプロジェクトに適用する。

- 1つの継続クライアント（またはテーマ）の下に、独立したサブプロジェクトが複数並走する
- サブプロジェクトは立ち上げ・完了・アーカイブのライフサイクルを繰り返し、束としての横断管理が必要
- 既存の完了案件・過去案件も含めて棚卸しし、全体の論点・示唆を横断的に維持したい

サブプロジェクトが1つしかない場合や、活動に案件単位の区切りがない月次運用（活動カタログ型が適する）には適用しない。

## 節構成（共通シェルからの差分）

| 節 | 内容 | ポートフォリオ型での扱い |
|----|------|--------------------|
| 1 | 基本情報・ファイル配置・連携リンク | ワークフロー類型に「ポートフォリオ管理型（カスタム）」、形態に「継続クライアントエンゲージメント（複数サブプロジェクト並走）」と書く。ファイル配置に `Output/サブプロジェクト/`（個別サマリ）と各サブプロジェクトのディレクトリを追記する |
| 2 | 現在の状態 | 定義リスト版を残す（ポートフォリオ層のフェーズ・ステップ・ステータス・担当） |
| 3 | 作業計画（WBS） | **「サブプロジェクト一覧」＋「ポートフォリオ運用のステップ」に差し替える**（下記）。ガントは全 Active サブプロジェクトのレーンで組んでよい（不要なら節ごと削除） |
| 4 | 成果物リンク | 全体サマリと各サブプロジェクトの個別サマリを載せる |
| 5 | タスク（積み残し） | そのまま使う |
| 6 | 運用記録 | 6.1 重要な意思決定に「背景」列を足す。6.2 履歴ログにサブプロジェクトの状態変化を記録する |

## 第3節: サブプロジェクト一覧

```html
<h3 class="sub-head"><span class="num">3.1</span>Active（進行中）</h3>

<table class="report-table">
  <thead>
    <tr><th>サブプロジェクト</th><th>概要</th><th>最終更新</th><th>個別サマリ</th><th>ディレクトリ</th></tr>
  </thead>
  <tbody>
    <tr><td class="name">{{名前}}</td><td>{{1行概要}}</td><td class="num">{{YYYY-MM-DD}}</td><td><code class="mono">Output/サブプロジェクト/{{名前}}.md</code></td><td><code class="mono">{{ディレクトリ}}/</code></td></tr>
  </tbody>
</table>

<h3 class="sub-head"><span class="num">3.2</span>Completed（完了・成果物納品済）</h3>

<table class="report-table">
  <thead>
    <tr><th>サブプロジェクト</th><th>概要</th><th>完了時期</th><th>主要成果物</th></tr>
  </thead>
  <tbody>
    <tr><td class="name">{{名前}}</td><td>{{1行概要}}</td><td class="num">{{YYYY-MM}}</td><td><code class="mono">{{パス}}</code></td></tr>
  </tbody>
</table>

<h3 class="sub-head"><span class="num">3.3</span>Archived（過去案件）</h3>

<table class="report-table">
  <thead>
    <tr><th>サブプロジェクト</th><th>概要</th><th>時期</th></tr>
  </thead>
  <tbody>
    <tr><td class="name">{{名前}}</td><td>{{1行概要}}</td><td class="num">{{YYYY-MM〜MM}}</td></tr>
  </tbody>
</table>
```

## 第3節: ポートフォリオ運用のステップ

```html
<h3 class="sub-head"><span class="num">3.4</span>Phase 1: ポートフォリオ初期化（1回のみ）</h3>

<table class="report-table">
  <thead>
    <tr><th class="num-col">WBS</th><th>ステップ</th><th>担当</th><th>状態</th></tr>
  </thead>
  <tbody>
    <tr><td class="num">1-1</td><td class="name">サブプロジェクト棚卸し</td><td>AI</td><td>進行中 ← 現在</td></tr>
    <tr><td class="num">1-2</td><td class="name">全体論点・仮説・現時点の示唆を整理</td><td>AI</td><td>未着手</td></tr>
    <tr><td class="num">1-3</td><td class="name">active サブプロジェクトの個別サマリ作成</td><td>AI</td><td>未着手</td></tr>
  </tbody>
</table>

<h3 class="sub-head"><span class="num">3.5</span>Phase 2: 継続運用（恒常的）</h3>
<!-- 恒常運用のため「完了」にしない。実施のたびに第6.2節の履歴ログへ記録する -->

<table class="report-table">
  <thead>
    <tr><th class="num-col">WBS</th><th>ステップ</th><th>担当</th><th>頻度</th></tr>
  </thead>
  <tbody>
    <tr><td class="num">2-1</td><td class="name">active サブプロジェクトの進捗トラッキング</td><td>AI/人間</td><td>恒常</td></tr>
    <tr><td class="num">2-2</td><td class="name">月次レビュー（全 active のステータス棚卸し）</td><td>AI</td><td>毎月</td></tr>
    <tr><td class="num">2-3</td><td class="name">全体示唆・提供価値の再整理</td><td>AI</td><td>四半期目安</td></tr>
  </tbody>
</table>

<h3 class="sub-head"><span class="num">3.6</span>Phase 3: 新規サブプロジェクト立ち上げ（都度）</h3>

<table class="report-table">
  <thead>
    <tr><th class="num-col">WBS</th><th>ステップ</th><th>担当</th><th>頻度</th></tr>
  </thead>
  <tbody>
    <tr><td class="num">3-1</td><td class="name">新規依頼受領・スコープ確認</td><td>人間</td><td>都度</td></tr>
    <tr><td class="num">3-2</td><td class="name">サブプロジェクト立ち上げ（ディレクトリ作成・一覧追記・個別サマリ作成）</td><td>AI</td><td>都度</td></tr>
  </tbody>
</table>
```

## 状態管理の方法

ポートフォリオ層とサブプロジェクト層の2層で管理する。

| 層 | 管理単位 | 語彙 |
|----|---------|------|
| ポートフォリオ層 | Phase 1 のステップ | `not_started` / `in_progress` / `review_pending` / `waiting_human` / `completed` / `skipped` |
| サブプロジェクト層 | サブプロジェクト一覧の行 | `Active` / `Completed` / `Archived` |

運用上のポイント:

- Phase 1 のステップは通常のステップと同様に完了させ、状態を「完了（YYYY-MM-DD）」にする
- Phase 2 のステップは恒常運用のため完了にしない。実施のたびに履歴ログへ記録する
- Phase 3 は新規依頼のたびに繰り返す。完了にせず、履歴ログとサブプロジェクト一覧への追加で表現する
- 規模の大きいサブプロジェクトは、そのディレクトリ配下に独自の `workflow.html`（調査型・チェックリスト型等）を個別に持ってよい。その場合もポートフォリオ側の一覧・個別サマリは維持する
- 個別サマリ（`Output/サブプロジェクト/{名前}.md`）には、そのサブプロジェクトの目的・現状・直近の成果・次のアクションを記載する

## PM 呼び出し時の扱い

PM は Active サブプロジェクト一覧（名前・概要・最終更新）とポートフォリオ層の現在の状態を提示し、AskUserQuestion で以下から選ばせる。

1. 特定の Active サブプロジェクトを進める（個別サマリを読み込んでから作業する）
2. 月次レビュー・全体示唆の再整理を実施する（Phase 2）
3. 新規サブプロジェクトを立ち上げる（Phase 3）

## 更新ルール

1. **サブプロジェクトの状態変化時**: 一覧の該当行を Active → Completed → Archived と移し、第6.2節の履歴ログに記録
2. **サブプロジェクト内で作業した時**: 個別サマリの「最終更新」「現状・次のアクション」を更新
3. **新規立ち上げ時**: ディレクトリ作成、Active 表への追加、個別サマリ作成、履歴記録をセットで行う
4. **月次レビュー時**: 全 Active の個別サマリを確認し、停滞案件・完了可能案件を洗い出して履歴ログに記録
5. **知識状態の変化時**: SKILL.md の自動同期ルールに従い `プロジェクトサマリ.md` を更新
