# CLAUDE.md テンプレート

プロジェクト初期化時に、以下のテンプレートを使用して `CLAUDE.md` を作成する。
`{変数名}` をヒアリング結果で置換すること。

---

```markdown
# プロジェクト: {プロジェクト名}

## 概要
- クライアント: {クライアント名}
- 種類: {project_type}
- 納期: {YYYY-MM-DD}
- スコープ: {スコープ}

## ファイル配置
- Input/: クライアント提供資料・与件
- Input/インタビュー/: インタビュー文字起こし
- Output/: 全成果物
- Output/議事録/: インタビュー議事録
- Output/調査/: デスクリサーチ結果

## 利用可能なリソース
- スキル: skills/ 配下の全スキル
  （project-manager, desk-research, interview-research-proposal,
   interview-guide-creator, report-outline-creator 等）
- SubAgent: agents/ 配下
  （desk-researcher, quality-reviewer）
- Agent Team Playbook: skills/agent-team-playbook/
  並行処理が有効な場面で、テンプレートを参照して Agent Team を構成できる
```

---

## 変数の説明

| 変数 | 取得元 | 例 |
|------|--------|-----|
| `{プロジェクト名}` | ヒアリング | AI動向調査プロジェクト |
| `{クライアント名}` | ヒアリング | 株式会社○○ |
| `{project_type}` | AskQuestion の選択結果 | technology-research / market-research / interview-focused / due-diligence |
| `{YYYY-MM-DD}` | ヒアリング | 2026-03-31 |
| `{スコープ}` | ヒアリング（1-2行） | 生成AI技術の市場動向と主要プレイヤーの戦略を調査し、参入機会を評価する |

## 注意事項

- CLAUDE.md はプロジェクトルールとして全セッション（Cursor / Claude Code）で参照される
- Agent Team 固有の運用ルールやタスクアサインは書かない（テンプレート側に記載する）
- スキル一覧は個別に列挙せず、ディレクトリを包括参照する
