# Components Catalog

このスキルで使う **21 種**のコンポーネントの仕様と HTML スニペット。**新規コンポーネントは追加せず、既存の組み合わせで対応する**。

> **例外（Slide Deck format の作り込み図版のみ）**：スライドのメッセージが構造的で、本カタログ 21 種・拡張 4 種・8 図解のいずれでも表現しきれない場合に限り、`.fig-NN` 名前空間での per-figure scoped CSS による「作り込み図版」を許可する。条件と作図文法は `references/crafted-figures.md` を参照（配色は `--fig-accent` 由来 + `--good`/`--warn` に限定、design-system の禁止パターン遵守、1 スライド 1 図版）。Vertical Document には適用しない。

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

このコンポーネント用の CSS は `assets/template.html` の `:root` 配下に組み込み済み（`.flow-margin`, `.flow-main`, `.flow-step`, `.flow-conn`, `.flow-notes`, `.flow-note` 等）。デザイントークン（`--accent` / `--rule` / `--bg-alt` / `--warn`）を使用し、紙質クリーム背景に整合させている。

**ルール**：
- ステップは 3〜7 個。それ以上は Roadmap への切り替えを検討
- マージン注釈は省略可。本体だけでも成立する
- `flow-note.warn` で注意系（`--warn` 色）に切り替え可能
- モバイル（920px 未満）では 1 列に折りたたまれ、注釈はステップ下に流し込まれる

---

## 拡張コンポーネント（22〜25）

メッセージ強調・巨大数字・結論バー・図解アノテーションのための拡張コンポーネント。**Slide Deck format × Mono テーマで最も映える**が、他のテーマや Vertical Document でも使ってよい（旧 "Consulting Pitch コンポーネント" / "Pitch Mode 専用" の形式ロックは撤廃）。「黒帯反転」「巨大数字」「結論バー」「図解アノテーション」で構造を視覚化する。

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

Slide Deck format（16:9 HTML スライドデッキ）でもここまでの 21 コンポーネントを **そのまま再利用**する。新規コンポーネントは追加しない（拡張コンポーネント 22〜25 は形式横断で利用可。先述）。

**ただし「作り込み図版」は例外**：21 種・拡張 4 種・8 図解で表現しきれない構造的メッセージのスライドに限り、`.fig-NN` 名前空間で per-figure scoped CSS を組んでよい（統制条件・作図文法は `references/crafted-figures.md`）。既存コンポーネント／8 図解で表現できる構造はそちらを優先し、作り込み図版は最上位の選択肢として使う。

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
