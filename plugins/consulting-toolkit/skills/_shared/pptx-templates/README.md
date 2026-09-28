# _shared/pptx-templates — スキル横断の既定テンプレート pptx

複数スキルが**テンプレート指定を省略されたときの既定**として参照する pptx を置く。
1 スキルの配下に置くと他スキルからの参照が越境するため、共有資産としてここに集約している。

```
_shared/pptx-templates/
├── README.md
└── テンプレート.pptx     ← 既定テンプレート（800 の標準マスター）
```

## 参照しているスキル

| スキル | 使い方 |
|---|---|
| [`html-artifact`](../../html-artifact/SKILL.md) | PPTX 変換セーフモードで生成する HTML の、想定変換先テンプレート |
| [`html-to-deck`](../../html-to-deck/SKILL.md) | `--template` 省略時の変換先テンプレート |
| [`deck`](../../deck/SKILL.md) | `--template` 省略時の変換先テンプレート（html-to-deck へ引き渡す） |
| [`pptx-from-reference`](../../pptx-from-reference/SKILL.md) | `reference-decks/` と併せて、既定で解析対象に含める参照デッキ |

参照パスはいずれも
`${CLAUDE_PLUGIN_ROOT}/skills/_shared/pptx-templates/テンプレート.pptx`。

## ルール

- **`テンプレート.pptx` のファイル名は変えない**。リネーム・削除・移動をすると上記スキルの既定が壊れる。
  差し替えるときは同じファイル名のまま置き換える。
- 別のテンプレートを使いたいときは、各スキルに `--template <path>` を渡す（既定は無視される）。
- 案件固有・クライアント固有の参照デッキはここに置かない。`pptx-from-reference/reference-decks/` へ。
- 機微情報を含む pptx をコミットしないこと。
