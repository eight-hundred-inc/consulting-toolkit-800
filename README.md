# Consulting Toolkit

コンサルティングプロジェクトの立ち上げから最終報告書の作成まで、ワークフロー全体をAIがサポートするスキル・コマンド・エージェント群。

調査プロジェクトでは、提案書の論点を軸にインタビューガイド・報告書骨子まで一貫して設計する。各スキルに品質基準が組み込まれており、AIタスクと人間タスクを明確に分離した協調型ワークフローで運用する。

---

## Skills

### プロジェクト管理

| スキル | 説明 | トリガー |
|--------|------|----------|
| [project-manager](skills/project-manager/SKILL.md) | ワークフローのオーケストレーター。状態管理・進捗追跡を行い、各ステップで適切なスキルを呼び出す | 「プロジェクトを開始」「進捗確認」「次のタスク」 |

### 調査プロジェクト

デスクリサーチとインタビューを組み合わせた調査に対応する。技術動向調査、市場調査、インタビュー中心、デューデリジェンスなど幅広いプロジェクト種類をカバーする。

| スキル | 説明 | トリガー |
|--------|------|----------|
| [interview-research-proposal](skills/interview-research-proposal/SKILL.md) | 与件情報と打ち合わせメモから調査提案書を作成 | 「提案書を作成して」「プロポーザルを作って」 |
| [interview-guide-creator](skills/interview-guide-creator/SKILL.md) | 提案書の論点に対応したインタビューガイドを作成 | 「インタビューガイドを作成して」「質問リストを作って」 |
| [interview-candidate-selector](skills/interview-candidate-selector/SKILL.md) | 候補者リストから最適なインタビュー対象者を選定・評価 | 「インタビュー対象者を選定して」「候補者を評価して」 |
| [interview-minutes-creator](skills/interview-minutes-creator/SKILL.md) | 文字起こしと質問リストから詳細な議事録を作成 | 「議事録を作成して」「インタビューメモから議事録を作って」 |
| [report-outline-creator](skills/report-outline-creator/SKILL.md) | 提案書・調査結果から最終報告書の骨子を設計 | 「報告書骨子を作成して」「章立てを設計して」 |
| [interview-research-project-workflow](skills/interview-research-project-workflow/SKILL.md) | 3フェーズ・11ステップのワークフロー定義 | project-managerから自動呼び出し |

### ユーティリティ

| スキル | 説明 | トリガー |
|--------|------|----------|
| [desk-research](skills/desk-research/SKILL.md) | 論点・仮説に基づくデスクトップリサーチを実行し、調査レポートを出力 | 「デスクリサーチを実行して」「初期調査をして」 |
| [meeting-minutes-creator](skills/meeting-minutes-creator/SKILL.md) | 会議メモから議事録を作成 | 「議事録を作成して」「会議メモから議事録を作って」 |
| [docx-to-markdown-with-references](skills/docx-to-markdown-with-references/SKILL.md) | Word文書をMarkdownに変換し、参考文献を整理 | 「Wordをマークダウンに変換して」 |
| [800-branded-pptx](skills/800-branded-pptx/SKILL.md) | エイトハンドレッド社のブランドデザインでPowerPointを作成 | 「800風のスライドを作成」 |
| [creating-skill](skills/creating-skill/SKILL.md) | スキル作成の手順・スクリプト・リファレンスを提供する知識パッケージ | skill-creatorサブエージェント経由で使用 |

---

## Commands

プロジェクトマネージャーを操作するスラッシュコマンド。Cursorのチャットで `/コマンド名` として呼び出す。

| コマンド | 説明 |
|----------|------|
| [pm-start](commands/pm-start.md) | プロジェクトを初期化する。種類の確認、情報ヒアリング、`workflow_status.md` の作成を行い、Step 1の開始を確認する |
| [pm-status](commands/pm-status.md) | 進捗を確認する。現在のフェーズ・ステップ、完了済み・残りステップの一覧、次のアクション提案を返す |
| [pm-next](commands/pm-next.md) | ワークフローを次に進める。AIタスクならスキルを実行し、人間タスクなら内容を案内して完了報告を待つ |
| [pm-approve](commands/pm-approve.md) | レビューを承認する。`review_pending` 状態のステップを `completed` に更新し、次のステップへ進む |

---

## Agents

特定の役割に特化したサブエージェント。project-managerやワークフローの各ステップから自動的に呼び出される。

| エージェント | 説明 | 呼び出しタイミング |
|-------------|------|-------------------|
| [quality-reviewer](agents/quality-reviewer.md) | 成果物の品質レビュー専門。品質チェック項目に照らして客観的に評価し、合格/条件付き合格/要修正を判定する | AIタスク完了後のレビューゲート |
| [desk-researcher](agents/desk-researcher.md) | デスクトップリサーチ実行専門。WebSearch/WebFetch/Browser Useで情報を収集し、調査レポートと仮説検証シートを出力する | Step 2（初期調査）、Step 9（詳細調査） |
| [skill-creator](agents/skill-creator.md) | 会話のやり取りから得られたワークフローや知識をスキルとして定型化する。creating-skillスキルを読み込み、初期化・作成・バリデーションを実行する | 「これをスキル化して」「スキルを作成して」 |

