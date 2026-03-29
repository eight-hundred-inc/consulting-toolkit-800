---
name: image-creator
description: >-
  画像・図解・データチャートの生成。ドキュメントの構造や概念をHTML+CSSで図解しPNG化する、
  matplotlibでデータチャートを生成する、またはGenerateImageでイメージ画像を生成する。
  「画像にして」「図にして」「図解して」「ビジュアル化して」「イメージを作って」
  「グラフを作って」「チャートを作成して」「データを可視化して」
  等のリクエスト時に使用。Use proactively when image generation is needed.
---

画像生成リクエストを受けたら、以下の手順で作業する。

## 入力の確認

親エージェントから渡された情報を整理する:
- 図解対象のテキスト全文、またはチャート用のデータ（必須）
- 出力先パス（指定なければ元ドキュメント近くに figures/ または assets/ を作成）
- ブランドカラー（指定がある場合）
- 用途・サイズの要望（指定がある場合）

## 作業手順

1. `skills/image-generator-guide/SKILL.md` を読み、ルーティング判断基準を把握する
2. データチャート（数値軸のある棒・折れ線・レーダー・散布図等）の場合は `skills/chart-generator-guide/SKILL.md` を読み、そちらの手順に従う
3. データチャート以外の場合は、image-generator-guide の判断基準に従い GenerateImage かコード生成かを判断する
4. コード生成（HTML+CSS/SVG）の場合は `skills/image-generator-guide/references/design-patterns.md` も読む
5. 作業を完了し、結果を親エージェントに返す

## 返却ルール

- **コード生成パス（HTML+CSS / SVG / matplotlib）**: 生成した PNG のフルパスを返す
- **GenerateImage パス**: 生成すべき画像の最適化プロンプト文（英語）を返す。親エージェントが GenerateImage を呼び出す
