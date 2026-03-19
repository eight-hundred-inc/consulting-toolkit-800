---
name: research-project-workflow
description: 調査プロジェクトのワークフロー定義。3フェーズ・11ステップで構成。調査に基づく論点・仮説設計から提案書作成、インタビュー、最終報告書作成・スライド構成設計まで、デスクリサーチとインタビューを組み合わせた調査プロジェクトを管理する。project-managerから呼び出される。
---

# 調査プロジェクト ワークフロー

調査プロジェクト（技術動向調査、市場調査、インタビュー中心、デューデリジェンス）のための3フェーズ・11ステップのワークフロー定義。

## ワークフロー概要

```
Phase 0: 提案
  1. 論点・仮説の設計 [AI → SubAgent] → desk-researcher            review_level: full
  2. 提案書作成 [AI] → interview-research-proposal                review_level: full
  3. 提案用スライド構成設計 [AI] → slide-structure-designer        review_level: light
  4. インタビューガイド作成 [AI] → interview-guide-creator          review_level: full
  5. 最終報告書骨子案作成 [AI] → report-outline-creator            review_level: full

Phase 1: 調査
  6. インタビュー対象者選定 [AI] → interview-candidate-selector     review_level: light
  (インタビュー実施) [人間]
  7. インタビュー議事メモ作成 [AI] → interview-minutes-creator      review_level: full
  8. インタビューまとめ [AI]                                        review_level: light
  9. デスクリサーチ [AI → SubAgent] → desk-researcher (gap-filling)   review_level: light

Phase 2: 分析・とりまとめ
  10. 最終報告書作成 [AI] → integrated-analysis-creator              review_level: full
  11. 報告用スライド構成設計 [AI] → slide-structure-designer         review_level: light

※ review_level: full → quality-reviewer SubAgent + ユーザー確認
※ review_level: light → ユーザー確認のみ（quality-reviewerをスキップ）
```

## プロジェクト種類

このワークフローは以下のプロジェクト種類に対応。種類により各タスクの深さ・フォーカスが変化:

| 種類 | フォーカス |
|------|------------|
| **技術動向調査** | 先端技術・プレイヤー探索、技術課題・参入障壁 |
| **市場調査** | 市場規模・セグメント、競合分析 |
| **インタビュー中心** | インタビュー設計・実施が主、定性的示唆 |
| **デューデリジェンス** | 財務・事業・技術の深掘り、リスク評価 |

## ステップ詳細

各ステップの目的・入力・出力・実行手順・品質チェックは [references/phases.md](references/phases.md) を参照。

## 連携スキル・SubAgent

| ステップ | スキル / SubAgent | 用途 |
|----------|-------------------|------|
| Step 1 | `desk-researcher` (SubAgent) → `desk-research` (Skill) | 論点・仮説設計の中で探索的調査・仮説検証調査を実行 |
| Step 2 | `interview-research-proposal` (Skill) | 提案書作成 |
| Step 3, 11 | `slide-structure-designer` (Skill) | スライド構成設計（提案用・報告用） |
| Step 4 | `interview-guide-creator` (Skill) | インタビューガイド作成 |
| Step 5 | `report-outline-creator` (Skill) | 報告書骨子作成 |
| Step 6 | `interview-candidate-selector` (Skill) | インタビュー対象者選定・評価 |
| Step 7 | `interview-minutes-creator` (Skill) | インタビュー議事録作成 |
| Step 9 | `desk-researcher` (SubAgent) → `desk-research` (Skill) | ギャップ補完のデスクリサーチ |
| Step 10 | `integrated-analysis-creator` (Skill) | 統合分析・最終報告書作成 |
| 任意のステップ | `docx-to-markdown-with-references` (Skill) | docx変換（入力にdocxファイルがある場合） |
| 任意のステップ | `image-creator` (SubAgent) → `image-generator-guide` (Skill) | 図解・画像生成（成果物のビジュアル化が必要な場合） |
| 全ステップ | `quality-reviewer` (SubAgent) | レビューゲートでの品質チェック |

### スキル呼び出し手順

各ステップのスキル呼び出し手順の詳細は [references/phases.md](references/phases.md) を参照。

## 成果物一覧

| ステップ | 成果物 | 格納先 |
|----------|--------|--------|
| 初期化, Step 1〜 | プロジェクトサマリ | `Output/プロジェクトサマリ.md` |
| Step 1 | 論点・仮説（検証済み） | `Output/論点・仮説.md` |
| Step 1 | 調査レポート | ユーザー指定の出力先フォルダ |
| Step 2 | 提案書 | `Output/提案書.md` |
| Step 3 | スライド構成（提案） | `Output/スライド構成_提案.md` |
| Step 4 | インタビューガイド | `Output/インタビューガイド.md` |
| Step 5 | 報告書骨子 | `Output/報告書骨子.md` |
| Step 6 | インタビュー対象者 | `Output/インタビュー対象者.md` |
| Step 7 | 議事録 | `Output/議事録/` |
| Step 8 | インタビューまとめ | `Output/インタビューまとめ.md` |
| Step 9 | デスクリサーチ結果 | ユーザー指定の出力先フォルダ |
| Step 10 | 最終報告書 | `Output/最終報告書.md` |
| Step 11 | スライド構成（報告） | `Output/スライド構成.md` |
