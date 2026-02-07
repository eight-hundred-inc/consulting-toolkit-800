---
name: interview-research-project-workflow
description: 調査プロジェクトのワークフロー定義。3フェーズ・11ステップで構成。提案書作成から報告書作成まで、デスクリサーチとインタビューを組み合わせた調査プロジェクトを管理する。project-managerから呼び出される。
---

# 調査プロジェクト ワークフロー

調査プロジェクト（技術動向調査、市場調査、インタビュー中心、デューデリジェンス）のための3フェーズ・11ステップのワークフロー定義。

## ワークフロー概要

```
Phase 0: 提案
  1. 提案書作成 [AI] → interview-research-proposal
  2. 初期デスクトップ調査 [AI → SubAgent] → desk-researcher → desk-research (initialモード)
  3. 提案書更新 [AI] → interview-research-proposal
  4. インタビューガイド作成 [AI] → interview-guide-creator
  5. 最終報告書骨子案作成 [AI] → report-outline-creator

Phase 1: 調査
  6. インタビュー対象者選定 [AI] → interview-candidate-selector
  (インタビュー実施) [人間]
  7. インタビュー議事メモ作成 [AI] → interview-minutes-creator
  8. インタビューまとめ [AI]
  9. デスクリサーチ [AI → SubAgent] → desk-researcher → desk-research (detailedモード)

Phase 2: 分析・とりまとめ
  10. 統合・分析 [AI]
  11. 報告書作成 [AI]

※ 全AIステップ完了後、quality-reviewer SubAgentによる品質チェック + ユーザーレビューゲートを経て次へ進む
```

## プロジェクト種類

このワークフローは以下のプロジェクト種類に対応。種類により各タスクの深さ・フォーカスが変化:

| 種類 | フォーカス |
|------|------------|
| **技術動向調査** | 先端技術・プレイヤー探索、技術課題・参入障壁 |
| **市場調査** | 市場規模・セグメント、競合分析 |
| **インタビュー中心** | インタビュー設計・実施が主、定性的示唆 |
| **デューデリジェンス** | 財務・事業・技術の深掘り、リスク評価 |

## ステップ別処理

各ステップの詳細は [references/phases.md](references/phases.md) を参照。

### Step 1: 提案書作成 [AI]

1. `interview-research-proposal` スキルを読み込む
2. `Input/与件.md`を入力として提案書を作成
3. `Output/提案書.md`に出力

### Step 2: 初期デスクトップ調査 [AI → SubAgent]

`desk-researcher` SubAgentに委譲して実行する。中間出力（検索結果・Webページ等）のコンテキスト分離が目的。

1. ユーザーに提案書のパスと出力先フォルダを確認
2. `desk-researcher` SubAgentを起動し、以下を渡す:
   - 提案書のファイルパス
   - 出力先フォルダのパス
   - モード: `initial`
   - docxファイルがある場合はそのパスも渡す
3. SubAgentが返却した結果（ファイルパス、主要な発見事項、仮説検証の要約）を受け取る
4. レビューゲートへ進む

### Step 3: 提案書更新 [AI]

初期調査結果に基づき提案書を更新:

1. `Input/初期調査結果.md`を読み込む
2. 初期調査結果に基づき、提案書の**初期仮説を更新**
3. **タスク・スケジュールの修正要否を判断**
4. **クライアントへの確認事項を出力**
5. `Output/提案書.md`を更新（確認事項セクションを含む）

### Step 4: インタビューガイド作成 [AI]

1. `interview-guide-creator` スキルを読み込む
2. 提案書（論点・仮説）と初期調査結果を入力
3. インタビューで検証・補強すべき事項を整理
4. `Output/インタビューガイド.md`に出力

### Step 5: 最終報告書骨子案作成 [AI]

1. `report-outline-creator` スキルを読み込む
2. 提案書（論点・仮説）、インタビューガイド（検証事項）、初期調査結果を入力
3. プロジェクト種類を判定し、適切な章構成テンプレートを参照
4. 論点を章にマッピングし、スライド構成・想定アウトプットを設計
5. `Output/報告書骨子.md`に出力

### Step 6: インタビュー対象者選定 [AI]

1. `interview-candidate-selector` スキルを読み込む
2. `Output/インタビューガイド.md` から対象者タイプ定義を確認
3. `Interview/` フォルダ内の候補者リストを読み込む
4. スキルの指示に従って対象者を選定・評価
5. `Output/インタビュー対象者.md`に出力

### (インタビュー実施) [人間]

- ユーザーがインタビューを実施
- 音声/動画の文字起こしを`Input/インタビュー/`に格納してもらう

### Step 7: インタビュー議事メモ作成 [AI]

1. `interview-minutes-creator` スキルを読み込む
2. 文字起こしから議事録を作成
3. `Output/議事録/`フォルダに出力

### Step 8: インタビューまとめ [AI]

1. 全インタビュー議事録を読み込み
2. 論点ごとに示唆を抽出
3. `Output/インタビューまとめ.md`に出力

### Step 9: デスクリサーチ [AI → SubAgent]

`desk-researcher` SubAgentに委譲して実行する。中間出力のコンテキスト分離が目的。

