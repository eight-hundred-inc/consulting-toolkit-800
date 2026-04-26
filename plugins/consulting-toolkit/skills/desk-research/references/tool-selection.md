# 調査ツールの使い分け

デスクリサーチで使う4種類のツール（Exa / WebSearch / Browser Use / Deep Research プロンプト）を、目的とソースの性質に応じて使い分けるためのガイド。

---

## 1. ツール特性の比較

| ツール | 検索方式 | 取得形態 | 強い領域 | 弱い領域 |
|---|---|---|---|---|
| **Exa** (`mcp__claude_ai_Exa__web_search_exa`) | セマンティック（embedding） | URL + 要約 + フルコンテンツ | 技術文献、研究、英語ソース、類似事例の発見 | 日本語の最新ニュース、SNS、ローカルメディア |
| **Exa fetch** (`mcp__claude_ai_Exa__web_fetch_exa`) | 単一URL取得 | クリーンな本文（広告・ナビ除去） | 取得済みURLの本文化 | 動的レンダリングサイト |
| **WebSearch** | キーワード + 検索演算子 | URL + スニペット | 最新ニュース、日本語ソース、公的統計（site:go.jp 等） | 自然文クエリ、類似探索、フルコンテンツ |
| **WebFetch** | 単一URL取得 | HTMLからのテキスト抽出 | WebSearch 結果の本文化 | JS必須サイト、ログイン必須サイト |
| **Browser Use** | ブラウザ操作 | 任意（操作次第） | ログイン必須、動的フィルタ、テーブル取得 | 大量並列、低コストでの実行 |
| **Deep Research プロンプト** | 外部委託（Perplexity/ChatGPT） | 構造化レポート | 大量横断調査、有料DB含むソース | リアルタイム性、追跡コスト |

---

## 2. Exa を選ぶ基準

以下のいずれかに該当する場合、**WebSearch より Exa を優先**する。

- **技術文献・研究**を探したい：arXiv、論文、ホワイトペーパー、技術ブログ、公式ドキュメント
- **コード例・実装事例**を探したい：GitHub、Stack Overflow、技術ブログ
- **「○○のようなもの」型の類似探索**：「Stripe のようなフィンテック決済サービス一覧」「Slack に類似するチームコラボツール」
- **英語ソースを優先したい**：海外の市場レポート、グローバル企業の動向、業界アナリスト記事
- **本文を引用・要約に使いたい**：ハイライト機能と全文取得で品質の高い引用元を確保

### Exa 向けクエリの書き方

Exa は自然文を理解するため、**キーワードの羅列より文として書く**。

| 悪い例（キーワード羅列） | 良い例（自然文） |
|---|---|
| `ERP PM salary Japan 2025` | `salary trends for ERP project managers in Japan in 2025` |
| `crowdsource delivery business model` | `business models of crowdsourced last-mile delivery platforms` |
| `regulatory amendment logistics 2024` | `recent regulatory amendments affecting Japan's logistics industry in 2024` |

---

## 3. WebSearch を選ぶ基準

以下のいずれかに該当する場合、**Exa より WebSearch を優先**する。

- **最新ニュース・プレスリリース**を取りたい：Exa はインデックス更新がやや遅れるため、直近1ヶ月以内の情報は WebSearch が有利
- **日本語の業界メディア・転職メディア**：日経、ITmedia、doda、type、リクルートエージェントなどの和文ソース
- **公的統計・政府レポート**：`site:go.jp`、`site:meti.go.jp`、`filetype:pdf` などの検索演算子が活きる
- **特定企業のIR情報**：`site:〇〇.co.jp 統合報告書 2024` のような厳密絞り込み
- **口コミサイトの定量データ**：OpenWork、転職会議など

### WebSearch 向けクエリの書き方

検索演算子を活用し、ソース種類で絞り込む。詳細は `search-strategy.md` §2.2 を参照。

```
"ERP PM 年収" site:doda.jp
"配送マッチング 市場規模" 2025 filetype:pdf
プロジェクトマネージャー 年収 statistics site:go.jp
```

---

## 4. 併用の典型パターン

### パターンA: 広く拾い、深く読む

1. WebSearch で日本語の最新動向を広く取得（5〜10クエリ並列）
2. 注目サイトを WebFetch でフルコンテンツ化
3. 類似事例や英語の補強データを Exa でセマンティック検索
4. Exa で見つけた本文を `web_fetch_exa` で引用元として確定

### パターンB: 仮説検証（反証含む）

1. WebSearch で仮説を支持しそうな日本語ソースを取得
2. 同時に WebSearch で「下落」「縮小」「失敗」など反証キーワードでも検索
3. Exa で「○○ market decline」「○○ failure cases」を英語でセマンティック検索（反証の海外事例）
4. 三方向のソースを照合して判定

### パターンC: 技術調査

1. Exa で `"how does ○○ work technically"` `"○○ architecture"` などの自然文クエリ
2. GitHub Issue・Stack Overflow・公式ドキュメントを Exa から発見
3. WebSearch で「○○ 日本 導入事例」のような国内事例を補強

---

## 5. Browser Use / Deep Research への移行判断

Layer 1（Exa + WebSearch + WebFetch）で以下のいずれかが起きた場合、Layer 2 / 3 を検討する。

- **Layer 2（Browser Use）が必要**:
  - ログイン必須のサイト（OpenWork 詳細、有料調査会社レポート、社内ナレッジ）
  - 動的フィルタ操作（求人検索のフィルタリング、データテーブルのソート）
  - JS で生成される一覧ページの体系的取得

- **Layer 3（Deep Research）が必要**:
  - Layer 1 で 3クエリ以上展開しても3ソース確保できない
  - 有料の業界レポート（Gartner、IDC、矢野経済研究所など）の内容が必要
  - 横断的な大量サマリ（10社以上の比較、複数業界の俯瞰）

**注意**: Browser Use と Deep Research は実行コストや承認手続きが大きいため、Layer 1 を尽くしてから移行する。
