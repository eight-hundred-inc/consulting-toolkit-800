---
description: 成果物の提出前最終検査。quality-reviewer を提出前最終検査モードで起動し、出典照合・断定トーン・メタ言及・事実と考察の区分・AI臭表現を検査する
argument-hint: <成果物ファイルパス> [関連入力ファイル...]
---

引数で指定された成果物ファイルを対象に、提出前最終検査を実行する。引数がない場合は対象ファイルをユーザーに確認する。

1. **quality-reviewer の起動**: quality-reviewer エージェントを**提出前最終検査モード**で起動する。以下を渡す。
   - モード指定: 「提出前最終検査モード」
   - 検査対象の成果物ファイルパス（必須）
   - 関連入力ファイルパス（与件・提案書・議事録等。引数で渡されていれば。聴取事実の照合に使う）
   - 検査基準の正本: `${CLAUDE_PLUGIN_ROOT}/skills/_shared/writing-principles.md`（「提出前最終検査基準」節）と `${CLAUDE_PLUGIN_ROOT}/skills/integrated-analysis-creator/SKILL.md`（品質チェックリスト E 節）
2. **レンダリング検証**（対象が HTML / pptx の場合のみ。quality-reviewer では実行できないため親が担う）
   - HTML: `${CLAUDE_PLUGIN_ROOT}/skills/html-artifact/SKILL.md` の step 11「ビジュアル検証」の手順に従い、ブラウザでスクリーンショットを撮影して、はみ出し・見切れ・重なり・図解の矢印崩れがないかを確認する
   - pptx: スライドを画像化（LibreOffice `soffice --convert-to` 等）し、同じ観点で確認する
3. **結果報告**: quality-reviewer の返却（総合判定・検査サマリ・「箇所・問題・修正案」の3点セットの指摘一覧）に、レンダリング検証の結果を加えてユーザーに提示する。修正の実施はユーザーの承認を得てから行う（このコマンドは検査までを担い、自動修正はしない）。