1. ユーザーに提案書、インタビューまとめ、既存調査結果のパスと出力先フォルダを確認
2. `desk-researcher` SubAgentを起動し、以下を渡す:
   - 提案書のファイルパス
   - インタビューまとめのファイルパス
   - 既存調査結果のファイルパス
   - 出力先フォルダのパス
   - モード: `detailed`
   - 追加指示: インタビューで判明したギャップを埋める深掘り調査
3. SubAgentが返却した結果（ファイルパス、主要な発見事項、仮説検証の要約）を受け取る
4. レビューゲートへ進む

### Step 10: 統合・分析 [AI]

1. デスクリサーチ結果を読み込み
2. インタビュー結果と統合
3. 論点ごとに分析・示唆を整理
4. `Output/分析結果.md`に出力

### Step 11: 報告書作成 [AI]

1. 報告書骨子と分析結果を統合
2. 最終報告書を作成
3. `Output/最終報告書.md`に出力

## 連携スキル・SubAgent

| ステップ | スキル / SubAgent | 用途 |
|----------|-------------------|------|
| Step 1, 3 | `interview-research-proposal` (Skill) | 提案書作成・更新 |
| Step 2, 9 | `desk-researcher` (SubAgent) → `desk-research` (Skill) | デスクリサーチ実行（コンテキスト分離） |
| Step 4 | `interview-guide-creator` (Skill) | インタビューガイド作成 |
| Step 5 | `report-outline-creator` (Skill) | 報告書骨子作成 |
| Step 6 | `interview-candidate-selector` (Skill) | インタビュー対象者選定・評価 |
| Step 7 | `interview-minutes-creator` (Skill) | インタビュー議事録作成 |
| Step 2 | `docx-to-markdown-with-references` (Skill) | docx変換（必要時） |
| 全ステップ | `quality-reviewer` (SubAgent) | レビューゲートでの品質チェック |

### スキル呼び出し手順

**Step 1, 3（提案書作成・更新）**:
```
1. ~/.cursor/skills/consulting/project-type/Interview-research-project/interview-research-proposal/SKILL.md を読み込む
2. references/quality_playbook.md も読み込む（品質基準）
3. スキルの指示に従って提案書を作成/更新
```

**Step 2（初期デスクトップ調査）** ※ SubAgent経由:
```
1. ユーザーに提案書のパスと出力先フォルダを確認
2. desk-researcher SubAgent（~/.cursor/agents/desk-researcher.md）を起動
   - 提案書パス、出力先フォルダ、モード: initial を指定
3. SubAgentの返却結果（ファイルパス、発見事項、仮説検証要約）を受け取る
4. レビューゲートへ進む
```

**Step 9（詳細デスクリサーチ）** ※ SubAgent経由:
```
1. 提案書、インタビューまとめ、既存調査結果のパスを確認
2. ユーザーに出力先フォルダを確認
3. desk-researcher SubAgent（~/.cursor/agents/desk-researcher.md）を起動
   - 提案書パス、インタビューまとめパス、既存調査パス、出力先フォルダ、モード: detailed を指定
4. SubAgentの返却結果（ファイルパス、発見事項、仮説検証要約）を受け取る
5. レビューゲートへ進む
```

**Step 4（インタビューガイド作成）**:
```
1. ~/.cursor/skills/Interview-research-project/interview-guide-creator/SKILL.md を読み込む
2. Output/提案書.md から論点・仮説を確認
3. Input/初期調査結果.md から未検証事項を把握
4. スキルの指示に従ってインタビューガイドを作成
```

**Step 5（報告書骨子作成）**:
```
1. ~/.cursor/skills/report-outline-creator/SKILL.md を読み込む
2. Output/提案書.md から論点・仮説・納品物定義を確認
3. Output/インタビューガイド.md から検証事項を確認
4. Input/初期調査結果.md から調査で得た情報を把握
5. プロジェクト種類を判定し、references/structure_templates.md を参照
6. スキルの指示に従って報告書骨子を作成
```

**Step 6（インタビュー対象者選定）**:
```
1. ~/.cursor/skills/Interview-research-project/interview-candidate-selector/SKILL.md を読み込む
2. Output/インタビューガイド.md から対象者タイプ定義を抽出
3. Interview/ 内の候補者リストを読み込む（xlsxスキルを活用）
4. スキルの指示に従って対象者を選定・評価
```

**Step 7（インタビュー議事録作成）**:
```
1. ~/.cursor/skills/Interview-research-project/interview-minutes-creator/SKILL.md を読み込む
2. Input/インタビュー/ 内の文字起こしファイルを確認
3. Output/インタビューガイド.md の質問リストを参照
4. スキルの指示に従って議事録を作成
```

## 成果物一覧

| ステップ | 成果物 | 格納先 |
|----------|--------|--------|
| Step 1, 3 | 提案書 | `Output/提案書.md` |
| Step 2 | 初期調査結果 | ユーザー指定の出力先フォルダ |
| Step 4 | インタビューガイド | `Output/インタビューガイド.md` |
| Step 5 | 報告書骨子 | `Output/報告書骨子.md` |
| Step 6 | インタビュー対象者 | `Output/インタビュー対象者.md` |
| Step 7 | 議事録 | `Output/議事録/` |
| Step 8 | インタビューまとめ | `Output/インタビューまとめ.md` |
| Step 9 | デスクリサーチ結果 | ユーザー指定の出力先フォルダ |
| Step 10 | 分析結果 | `Output/分析結果.md` |
| Step 11 | 最終報告書 | `Output/最終報告書.md` |
