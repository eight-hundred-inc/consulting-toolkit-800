# Markdown → HTML 構造変換ルール

Markdown を機械的に HTML 化するのではなく、**意味を読み取って HTML コンポーネントに割り当てる**。同じ `## 見出し` でも、内容によって章番号付きの SectionHead として扱ったり、TOC エントリに追加したりする。

最終的にどのコンポーネントを使うかは [`components.md`](components.md) を、章構成全体の処方は [`document-recipes.md`](document-recipes.md) を参照する。

## フロントマター処理

```yaml
---
title: "Q1 進捗レポート"
date: 2026-05-11
client: "acme"
confidential: true
tags: ["progress", "q1"]
---
```

- `title` → ページ `<title>` と Cover の `h1.cover-title`
- `date` → Cover メタの `Issued` 列、または DocHeader のタイムスタンプ
- `client` → Cover メタの 1 列に表示 + manifest 記録用
- `confidential: true` → HTML 末尾に `<!-- confidential: true -->` を埋め込む（公開時の警告トリガー）
- `tags` → Cover サブタイトル下にメタ列として展開（必要に応じて）

## ブロック要素マッピング

### 見出し

| MD | HTML | 補足 |
|----|------|------|
| `# H1` | Cover の `h1.cover-title` | 1 つだけ。複数あれば最初のみ採用 |
| `## H2` または `## 01 ○○` | `<section class="report-section" id="sec-N">` + Section Head | 章番号 + `.sec-eyebrow` + `<h2>` の3要素構造。H2 が 3 個以上で TOC 生成 |
| `### H3` | `<h3 class="sub-head"><span class="num">章番号.連番</span>...</h3>` | 章番号は自動で付与（4.1, 4.2...） |
| `#### H4` | `<h4 class="minor-head">` | 左罫線アクセント付きの小々見出し |

### 段落

- 通常段落: `<p>` のまま（`.report-section p` のスタイルが適用される）
- **章冒頭** または「**重要**」「**結論**」「**要約**」を含む 1〜3 文の段落: `<p class="lede">` で強調

### リスト

| MD | HTML | 条件 |
|----|------|------|
| `- 項目` 連続 | `<ul class="body">`（■マーカー） | 通常箇条書き |
| `1. 項目` | `<ol class="body">`（(1)(2)... 形式） | 順序付き列挙 |
| `- [ ]` チェックボックス | Q&A Card の `<ol>` 形式へ変換 | TODO・確認事項 |
| **3 セル数値リスト**（「対象3領域 / 予算20万円 / 期間4週間」等） | KPI Row | コロン区切り or 短文 3 個 |
| **「1位／2位／3位」「優先順位」表記** | Priority List | 3〜5 項目で番号と理由が明示されている |

### 引用

```markdown
> 通常の引用
```
→ `<p>` 内の `<em>` 扱い、または Lede へ昇格（章冒頭の場合）

```markdown
> [!INSIGHT]
> または「示唆：」「結論：」で始まる引用
```
→ Insight Callout

```markdown
> [!SCOPE]
> または「推奨：」「対象：」で始まる引用
```
→ Scope Panel

### コードブロック

業務文書スタイルではコードブロックの利用は基本想定しないが、技術提案・システム提案では使う：

- 短いコード: `<pre><code>` （余白控えめ、ボーダー付き）
- 長いコード（30 行超）: 通常通り表示（業務文書では折りたたみは原則使わない）

### テーブル

- 通常テーブル: `<table class="report-table">` でスタイル適用（ダークヘッダー）
- 3〜5 列で評価語（「◎○△×」等）を含む: Report Table + Rating Dots
- 2 列の対比テーブル（A 案 vs B 案、現状 vs 目標、Before vs After 等）: State Grid
- 2 案＋金額情報: Budget Grid

### 区切り線

`---` → `<hr>` (`border-top: 1px solid var(--rule)`、控えめ)

### 画像

```markdown
![alt](path/to/image.png)
```
→ `<figure><img src alt><figcaption>alt</figcaption></figure>`

- ローカル相対パス: そのまま埋め込み（HTML と同じディレクトリに画像も置く）
- 絶対 URL: そのまま埋め込み（外部依存になることに注意）
- SVG ソース: `<svg>...</svg>` をインラインで埋め込み（推奨）

### リンク

- 同一ドキュメント内: `#sec-N` ジャンプリンク
- 外部 URL: 末尾に `↗` を付け、`target="_blank" rel="noopener"`
- メールアドレス: `mailto:` リンク

## インライン要素

- `**bold**` → `<strong>`
- `*italic*` → `<em>`（業務文書ではほぼ使わない）
- `` `code` `` → `<code>`（`background: var(--bg-alt)` で控えめに）
- `~~strike~~` → `<del>`

## 構造化コンポーネントへのマッピング表

`document-recipes.md` のレシピに従って章構成を決めた上で、各章の内容パターンを以下のコンポーネントに割り当てる。

| MD パターン | 割当先コンポーネント |
|---|---|
| 章番号付き `## H2` または 文書冒頭の `## H2` | Section Head（`.sec-num` + `.sec-eyebrow` + `<h2>`） |
| H2 が 3 個以上 | TOC を Cover の下に自動生成 |
| 3 セルの数値メタ（領域 / 予算 / 期間 等） | KPI Row |
| 「As-Is / To-Be」「Before / After」「現状 / 目標」見出しペア | State Grid |
| 「推奨：」「対象：」「結論：」blockquote または見出し付きの強調枠 | Scope Panel |
| 3〜5 列の比較表 + 評価語（「◎○△×」「適合度」等） | Report Table + Rating Dots |
| 「示唆：」「Key Insight」blockquote または章末の太字 1〜3 文 | Insight Callout |
| 番号付きリストで「1位／2位／3位」「優先順位」明示 | Priority List |
| 2 案の対比 + 金額（「Starter / Professional」「Plan A / Plan B + 価格」） | Budget Grid |
| Q&A / FAQ / チェックリスト形式（質問・確認事項の列挙） | Q&A Card |
| 「Phase 1 / Phase 2 / Phase 3 / Phase 4」見出し列、4 段階で固定 | Roadmap |
| 縦長プロセス + 各ステップへの右側補足注釈 | Flow with Margin |
| 提案サービス／パッケージ説明（実施内容 + 成果物 + 期間 + 金額） | Proposal Card |
| まとめ章（3 ポイント要約 + 全体総括） | Summary（必須構造） |

