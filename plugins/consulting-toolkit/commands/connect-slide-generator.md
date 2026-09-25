---
description: slide-generator MCP（HTML デッキ → PPTX 変換）への接続をセットアップ・更新する。ブラウザでログインするだけでよい
---

`${CLAUDE_PLUGIN_ROOT}/skills/connect-slide-generator/SKILL.md` を読み、その手順に従って
`slide-generator` MCP への接続をセットアップまたは更新する。

利用者はコマンドを打たない前提で進める。ブラウザを開く前に何が起きるかを伝え、
スクリプトは必ずエージェントモード（`SG_TOKEN_AGENT=1`）かつバックグラウンドで実行し、
`SGTOKEN:` マーカーで結果を判断して平易な日本語で報告する。トークンは読まない・出さない。

ユーザーが追加で文言を入力していれば解釈に含める（例:「つながっているか確認したい」
「403 が出る」「別環境につなぎたい」）。
