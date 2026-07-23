# Components Catalog

このスキルで使う **30 種**のコンポーネント（基本 21 + 拡張 4 + Slide Deck 参照デザイン 5）の仕様と HTML スニペット。**新規コンポーネントは追加せず、既存の組み合わせで対応する**。

> **例外（Slide Deck format の作り込み図版のみ）**：スライドのメッセージが構造的で、本カタログ 30 種・8 図解のいずれでも表現しきれない場合に限り、`.fig-NN` 名前空間での per-figure scoped CSS による「作り込み図版／レイアウトパターン」を許可する。条件と作図文法は `references/diagram-components.md`（図解の統合リファレンス後半）を参照（配色は `--fig-accent` 由来 + `--good`/`--warn` に限定、design-system の禁止パターン遵守、1 スライド 1 図版）。Vertical Document には適用しない。

**コンポーネントの範囲**：
- 基本 21 種（#1〜#21）＋拡張 4 種（#22〜#25）は **Vertical Document / Slide Deck 両方**で使う
- 参照デザイン 5 種（#26〜#30）は **Slide Deck 専用の統一シャシ・全 5 テーマ共通**（`.slide` スコープ内で使用。Vertical Document には適用しない。テーマ切替で accent 色に自動追従する）

## 目次

1. [必須構造コンポーネント](#必須構造コンポーネント)
   - [DocHeader](#1-docheader)
   - [Cover](#2-cover)
   - [TOC](#3-toc)
   - [Section Head](#4-section-head)
   - [Summary](#5-summary)
   - [Footer](#6-footer)
2. [本文用コンポーネント](#本文用コンポーネント)
   - [Sub Head / Minor Head](#7-sub-head--minor-head)
   - [Lede](#8-lede)
   - [Body Lists](#9-body-lists)
3. [構造化データコンポーネント](#構造化データコンポーネント)
   - [KPI Row](#10-kpi-row)
   - [State Grid (As-Is / To-Be)](#11-state-grid-as-is--to-be)
   - [Scope Panel](#12-scope-panel)
   - [Report Table](#13-report-table)
   - [Rating Dots](#14-rating-dots)
   - [Insight Callout](#15-insight-callout)
   - [Priority List](#16-priority-list)
   - [Budget Grid](#17-budget-grid)
   - [Q&A Card](#18-qa-card)
   - [Roadmap](#19-roadmap)
   - [Proposal Card](#20-proposal-card)
   - [Flow with Margin](#21-flow-with-margin)
4. [拡張コンポーネント（22〜25）](#拡張コンポーネント2225)
   - [Eyebrow Bar](#22-eyebrow-bar)
   - [Hero Number](#23-hero-number)
   - [Takeaway Strip](#24-takeaway-strip)
   - [Annotation Pointer](#25-annotation-pointer)
5. [Slide Deck × Mono 参照デザイン（26〜30）](#slide-deck--mono-参照デザイン2630)
   - [Filled-Header Card](#26-filled-header-card)
   - [Value Bar](#27-value-bar)
   - [Icon Chip](#28-icon-chip)
   - [Pill Tag](#29-pill-tag)
   - [Expansion Pills](#30-expansion-pills)

---

## 必須構造コンポーネント

### 1. DocHeader

ページ最上部の固定ヘッダー。ドキュメントIDと章ナビを表示。

```html
<header class="doc-header">
  <div class="doc-header-inner">
    <div><span class="doc-id">DOC-2026-001</span> &nbsp;·&nbsp; ドキュメントタイトル</div>
    <nav>
      <a href="#sec-1">1. 章名</a>
      <a href="#sec-3">3. 章名</a>
      <a href="#summary">まとめ</a>
    </nav>
  </div>
</header>
```

**カスタマイズポイント**：`doc-id` はドキュメント管理番号。`nav` のリンクは3〜5個に絞る（主要章のみ）。

### 2. Cover

表紙。タイトル・サブタイトル・4項目のメタ情報。

```html
<section class="cover">
  <div class="cover-tag">Proposal / Planning Document</div>
  <h1 class="cover-title">タイトル（最大2行・46px）</h1>
  <p class="cover-sub">サブタイトル<br>2行程度の説明</p>

  <dl class="cover-meta">
    <div>
      <dt>Document Type</dt>
      <dd>企画案 / 提案メモ</dd>
    </div>
    <div>
      <dt>Themes</dt>
      <dd>3領域</dd>
    </div>
    <div>
      <dt>Initial Budget</dt>
      <dd>20〜30万円 / 月</dd>
    </div>
    <div>
      <dt>Issued</dt>
      <dd>2026.05</dd>
    </div>
  </dl>
</section>
```

**カスタマイズポイント**：メタ4項目はドキュメント性質に合わせて変更（例：Author / Status / Version / Date）。

### 3. TOC

ページ番号付き目次。2列レイアウト。

```html
<section class="toc">
  <div class="toc-header">
    <div class="toc-title">目次</div>
    <div class="toc-label">TABLE OF CONTENTS</div>
  </div>
  <ul class="toc-list">
    <li><a href="#sec-1"><span class="toc-num">1.</span><span class="toc-text">章名</span><span class="toc-page">P.01</span></a></li>
    <!-- 各章ごとに繰り返し -->
  </ul>
</section>
```

**注意**：`href` は各セクションの `id` と一致させる。`toc-num` と章番号（`sec-num`）を揃える。

### 4. Section Head

各章の冒頭。番号 + アイブロウ + タイトル。

```html
<section class="report-section" id="sec-1">
  <div class="sec-head">
    <div class="sec-num">01</div>
    <div class="sec-text">
      <div class="sec-eyebrow">Section 01 / Background</div>
      <h2>企画背景</h2>
    </div>
  </div>
  <!-- 章の中身がここに続く -->
</section>
```

### 5. Summary

末尾の「まとめ」セクション。クリーム背景のまま、太い上罫線で最終章であることを示す。3項目のサマリーカードを含む。**Web ページのダークフッターのようには見せない**（業務文書として最終ページが急にダーク背景になる違和感を避ける）。

```html
<section class="summary" id="summary">
  <div class="page" style="padding:0 56px">
    <div class="sum-tag">11 / Summary</div>
    <h2>まとめのキーメッセージ。<br>2行程度。</h2>
    <p style="color:var(--ink-soft);font-size:14px;line-height:1.95;max-width:880px">
      まとめの本文（200字程度）。
    </p>
    <div class="sum-grid">
      <div class="sum-card">
        <div class="num">01</div>
        <h6>ポイント1の見出し</h6>
        <p>ポイント1の説明文。</p>
      </div>
      <!-- カード3つ -->
    </div>
  </div>
</section>
```

**注意**：
- summary セクションは `.page` の外側に配置するため、内部に `.page` 相当のラッパーを入れる
- 背景はクリーム `--bg`、本文は `--ink` / `--ink-soft`、`sum-card` のみ純白パネルとして例外的に許可
- アクセント色は `sum-tag` と `sum-card .num` に使う（旧版の `--accent-soft` ではなく通常の `--accent`）

### 6. Footer

最下部の固定フッター。

```html
<footer class="footer">
  <div>DOC-2026-001 &nbsp;·&nbsp; ドキュメントタイトル</div>
  <div>Page N of N</div>
</footer>
```

---

## 本文用コンポーネント

### 7. Sub Head / Minor Head

章内の小見出し2階層。

```html
<!-- h3：小見出し（章番号 + タイトル） -->
<h3 class="sub-head"><span class="num">4.1</span>現状の課題</h3>

<!-- h4：小々見出し（左罫線アクセント） -->
<h4 class="minor-head">最小成果物</h4>
```

**ルール**：`sub-head` の num は `章番号.連番` の形式（4.1, 4.2, 4.3...）。

### 8. Lede

章冒頭のリード文。背景色付きで強調。

```html
<p class="lede">
  章の要点を1〜3文で簡潔に。読者がこの章で何を理解すべきかを明示する。
</p>
```

**使用頻度**：各章の冒頭か、特に強調したい段落のみ。乱用しない。

### 9. Body Lists

通常の箇条書きリストと番号付きリスト。

```html
<!-- 箇条書き（■のマーカー） -->
<ul class="body">
  <li>項目1</li>
  <li>項目2</li>
</ul>

<!-- 番号付き（(1) (2) ... 形式・罫線付き） -->
<ol class="body">
  <li>項目1</li>
  <li>項目2</li>
</ol>
```

---

## 構造化データコンポーネント

### 10. KPI Row

数値メタ情報を3カラムで横並び。

```html
<div class="kpi-row">
  <div class="kpi-cell">
    <div class="kpi-label">対象業務領域</div>
    <div class="kpi-value">3<span class="unit">領域</span></div>
    <div class="kpi-note">補足説明</div>
  </div>
  <div class="kpi-cell">
    <div class="kpi-label">月額予算想定</div>
    <div class="kpi-value">20-30<span class="unit">万円</span></div>
    <div class="kpi-note">補足説明</div>
  </div>
  <div class="kpi-cell">
    <div class="kpi-label">初期検証期間</div>
    <div class="kpi-value">2-4<span class="unit">週間</span></div>
    <div class="kpi-note">補足説明</div>
  </div>
</div>
```

**ルール**：3カラム固定（2や4にしない）。`kpi-value` は短く（10文字以内）。

### 11. State Grid (As-Is / To-Be)

現状と目指す姿の対比。To-Be 側がダーク背景。

```html
<div class="state-grid">
  <div class="state-box">
    <div class="state-label">As-Is / 現行業務</div>
    <div class="state-title">現状を一行で表現</div>
    <ul>
      <li>現状ポイント1</li>
      <li>現状ポイント2</li>
    </ul>
  </div>
  <div class="state-box target">
    <div class="state-label">To-Be / 目指す姿</div>
    <div class="state-title">目指す姿を一行で表現</div>
    <ul>
      <li>To-Beポイント1</li>
      <li>To-Beポイント2</li>
    </ul>
  </div>
</div>
```

**ルール**：必ず2列ペア。3列以上には拡張しない（その場合は report-table を使う）。

**`.target` ダーク背景の利用条件（重要）**：

`.state-box.target`（ダーク背景＝`var(--ink)`）は **As-Is → To-Be のような非対称比較で、To-Be 側に視線を集めたいケース専用**。以下の場合は使わない：

| シーン | 使ってよいか | 代替 |
|---|---|---|
| As-Is（現状）→ To-Be（目指す姿） | ✓ `.target` をダークに | — |
| Before / After（時系列の状態変化） | ✓ `.target` をダークに | — |
| 推奨案 vs 却下案（明確な軍配） | ✓ `.target` をダークに | — |
| **買い手ペイン vs 買われ側ペイン**（対称的な並列） | ✗ 使わない | 両方ライト（`.tc-box` 等）に統一、強調はアクセントボーダーで |
| **メリット vs デメリット**（中立的な並列） | ✗ 使わない | 同上 |
| **A案 vs B案**（フラットな比較） | ✗ 使わない | Proposal Card #20 を 2 枚並べる、または report-table |

ダーク背景は「重みのある一方」を示すサイン。両側を等価に読み比べる文脈ではダーク側の可読性が落ち、読み手に余計な認知負荷をかける。

### 12. Scope Panel

推奨スコープを強調する暖色背景パネル。

```html
<div class="scope-panel">
  <div class="scope-head">Recommended Scope</div>
  <div class="scope-sub">スコープを1行で要約</div>
  <ul>
    <li>スコープ項目1</li>
    <li>スコープ項目2</li>
    <li>スコープ項目3</li>
    <li>スコープ項目4</li>
  </ul>
</div>
```

**ルール**：箇条書きは2列グリッドで自動配置されるため、4〜10項目が見栄え良い。

### 13. Report Table

比較表・リスク対応表。ヘッダーがダーク背景。

```html
<table class="report-table">
  <thead>
    <tr>
      <th class="num-col">No.</th>
      <th>項目</th>
      <th>領域</th>
      <th>主な価値</th>
      <th class="center">評価</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td class="num">①</td>
      <td class="name">項目名（太字）</td>
      <td>領域名</td>
      <td>説明文</td>
      <td class="center"><!-- Rating Dotsを入れる --></td>
    </tr>
  </tbody>
</table>
```

**class修飾子**：
- `th.num-col` / `td.num`：番号列（中央寄せ・幅50px・accent色）
- `td.name`：項目名（太字・ink色）
- `td.center`：中央寄せ

### 14. Rating Dots

5段階評価のドット表示。Report Table 内で使うのが基本。

```html
<span class="rating">
  <span class="d on"></span>
  <span class="d on"></span>
  <span class="d on"></span>
  <span class="d"></span>
  <span class="d"></span>
</span>
```

**ルール**：必ず5個。`on` クラスでアクセント色になる。

### 15. Insight Callout

特に強調したい示唆。アクセント背景。

```html
<div class="insight">
  <div class="insight-label">Key Insight</div>
  <div class="insight-body">
    示唆の本文。1〜3文で。
  </div>
</div>
```

**使用頻度**：1章につき最大1個。乱用すると強調効果が薄れる。

### 16. Priority List

優先順位ランキング。1, 2, 3 形式。

```html
<div class="prio-list">
  <div class="prio-item">
    <div class="prio-rank">1</div>
    <div class="prio-body">
      <div class="prio-tag">First Priority</div>
      <h5>項目名</h5>
      <p><strong>キーフレーズ</strong>続く説明文。なぜ1位なのかの理由を明記する。</p>
    </div>
  </div>
  <!-- 2, 3を繰り返し -->
</div>
```

**ルール**：3〜5項目まで。それ以上は表に切り替える。

### 17. Budget Grid

2プラン比較カード。プレミアム側はダーク背景。

```html
<div class="budget-grid">
  <div class="budget-card">
    <div class="bc-head">
      <div class="bc-tag">Starter Tier</div>
      <div class="bc-amount">月 20〜30<span class="u">万円</span></div>
    </div>
    <div class="bc-body">
      <h6 style="color:var(--good)">適した進め方</h6>
      <ul class="ok">
        <li>項目1</li>
      </ul>
      <h6 class="bad">避けるべき進め方</h6>
      <ul class="ng">
        <li>項目1</li>
      </ul>
    </div>
  </div>

  <div class="budget-card premium">
    <div class="bc-head">
      <div class="bc-tag">Professional Tier</div>
      <div class="bc-amount">月 100<span class="u">万円以上</span></div>
    </div>
    <div class="bc-body">
      <h6>検討可能な範囲</h6>
      <ul class="ok">
        <li>項目1</li>
      </ul>
    </div>
  </div>
</div>
```

### 18. Q&A Card

確認事項リスト。3カラム配置が標準。

```html
<div class="qa-grid">
  <div class="qa-card">
    <div class="qa-tag">Theme ①</div>
    <h5>カードタイトル</h5>
    <ol>
      <li>質問1</li>
      <li>質問2</li>
    </ol>
  </div>
  <!-- カードを3つ並べる -->
</div>
```

**ルール**：3カードで横並び。2や4には拡張しない。

### 19. Roadmap

4フェーズの横長ロードマップ。上段がフェーズバー、下段が詳細カード。

```html
<div class="roadmap-wrap">
  <!-- 上段：フェーズバー -->
  <div class="roadmap-bar">
    <div class="phase-mini active">
      <div class="ph-num">PHASE 0</div>
      <div class="ph-name">フェーズ名</div>
      <div class="ph-period">2〜4週間</div>
    </div>
    <div class="phase-mini">
      <div class="ph-num">PHASE 1</div>
      <div class="ph-name">フェーズ名</div>
      <div class="ph-period">1〜3ヶ月</div>
    </div>
    <!-- 4フェーズ -->
  </div>

  <!-- 下段：詳細カード -->
  <div class="roadmap-detail">
    <div class="pd-card active">
      <h5>目的</h5>
      <p>フェーズの目的</p>
      <h5 style="margin-top:14px">主な内容</h5>
      <ul>
        <li>内容1</li>
        <li>内容2</li>
      </ul>
    </div>
    <!-- 4カード -->
  </div>
</div>
```

**ルール**：
- 4フェーズ固定。`active` クラスで現在地を示す（通常はPhase 0）
- **モバイル（≤920px）では1列縦並びに折りたたむ**。2x2 にしない（Phase 1→2→3→4 の線形性が崩れるため）。この挙動は `template.html` の `@media (max-width:920px)` でデフォルト保証されている
- 「行→列」の切り替えで進行方向を維持する。視線がジグザグになるレイアウトは順序の可視性を損なう

### 20. Proposal Card

提案パッケージカード。ヘッダーがダーク背景。

```html
<div class="proposal-card">
  <div class="proposal-head">
    <div class="ph-l">
      <div class="ph-tag">Phase 0</div>
      <h4>提案フェーズ名</h4>
    </div>
    <div class="ph-r">
      <div class="price">20〜30万円から</div>
      <div class="period">期間：2〜4週間</div>
    </div>
  </div>
  <div class="proposal-body">
    <div>
      <h6>実施内容</h6>
      <ul>
        <li>項目1</li>
      </ul>
    </div>
    <div>
      <h6>成果物</h6>
      <ul>
        <li>項目1</li>
      </ul>
    </div>
  </div>
</div>
```

### 21. Flow with Margin

縦長プロセス＋右側マージン注釈。業務プロセス可視化、ユーザーフロー、システム間データフロー、意思決定フロー、施行スケジュールの詳細表示などに使う。

```html
<div class="flow-margin">
  <!-- 左：本体フロー -->
  <div class="flow-main">
    <div class="flow-step" id="step-1">
      <div class="fs-num">1</div>
      <div class="fs-body">
        <div class="fs-title">ステップ名</div>
        <div class="fs-meta">
          <span class="fs-actor">担当者・部署</span>
          <span>所要時間</span>
          <span>使用ツール</span>
        </div>
        <p>ステップの説明文。1〜3行。</p>
      </div>
    </div>
    <div class="flow-conn"></div>

    <div class="flow-step" id="step-2">
      <div class="fs-num">2</div>
      <div class="fs-body">
        <div class="fs-title">次のステップ</div>
        <div class="fs-meta"><span class="fs-actor">担当者</span></div>
        <p>説明文。</p>
      </div>
    </div>
    <div class="flow-conn"></div>

    <div class="flow-step" id="step-3">
      <div class="fs-num">3</div>
      <div class="fs-body">
        <div class="fs-title">最終ステップ</div>
        <p>説明文。</p>
      </div>
    </div>
  </div>

  <!-- 右：マージン注釈（sticky） -->
  <aside class="flow-notes">
    <div class="flow-note">
      <div class="fn-label">補足 — Step 1</div>
      Step 1 の補足情報。前提条件・注意点・参考ドキュメントへの言及など。
    </div>
    <div class="flow-note warn">
      <div class="fn-label">注意 — Step 2</div>
      Step 2 の注意ポイント。失敗パターン・確認事項など。
    </div>
    <div class="flow-note">
      <div class="fn-label">補足 — Step 3</div>
      Step 3 の補足情報。
    </div>
  </aside>
</div>
```

このコンポーネント用の CSS は `assets/template.html`（Vertical Document）と `assets/template-slides.html`（Slide Deck・`.slide` スコープ）の両方に組み込み済み（`.flow-margin`, `.flow-main`, `.flow-step`, `.flow-conn`, `.flow-notes`, `.flow-note` 等）。デザイントークン（`--accent` / `--rule` / `--bg-alt` / `--warn`）を使用する。

**ルール**：
- ステップは 3〜7 個。それ以上は Roadmap への切り替えを検討
- マージン注釈は省略可。本体だけでも成立する
- `flow-note.warn` で注意系（`--warn` 色）に切り替え可能
- モバイル（920px 未満）では 1 列に折りたたまれ、注釈はステップ下に流し込まれる

---

## 拡張コンポーネント（22〜25）

メッセージ強調・巨大数字・結論バー・図解アノテーションのための拡張コンポーネント。**Slide Deck format × Mono テーマで最も映える**が、他のテーマや Vertical Document でも使ってよい。「黒帯反転」「巨大数字」「結論バー」「図解アノテーション」で構造を視覚化する。

### 22. Eyebrow Bar

スライド最上部のメタラベル。「SLIDE 05 / COMPETITIVE POSITIONING」のような構造ラベル。黒帯反転 or 罫線下のテキスト2パターン。

```html
<div class="eyebrow-bar">
  <span class="eb-num">SLIDE 05</span>
  <span class="eb-sep">／</span>
  <span class="eb-label">Competitive Positioning</span>
</div>
```

CSS は `assets/template-slides.html` に組み込み済み（`.eyebrow-bar`, `.eb-num`, `.eb-sep`, `.eb-label`）。Mono テーマと組み合わせると、小さい大文字＋トラッキング広めで上品に決まる。

**ルール**：
- 1スライドに1つ、タイトル直上に配置
- 「番号 / カテゴリ名」の二段構造を守る
- 全角句読点ではなく半角 `/` または `／` を使う

### 23. Hero Number

KPI Row が3〜5セル横並びなのに対し、Hero Number は **1つの巨大数字** を構図の主役に据える。「2,760万円」「40%」「年5,115件」のような象徴的な数字に。

```html
<div class="hero-number">
  <div class="hn-value">2,760<span class="hn-unit">万円</span></div>
  <div class="hn-label">12ヶ月コスト総額</div>
  <div class="hn-note">役員報酬比43% / 士業BPO 22%</div>
</div>
```

CSS：`.hero-number` は数字を 80-120px で表示。`.hn-label` は eyebrow 風小ラベル。Mono テーマと合わせると Hero Number が紙面の主役になる。

**ルール**：
- 1スライドに最大2つ（左右並び）まで
- 値は短く（10文字以内）
- 単位は `.hn-unit` で小さく
- KPI Row と併用しない（情報密度がかぶる）

### 24. Takeaway Strip

スライド最下部の結論バー。「★ TAKEAWAY」のラベル付きで、そのスライドの持ち帰りメッセージを1行で示す。

```html
<div class="takeaway-strip">
  <span class="ts-label">TAKEAWAY</span>
  <span class="ts-body">方針策定はファームに任せる。我々は買収後100日の現場を回す。</span>
</div>
```

CSS：黒地に白文字（Mono テーマ）または `--accent` 背景（他テーマ）。スライド最下部、`.slide-foot` の直上に配置。

**ルール**：
- 1スライドに1つ
- 30-60文字以内
- 「★」アイコンは1つだけ（複数並べない）
- Slide Deck format × Mono テーマで最も映えるが、Vertical Document や他テーマでも使ってよい

### 25. Annotation Pointer

図解（diagram）内に「★ WHITE SPACE」「ここに誰もいない」のような注釈を矢印付きで添える。Quadrant Matrix の空き象限、Concept Flow の最終ノード等、視線誘導が必要な箇所に。

```html
<div class="annotation-pointer" style="position:absolute;top:20%;left:60%">
  <div class="ap-line"></div>
  <div class="ap-text">★ WHITE SPACE<br>誰もいない</div>
</div>
```

CSS：絶対位置で配置、`.ap-line` は短い罫線、`.ap-text` は eyebrow 風の小文字ラベル。背景は透明 or 半透明白。

**ルール**：
- 1図解に最大2つ
- ラベルは10文字以内＋補足1行まで
- 図解の中央に置かない（縁か空きスペースから引き出す）
- アンカーは図解側で `position: relative` を付ける必要あり

---

## Slide Deck 統一シャシ 参照デザイン（26〜30）

参照デザイン（`AI Biz Ops Partner/assets` および `V_ビザスク/24_インフォコム/02_Phase2/Output/提案書/figures`）を踏襲する 5 種の追加コンポーネント。**Slide Deck 全 5 テーマで使える統一シャシ**（`.slide` スコープで定義。CSS は `assets/template-slides.html` に組み込み済み）。すべて `var(--accent)` 系トークンで色を取るため、テーマを Terracotta / Navy / Forest / Charcoal / Mono のどれに切り替えても、帯色・ピル色・アイコン色が自動追従する。

**Vertical Document には適用しない**（Vertical Document は別の視覚言語系を持つ）。

### 26. Filled-Header Card

黒帯ヘッダー＋淡グレーボディの主役カード。Phase / Track / セグメント / セクションごとの独立ブロックとして 3〜4 枚を横並びに配置し、Growth Model・3 本柱・Phase 概観などを構造化して見せる。内部に `.section`（`.icon-chip` 付きミニカード）や `.tag-list`（Pill Tag）を積む。

**重要：フルスライドレイアウトとして使う**。標準の `.title-bar` + `.message` の下にコンポーネントとして落とし込むのではなく、**この 3〜4 枚のカード群自体がスライド本体**として構成する。参照デザイン（`fig03-acquire-expand-scale.png`）が範例。

```html
<section class="slide" id="sN">
  <!-- 図自身のタイトル・サブタイトル（.title-bar は使わない） -->
  <div class="phase-title">
    <h2>AI Biz Ops Partner — Growth Model</h2>
    <p class="phase-subtitle-top">Acquire → Expand → Scale : 3-Phase Client Development Strategy</p>
  </div>

  <!-- 3 カード横並び -->
  <div class="phase-flow">

    <div class="phase-card">
      <div class="phase-header">
        <span class="phase-number">PHASE 1</span>
        <span class="phase-name">Acquire</span>
      </div>
      <div class="phase-subtitle">1本目の案件で入り、Expandへの接続を優先</div>
      <div class="phase-body">

        <div class="section">
          <div class="section-title"><span class="icon-chip">G</span> 目的</div>
          <ul>
            <li>クライアントのデータ状態を理解</li>
            <li>業務プロセス・課題構造を把握</li>
          </ul>
        </div>

        <div class="section">
          <div class="section-title"><span class="icon-chip">T</span> 入口テーマ例</div>
          <div class="tag-list">
            <span class="tag primary">リサーチ</span>
            <span class="tag">データ分析</span>
            <span class="tag">CRM分析</span>
          </div>
        </div>

      </div>
    </div>

    <div class="phase-arrow"><!-- SVG 矢印 --></div>

    <div class="phase-card"> ... </div>

  </div>

  <!-- スライド最下部の Value Bar（オプション。#27 参照） -->
  <div class="value-bar"> ... </div>
</section>
```

**ルール**：
- **ベースライン規範との関係（重要）**：`.phase-card`（filled-header）＞ `.section`（白の内カード）というカード内カード構造は、ベースライン規範（`_shared/slide-body-principles.md`）原則 2 のネスト禁止に該当する。したがって #26 をスライドの主役に使うのは**図版の見せ場（例外①）としてのみ**——作り込み図版と同格の扱いで、Growth Model / Phase 概観のような「この 1 枚が構造化図版」のスライドに限る。通常の Content スライド（`.title-bar`＋`.message`＋本文）の本文部品として `.phase-card` を流用しない
- **`.title-bar` + `.message` は使わない**。図自身が `.phase-title` を持つ（参照デザイン fig03 が範例。20px 太字＋12px サブタイトル、中央寄せ）
- 1 スライドに 2〜4 枚並べる（`.phase-flow` が横並び flex を担う）
- `.phase-header` は黒 `var(--accent)` 塗り＋白文字。`.phase-number` は 11px 白 55%、`.phase-name` は 19px 白 100%
- `.phase-body` は `var(--panel-soft)` 淡グレー背景。内部の `.section` は白背景＋`--card-shadow` の軽い影で「浮くカード」感を出す
- 隣接カード間の矢印は `.phase-arrow` の SVG（`stroke: var(--accent)`）
- 4 枚を超えるなら 2 段組より **別スライドに分割**する（1 スライド 1 メッセージの原則）
- 縦領域配分の目安：`.phase-title` ≈60px、カード群 ≈480〜520px、`.value-bar`（あれば）≈70px。合計は Slide の内容領域（padding 込み 720px 全域）に収める
- **`.section` の中身は 3〜5 行に絞る**（参照デザインは 2〜4 行）。詰め込むとカードが 480px を超えて value-bar が押し出される

### 27. Value Bar

スライド最下部の全幅黒帯。3〜4 アイテム＋縦罫でスライドの持ち帰りを凝縮する。Takeaway Strip（#24）が「1 行結論」なのに対し、Value Bar は「複数ステップの要約行列」。参照デザインの `.value-bar`（AI Biz Ops fig03）が規範。

```html
<div class="value-bar">
  <div class="value-bar-item">
    <div class="vb-icon">1</div>
    <div class="vb-text">案件で入り<br>課題を理解</div>
  </div>
  <div class="vb-divider"></div>
  <div class="value-bar-item">
    <div class="vb-icon">2</div>
    <div class="vb-text">月額関係を構築<br>AI運用を拡大</div>
  </div>
  <div class="vb-divider"></div>
  <div class="value-bar-item">
    <div class="vb-icon">3</div>
    <div class="vb-text">インフラ化し<br>他部門へ横展開</div>
  </div>
  <div class="vb-divider"></div>
  <div class="value-bar-item">
    <div class="vb-icon">↑</div>
    <div class="vb-text">LTV最大化<br>構造的ロックイン</div>
  </div>
</div>
```

**ルール**：
- 1 スライドに 1 つ。`.phase-flow`（Filled-Header Card 群）または独立コンテンツの**直下**・`.slide-foot` の上に配置
- 使い方は 2 通り：**(A) Filled-Header Card #26 と組み合わせて 1 枚のフルスライドを構成する**（参照デザイン fig03 の型。推奨）。**(B) 標準 Content スライド（`.title-bar` + `.message` + 本文）の締めとして最下部に追加する**（Takeaway Strip #24 の代替。3〜4 アイテムに情報を凝縮したいとき）
- アイテムは 3〜4 個まで。それ以上は情報過多
- `.vb-icon` は 32×32 の円形（`rgba(255,255,255,0.12)` 塗り）に数字 or 記号 1 文字
- `.vb-text` は 2 行に折り返す（`<br>` で明示改行）
- Takeaway Strip（#24）とは併用しない（下部の重み付けが重複するため）

### 28. Icon Chip

Filled-Header Card 内 `.section-title` の先頭に置く 18×18 の黒塗り四角＋白文字 1 字ラベル。「G=Goal」「K=Key」「S=Scale 定着」「X=Reject」「T=Theme」等のセマンティックコードで、章内の役割を最小面積で示す。

```html
<div class="section-title">
  <span class="icon-chip">G</span> 目的
</div>
```

**ルール**：
- 1 字のみ（英字 1 文字か記号 1 字）。2 字以上は不可
- 意味を持たせる（`G` = 目的、`K` = 概要、`S` = 定着、`X` = 却下基準、`T` = テーマ、`R` = 結果、`I` = インサイト 等）。**装飾目的では使わない**
- 色の派生（`.icon-chip.muted` で `#888` 塗り）は Reject / Warn 用のみ許可
- Filled-Header Card #26 の中でのみ使う想定（単独で `.section-title` の外に置かない）

### 29. Pill Tag

Filled-Header Card 内で入口テーマ・カテゴリ・分類を列挙するピル型タグ。参照デザイン `.tag` / `.tag.primary`（黒塗り優先タグ）が規範。

```html
<div class="tag-list">
  <span class="tag primary">リサーチ（最強）</span>
  <span class="tag">データ分析自動化</span>
  <span class="tag">CRM分析</span>
  <span class="tag">戦略コンサルティング</span>
</div>
```

**ルール**：
- 3〜6 個を目安。1 個や 2 個ならタグにせず文中で書く
- `.tag.primary`（黒塗り＋白文字）は「最重要」「推奨」「主軸」など **1 つだけ**強調。複数を primary にしない
- 通常タグは `#e8e8e8` 塗り＋黒文字
- タグ 1 個は 8〜16 文字以内。長い説明はタグにしない
- Filled-Header Card #26 の中でのみ使う（`.body-list` の代替として使わない）

### 30. Expansion Pills

「→ 経営企画」「→ 営業」「→ R&D」のような、横展開・派生方向を示すピル群。Pill Tag（#29）が「並列列挙」なのに対し、Expansion Pills は「起点 → 展開先」の一方向を示す黒塗りピル。参照デザイン `.expansion-item`（AI Biz Ops fig03 の Scale フェーズ）が規範。

```html
<div class="expansion-area">
  <div class="expansion-title">横展開・発展</div>
  <div class="expansion-arrows">
    <span class="expansion-item"><span class="arr">&rarr;</span> 経営企画</span>
    <span class="expansion-item"><span class="arr">&rarr;</span> 営業</span>
    <span class="expansion-item"><span class="arr">&rarr;</span> R&amp;D</span>
    <span class="expansion-item"><span class="arr">&rarr;</span> データ基盤構築</span>
  </div>
</div>
```

**ルール**：
- 3〜5 個を目安
- ピルは全て黒塗り＋白文字（Pill Tag と違い primary/通常の区別は付けない）
- `.arr` は `&rarr;`（→）を透過白（`opacity:.6`）で表示
- Filled-Header Card #26 内の `.section` に相当する位置（`.phase-body` 内）に置くのが典型。単独スライドの主役にはしない（情報密度が薄いため）

---

## コンポーネント選択ガイド

「こういう内容を表現したい」 → 「このコンポーネントを使う」の対応表。各コンポーネントは見た目のパターンであり、用途は柔軟に解釈してよい。

### 用途別

| 表現したい内容 | 使うコンポーネント |
|--------------|------------------|
| 数値の見せどころ（売上、件数、期間、規模） | KPI Row |
| 2項対比（現状vs目標、案A vs案B、メリットvsデメリット、Before/After） | State Grid |
| 範囲・対象・結論を強調表示 | Scope Panel |
| 多軸での比較（評価表・選択肢比較・リスク表・責任分担） | Report Table（+ Rating Dots） |
| 重要な示唆・キーメッセージ・経営層に伝えたい一文 | Insight Callout |
| 順位・推奨順・優先度（3〜5項目） | Priority List |
| 2案・2プランの詳細比較（プレミアム強調） | Budget Grid |
| 質問・確認・チェック・FAQ・論点 | Q&A Card |
| 段階的進行（フェーズ・プロセス・年表・施行スケジュール） | Roadmap（4 フェーズ固定） |
| 縦長プロセス＋補足注釈（ユーザーフロー・業務手順詳細） | Flow with Margin |
| パッケージ的な提示（提案内容・サービス・選択肢の中身） | Proposal Card |
| 単純な列挙 | Body List（ul.body / ol.body） |

### コンポーネントの応用例

各コンポーネントは元の名前に縛られず、形状が合えば他用途にも使う。

| コンポーネント | 想定外だが有効な使い方の例 |
|--------------|-------------------------|
| `.budget-grid` | プランA/プランB、案A/案B、自社/競合、現行/新方式 |
| `.qa-card` | 商談確認事項、検討論点、FAQ、リスクチェックリスト、ベンダー選定基準 |
| `.proposal-card` | 提案フェーズ、サービスメニュー、補助金プログラム、研修プログラム |
| `.roadmap-bar` | プロジェクトフェーズ、年表、施行スケジュール、社員のキャリアステップ |
| `.flow-margin` | 業務手順、システム間連携、意思決定フロー、ユーザージャーニー |
| `.prio-list` | 優先順位、推奨順、ベストプラクティス順位、リスク順 |
| `.state-grid` | 現行/新方式、案A/案B、定性/定量、メリット/デメリット、長所/短所 |
| `.kpi-row` | 売上指標、調査規模、プロジェクト体制、対象人数 |

迷ったら **Report Table** が万能。表として整理できるならそれが第一選択。Roadmap が固定4フェーズで合わない場合は **Flow with Margin** を検討する。

### 構造化図解が必要な場合

ここまでの 21 種は **情報パネル**（テキスト・表・カード）中心。「概念フロー」「2x2 マトリクス」「ピラミッド」「ファネル」「サイクル」「ベン図」「組織図」「レイヤー積層図」のような **視覚的な構造図** が必要な場合は、補助コンポーネント集 `references/diagram-components.md` の 22〜29 番を参照する。

| 既存（本ファイル） | 補助図解（diagram-components.md） | 使い分け |
|---|---|---|
| #11 State Grid | 23. Quadrant Matrix | State Grid は 2 列比較（As-Is/To-Be 等）。Quadrant は 2 軸 4 象限分類 |
| #16 Priority List | 24. Pyramid | Priority List は 3〜5 項目の縦リスト。Pyramid は階層構造の可視化 |
| #19 Roadmap | 22. Concept Flow | Roadmap は 4 フェーズ固定の時系列。Concept Flow は概念的な流れ |
| #21 Flow with Margin | 22. Concept Flow | Flow with Margin は業務手順の詳細＋注釈。Concept Flow は概念レベル |

情報をパネルで整理するなら本ファイルの 21 種、視覚的な構造を見せるなら diagram-components.md。

## スライド文脈での利用（Slide Deck format）

Slide Deck format（16:9 HTML スライドデッキ）でもここまでの 21 コンポーネントを **そのまま再利用**する。加えて、拡張 4 種（#22〜25、形式横断で利用可）と、**Slide Deck 統一シャシの参照デザイン 5 種（#26〜30、Filled-Header Card / Value Bar / Icon Chip / Pill Tag / Expansion Pills、5 テーマ共通で accent 色に自動追従）** をスライドの主役として使う。

**CSS の所在**：#1〜21 の CSS は Vertical Document では `assets/template.html`、Slide Deck では `assets/template-slides.html`（`.slide` スコープ・外側マージンをスライド向けに縮小済み）にそれぞれ搭載済み。デッキ側で CSS をコピー・再定義する必要はない。ただしスライドでは 2 コンポーネントに**スライド簡易形**があり、そちらが基本：Insight Callout は `.insight > .txt`（`slide-deck.md`「Content」の型。#15 の `.insight-label`/`.insight-body` 形も使える）、Scope Panel は `.scope`＋`.scope-sub`＋`ul`（#12 の `.scope-panel` 形も使える）。

**ただし「作り込み図版／レイアウトパターン」は例外**：30 種・8 図解で表現しきれない構造的メッセージのスライドに限り、`.fig-NN` 名前空間で per-figure scoped CSS を組んでよい（統制条件・作図文法・5 レイアウトパターンは `references/diagram-components.md` 後半）。既存コンポーネント／8 図解で表現できる構造はそちらを優先し、作り込み図版は最上位の選択肢として使う。

### 利用ルール

- 各スライドは `<section class="slide" id="sN">` の中身として組む（シェル仕様は `slide-deck.md`）
- **1 スライドに入れるコンポーネントは原則 1〜2 個**まで。`.title-bar` + `.message` の見出し部分に加えて、本文系コンポーネントを 1 つ（最大 2 つ）置く構成が標準
- 1 スライドに入りきらない場合は **複数スライドに分割**する。`.title-bar` のタイトル末尾に「(続き)」を付けて連結する
- 縦長スクロール前提のコンポーネント（`.flow-margin` 全体、`.roadmap-detail` 4 列全カード、12 行を超える `.report-table` 等）は **スライドあたりの規模を縮小**するか、複数スライドに割る

### コンポーネント別の目安

| コンポーネント | スライド内での扱い |
|---|---|
| `.cover` | Cover スライド専用（1 デッキに 1 枚） |
| `.toc-list` / `.toc-grid` | TOC スライド。4〜8 項目までを目安に、多ければ 2 列に分割 |
| `.kpi-row` | 1 スライドに 1 つ。3 セルが基本（5 セルなら 2 行に折り返さず 1 スライド使い切る） |
| `.state-grid` | 1 スライドに 1 つ。As-Is/To-Be の 2 列を中央に配置 |
| `.scope-panel` | 1 スライドに 1 つ。リスト 6 項目までで分割 |
| `.report-table` | 5 行 × 4 列以内が読みやすさの上限。超える場合は分割 |
| `.insight` | 1 スライドに 1 つ。本文の最後に置き、結論を 1 文で |
| `.prio-list` | 3〜5 項目で 1 スライド |
| `.budget-grid` | 2 案比較。1 スライドに 1 つ |
| `.qa-grid` | 1 スライドに 1 つ。カード 3 枚が標準（多ければ Q&A スライドを分割） |
| `.roadmap-bar` | 4 フェーズで 1 スライド。詳細カード `.roadmap-detail` は別スライドへ |
| `.proposal-card` | 1 スライドに 1 つ |
| `.flow-margin` | スライドではあまり使わない。使う場合はフロー 3〜4 ステップで止める |
| `.summary` | 最終スライド専用（1 デッキに 1 枚） |

### タイポグラフィの上書き

スライド向けに少しサイズを上げて投影で読めるようにする。`<style>` 末尾で上書きする例：

```css
.slide .message{ font-size: 17px; line-height: 1.7 }
.slide .body-list{ font-size: 14.5px; line-height: 1.85 }
.slide .insight .txt{ font-size: 15.5px; line-height: 1.7 }
.slide .fact-list{ font-size: 13.5px }
.slide table.report-table{ font-size: 13px }
.slide .summary ul li{ font-size: 17px }
```

詳細は `slide-deck.md` の「タイポグラフィ調整（スライド向け）」を参照。サイズを上げた分だけ 1 スライドに入る情報量を減らす（密度ガイドラインを守る）。

---

# 付録：Markdown → HTML マッピング

Markdown を機械的に HTML 化するのではなく、**意味を読み取って HTML コンポーネントに割り当てる**。同じ `## 見出し` でも、内容によって章番号付きの SectionHead として扱ったり、TOC エントリに追加したりする。章構成全体の処方は [`document-recipes.md`](document-recipes.md) を参照する。

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

H2 が 3 個以上ある場合、自動で Cover の後に TOC セクションを生成する（議事メモなど短い文書（3〜5 章）では省略してよい。`document-recipes.md` Recipe E 参照）。

### 章番号・小番号

H2 ごとに `sec-num`（01, 02, 03...）と `sec-eyebrow`（"Section 01 / Background" 等の英語ラベル）を自動付与。H3 ごとに `章番号.連番`（1.1, 1.2, 2.1...）を自動付与。

### Footer

ページ末尾に `<footer class="footer">` を自動追加。`DOC-ID` と「Page N of N」を表示。

## マージン注釈の検出（Flow with Margin 用）

Recipe E（議事メモ / プロセス文書）で `FlowWithMargin` を使う場合、`>` の直後に「補足:」「Note:」がある場合 → `.flow-note`、「注意:」「Warning:」「Caution:」がある場合 → `.flow-note.warn` に振り分ける。

## 保持するもの / 変更してよいもの

- **保持**：元 MD の論点・主張・事実関係・数字、著者の意図したセクション順序、強調の位置（**bold** の所在）
- **変更可**：視覚的構造（KPI Row 化・State Grid 化・Insight 化等の割り当て）、強い AI 表現の中立化（`design-system.md` の置換表）、改行・空行の整形、装飾記号（→ ▶ ✓ 等。絵文字は不可）、章番号・サブ番号の自動付与

## 図解への置換（diagram-components.md の扱い）

**原則：章内容が下表のパターンに該当する場合、テキスト＋表で済ませず、まず図解への置換を試す**。「迷ったら使わない」ではなく「**迷ったらまず図解を試す**」がデフォルト。無理に当てはめている感が出る場合のみ通常コンポーネントに戻す。

### 図解密度の目安（議事メモ・通達・速報系を除く）

| ドキュメント規模 | 構造化図解の最低含有数 |
|---|---|
| 章数 5 以下 | **1 個以上** |
| 章数 6〜10 | **2〜3 個** |
| 章数 11+ | **3〜5 個** |
| Slide Deck format | メッセージが構造的なスライドは原則 1 枚 1 図解 |

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
| 「複数レーン×時系列」「ツール分担」「スイムレーン」「正本(SSoT)所有」「アーキ図」「連携」 | レイアウトパターン／作り込み図版（diagram-components.md 後半） |

詳細は `diagram-components.md`（図解の統合リファレンス）を参照。1 ドキュメントに同じ図解を 3 個以上連続で並べない／短文・速報系は無理に入れない。