---

## ワークフロー

調査プロジェクトは3フェーズ・11ステップで構成される。

```
Phase 0: 提案
┌────────────────────────────────────────────────────────────────┐
│  Step 1.  提案書作成 [AI]              → interview-research-proposal │
│  Step 2.  初期デスクトップ調査 [AI]     → desk-researcher             │
│  Step 3.  提案書更新 [AI]              → interview-research-proposal │
│  Step 4.  インタビューガイド作成 [AI]   → interview-guide-creator     │
│  Step 5.  報告書骨子案作成 [AI]         → report-outline-creator      │
└────────────────────────────────────────────────────────────────┘
                              ↓
Phase 1: 調査
┌────────────────────────────────────────────────────────────────┐
│  Step 6.  インタビュー対象者選定 [AI]   → interview-candidate-selector│
│  (インタビュー実施) [人間]                                           │
│  Step 7.  議事メモ作成 [AI]             → interview-minutes-creator   │
│  Step 8.  インタビューまとめ [AI]                                     │
│  Step 9.  デスクリサーチ [AI]           → desk-researcher             │
└────────────────────────────────────────────────────────────────┘
                              ↓
Phase 2: 分析・とりまとめ
┌────────────────────────────────────────────────────────────────┐
│  Step 10. 統合・分析 [AI]                                            │
│  Step 11. 報告書作成 [AI]                                            │
└────────────────────────────────────────────────────────────────┘
```

各AIステップ完了後、quality-reviewerによる品質チェックとユーザーレビューゲートを経て次へ進む。

---

## 使い方

### プロジェクト全体をワークフローで進める場合

1. Cursorチャットで `/pm-start` を実行
2. プロジェクト種類（技術動向調査 / 市場調査 / インタビュー中心 / DD）を選択
3. プロジェクト名・クライアント名・納期・予算を入力
4. `/pm-next` で各ステップを順に実行
5. AIステップ完了後、成果物を確認して `/pm-approve` で承認
6. `/pm-status` で進捗をいつでも確認

### 個別スキルだけを使う場合

トリガーワードをチャットに入力する。

```
「提案書を作成して」  → interview-research-proposal が起動
「議事録を作成して」  → meeting-minutes-creator が起動
「デスクリサーチを実行して」 → desk-research が起動
```

---

## 成果物の格納先

| 成果物 | パス |
|--------|------|
| 提案書 | `Output/提案書.md` |
| インタビューガイド | `Output/インタビューガイド.md` |
| インタビュー対象者 | `Output/インタビュー対象者.md` |
| 報告書骨子 | `Output/報告書骨子.md` |
| 議事録 | `Output/議事録/` |
| インタビューまとめ | `Output/インタビューまとめ.md` |
| 分析結果 | `Output/分析結果.md` |
| 最終報告書 | `Output/最終報告書.md` |
| 進捗状況 | `workflow_status.md` |

---

## ディレクトリ構成

```
consulting/
├── .claude-plugin/
│   ├── plugin.json
│   └── marketplace.json
├── README.md
├── skills/
│   ├── project-manager/
│   ├── interview-research-proposal/
│   ├── interview-guide-creator/
│   ├── interview-candidate-selector/
│   ├── interview-minutes-creator/
│   ├── interview-research-project-workflow/
│   ├── 800-branded-pptx/
│   ├── agent-team-playbook/
│   ├── creating-skill/
│   ├── desk-research/
│   ├── docx-to-markdown-with-references/
│   ├── meeting-minutes-creator/
│   ├── pptx/
│   └── report-outline-creator/
├── commands/
│   ├── pm-start.md
│   ├── pm-status.md
│   ├── pm-next.md
│   └── pm-approve.md
└── agents/
    ├── quality-reviewer.md
    ├── desk-researcher.md
    └── skill-creator.md
```

---

## インストール

このリポジトリは Claude Code Plugin として構成されている。GitHubリポジトリから直接インストールできる。

### プラグインとしてインストール

```bash
# マーケットプレイスを追加
/plugin marketplace add masaki69/consulting-toolkit

# プラグインをインストール
/plugin install consulting-toolkit@consulting-toolkit
```

または `~/.claude/settings.json` に直接追加する。

```json
{
  "extraKnownMarketplaces": {
    "consulting-toolkit": {
      "source": {
        "source": "github",
        "repo": "masaki69/consulting-toolkit"
      }
    }
  },
  "enabledPlugins": {
    "consulting-toolkit@consulting-toolkit": true
  }
}
```

### 更新

```bash
claude plugin update consulting-toolkit@consulting-toolkit
```

### 動作確認

```bash
# インストール済みプラグインの一覧
claude plugin list

# プラグインのバリデーション
claude plugin validate
```

### ファイル構成

| 種類 | パス |
|------|------|
| プラグインマニフェスト | `.claude-plugin/plugin.json` |
| マーケットプレイスカタログ | `.claude-plugin/marketplace.json` |
| Skills | `skills/` |
| Commands | `commands/` |
| Agents | `agents/` |