## 自動生成要素

### 目次（TOC）

H2 が 3 個以上ある場合、自動で Cover の後に TOC セクションを生成：

```html
<section class="toc">
  <div class="toc-header">
    <div class="toc-title">目次</div>
    <div class="toc-label">TABLE OF CONTENTS</div>
  </div>
  <ul class="toc-list">
    <li><a href="#sec-1"><span class="toc-num">1.</span><span class="toc-text">概要</span><span class="toc-page">P.01</span></a></li>
    ...
  </ul>
</section>
```

議事メモなど短い文書（3〜5 章）では TOC を省略してよい（`document-recipes.md` Recipe E 参照）。

### 章番号・小番号

H2 ごとに `sec-num`（01, 02, 03...）と `sec-eyebrow`（"Section 01 / Background" 等の英語ラベル）を自動付与。
H3 ごとに `章番号.連番`（1.1, 1.2, 2.1...）を自動付与。

### Footer

ページ末尾に `<footer class="footer">` を自動追加。`DOC-ID` と「Page N of N」を表示。

## マージン注釈の検出（Flow with Margin 用）

Recipe E（議事メモ / プロセス文書）で `FlowWithMargin` を使う場合、以下のパターンを検出：

```markdown
1. **ステップ名** — 簡潔な説明
   > 補足: マージン注釈に出すテキスト
   > 注意: 注意系（warn 色）のマージン注釈
```

`>` の直後に「補足:」「Note:」がある場合 → `.flow-note`、「注意:」「Warning:」「Caution:」がある場合 → `.flow-note.warn` に振り分ける。

## 強い表現の置換

`design-system.md` の「AI らしさを避ける表現」テーブルに従い、生成時に自動置換。元の論点・主張は変えない。

## 保持するもの

- 元 MD の論点・主張・事実関係・数字
- 著者の意図したセクション順序
- 強調の位置（**bold** などの所在）

## 変更してよいもの

- 視覚的構造（KPI Row 化、State Grid 化、Insight 化等のコンポーネント割り当て）
- 強い AI 表現の中立化
- 改行・空行の整形
- 装飾的な記号（→ ▶ ✓ 等）の追加（ただし絵文字は使わない）
- 章番号・サブ番号の自動付与

## 構造化図解（diagram-components.md）の扱い

**原則：章内容が下表のパターンに該当する場合、テキスト＋表で済ませず、まず図解への置換を試す**。「迷ったら使わない」ではなく「**迷ったらまず図解を試す**」のがデフォルト挙動。情報密度が低くなりすぎる／無理に当てはめている感が出る場合のみ通常コンポーネント（components.md の 21 種）に戻す。

### 図解密度の目安（議事メモ・通達・速報系を除く）

| ドキュメント規模 | 構造化図解の最低含有数 |
|---|---|
| 章数 5 以下 | **1 個以上** |
| 章数 6〜10 | **2〜3 個** |
| 章数 11+ | **3〜5 個** |
| Slide Deck format（スライドデッキ） | メッセージが構造的なスライドは原則 1 枚 1 図解 |

### MD パターン → 図解の置換マップ

| MD パターン | 推奨図解 |
|---|---|
| 「A → B → C」「ステップ」「手順」「プロセス」「フロー」「順序」 | Concept Flow（横/縦） |
| 「2 軸で 4 つに分類」「象限」「マトリクス」「対比」「比較軸」「ポジショニング」 | Quadrant Matrix |
| 「N 段階で絞り込み」「ファネル」「コンバージョン」「スクリーニング」「篩」 | Funnel |
| 「PDCA」「サイクル」「ループ」「循環」「継続改善」 | Cycle |
| 「階層」「上位／下位」「ピラミッド」「ロジックツリー」「重要度」「3 階層構造」 | Pyramid |
| 「組織」「階層構造」「報告ライン」「レポートライン」「責任分担」 | Org Tree |
| 「レイヤー」「アーキテクチャ層」「スタック」「N 層構成」「基盤／応用」 | Layer Stack |
| 「重なり」「共通領域」「ベン図」「交差点」「両立」 | Venn |

### 置換の判定ロジック（積極的デフォルト）

1. 章のタイトル・サブタイトル・本文に上表のキーワードが現れる → **図解化を第一候補にする**
2. 表形式の箇条書きで「2 軸 × 4 セル」「3〜5 段階」「N 個の同列要素」が見える → **対応する図解に置換**
3. 抽象度の高い概念説明（戦略フレームワーク・全体像・関係性）→ **テキストで列挙する前に図解を検討**
4. それでも図解が冗長／無理がある場合のみ通常コンポーネントに戻す

### ガード（維持）

- 1 ドキュメントに **同じ図解を 3 個以上連続して並べない**（読み手の認知が消耗する）
- 議事メモ・通達など短文/速報系は無理に入れない（合意事項やプロセスが図解向きなら 1 個まで）
- 装飾過多にしない（章タイトル直下に置く想定）

詳細は `references/diagram-components.md` を参照。
