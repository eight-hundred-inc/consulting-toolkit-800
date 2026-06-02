# Diagram Components — 構造化図解の補助コンポーネント集

業務文書 HTML 内に「概念フロー」「マトリクス」「ピラミッド」「サイクル」「関係図」等の **構造化図解** を埋め込むためのコンポーネント。components.md の 21 種では薄かった「純粋な図解表現」を補う位置付け。

外部 PNG を埋め込むのではなく、すべて **インライン HTML+CSS（SVG はベン図のみ）** で実装する。html-artifact の自己完結性（外部依存ゼロ）を維持する。

## デザイン方針

- **ハイブリッド：モノクロ基調＋アクセント 1 点**
  - 図全体は `--ink` / `--ink-soft` / `--ink-mute` / `--rule` / `--rule-soft` で構築
  - 強調は `--accent` を **1 箇所のみ**（最重要象限・推奨層・主役レイヤー等）
- テーマ（Terracotta/Navy/Forest/Charcoal）の切替に追随する（`--accent` 変数経由）
- 色は 1 色制約を維持。複数アクセントは禁止
- 図はあくまで業務文書の補助。装飾過多にしない（章タイトルの内側に置く想定）

## 利用ルール（共通）

**基本方針：積極利用**。章内容が構造的（フロー／対比／階層／サイクル／関係性）なら、テキスト＋表で済ませる前にまず図解化を検討する。図解密度の目安は `references/markdown-html-mapping.md` の「構造化図解の扱い」を参照。

- 1 ドキュメントに同じ図解を **3 個以上連続して並べない**（読み手の認知が消耗する）。ただし**異なる種類**の図解を複数入れるのは積極的に推奨
- 各ノード/象限/層のラベルは **短く**（タイトル 1 行、説明 1〜2 行）
- 印刷時に `page-break-inside: avoid` が効く（template.html に組み込み済み）
- 920px 未満では多くが 1 列に折り畳まれる（コンポーネント別の挙動は CSS 末尾参照）

---

## 22. Concept Flow — 概念フロー図（横 / 縦）

ステップやプロセスの流れを矢印付きで表現する。Flow with Margin（#21）が「業務手順の詳細表示」なのに対し、Concept Flow は **概念レベルの流れ**（3〜5 ノード、各ノードは短いラベル）に特化する。

### 横フロー

```html
<figure class="diagram diagram-flow-h">
  <div class="dflow-node">
    <div class="dfn-label">入力</div>
    <div class="dfn-desc">顧客データ・契約情報</div>
  </div>
  <div class="dflow-arrow"></div>
  <div class="dflow-node">
    <div class="dfn-label">分析</div>
    <div class="dfn-desc">セグメント抽出</div>
  </div>
  <div class="dflow-arrow"></div>
  <div class="dflow-node accent">
    <div class="dfn-label">意思決定</div>
    <div class="dfn-desc">優先施策の確定</div>
  </div>
  <div class="dflow-arrow"></div>
  <div class="dflow-node">
    <div class="dfn-label">実行</div>
    <div class="dfn-desc">キャンペーン配信</div>
  </div>
  <figcaption>Figure: 顧客分析から実行までの 4 段階</figcaption>
</figure>
```

### 縦フロー

```html
<figure class="diagram diagram-flow-v">
  <div class="dflow-node">
    <div class="dfn-label">課題認識</div>
    <div class="dfn-desc">現場ヒアリングで顕在化</div>
  </div>
  <div class="dflow-arrow-v"></div>
  <div class="dflow-node accent">
    <div class="dfn-label">仮説構築</div>
    <div class="dfn-desc">3 つの初期仮説に絞り込み</div>
  </div>
  <div class="dflow-arrow-v"></div>
  <div class="dflow-node">
    <div class="dfn-label">検証</div>
    <div class="dfn-desc">定量・定性両面で評価</div>
  </div>
</figure>
```

**ルール**:
- ノード数は 3〜5 個。それ以上は Roadmap または Flow with Margin に切り替え
- 強調する場合は **1 ノードのみ** `.accent` を付ける（最終アウトプットや意思決定点）
- `<figcaption>` は省略可。複数図解が並ぶ場合は付ける

---

## 23. Quadrant Matrix — 2x2 / 4 象限マトリクス

2 軸での分類・優先度判断・戦略マッピングに使う。各象限に短いタイトルと 1〜2 行の説明、推奨象限を 1 つだけアクセント表示。

```html
<figure class="diagram diagram-quadrant">
  <div class="dq-axis-y">高 ← <span>影響度</span> → 低</div>
  <div class="dq-axis-x">低 ← <span>実現容易性</span> → 高</div>
  <div class="dq-grid">
    <div class="dq-cell">
      <div class="dq-label">戦略課題</div>
      <p>重要だが時間がかかる。中期投資の対象。</p>
    </div>
    <div class="dq-cell accent">
      <div class="dq-label">クイックウィン</div>
      <p>影響大・実現容易。最優先で着手。</p>
    </div>
    <div class="dq-cell">
      <div class="dq-label">非優先</div>
      <p>影響小・実現困難。後回し。</p>
    </div>
    <div class="dq-cell">
      <div class="dq-label">小改善</div>
      <p>影響小だが手軽。余力時に実施。</p>
    </div>
  </div>
  <figcaption>Figure: 施策の優先度マッピング</figcaption>
</figure>
```

**ルール**:
- 4 象限の配置は左上→右上→左下→右下の順（HTML の記述順）
- 軸ラベルは `<` `>` 風の不等号や `←` `→` で方向性を明示
- アクセントは **1 象限のみ**（推奨象限 / クイックウィン等）

---

## 24. Pyramid — ピラミッド図

階層・優先度・抽象度の構造を表現。3〜5 層。上層ほど少数・本質、下層ほど多数・具体。

```html
<figure class="diagram diagram-pyramid">
  <div class="dp-layer dp-l1 accent">
    <div class="dp-label">ビジョン</div>
    <div class="dp-desc">2030 年に何を実現するか</div>
  </div>
  <div class="dp-layer dp-l2">
    <div class="dp-label">戦略</div>
    <div class="dp-desc">3 つの重点領域</div>
  </div>
  <div class="dp-layer dp-l3">
    <div class="dp-label">施策</div>
    <div class="dp-desc">12 のイニシアチブ</div>
  </div>
  <div class="dp-layer dp-l4">
    <div class="dp-label">タスク</div>
    <div class="dp-desc">日次の業務オペレーション</div>
  </div>
  <figcaption>Figure: 戦略ピラミッド</figcaption>
</figure>
```

**ルール**:
- 層数は 3〜5。`.dp-l1` 〜 `.dp-l5` まで対応（CSS で幅を段階的に拡張）
- アクセントは **頂点層** または **最重要層** に 1 つだけ付与
- ラベルは短く（最大 2 行）

---

## 25. Funnel — ファネル図

逆ピラミッド形状で、上から下へ絞り込まれる流れを表現。リード獲得→商談→受注、ユーザー流入→登録→課金など。

```html
<figure class="diagram diagram-funnel">
  <div class="df-stage df-s1">
    <div class="df-label">認知</div>
    <div class="df-num">100,000</div>
    <div class="df-desc">広告インプレッション</div>
  </div>
  <div class="df-stage df-s2">
    <div class="df-label">訪問</div>
    <div class="df-num">12,500</div>
    <div class="df-desc">サイト訪問者</div>
  </div>
  <div class="df-stage df-s3">
    <div class="df-label">登録</div>
    <div class="df-num">1,800</div>
    <div class="df-desc">無料トライアル登録</div>
  </div>
  <div class="df-stage df-s4 accent">
    <div class="df-label">課金</div>
    <div class="df-num">240</div>
    <div class="df-desc">有料プラン転換</div>
  </div>
  <figcaption>Figure: 月次コンバージョンファネル</figcaption>
</figure>
```

**ルール**:
- 段数は 3〜5。`.df-s1` 〜 `.df-s5` まで対応
- 数値（`.df-num`）は JetBrains Mono、目立たせる
- アクセントは **最終段（最重要 CV ポイント）** に 1 つだけ

---

## 26. Cycle — サイクル図（PDCA / ループ）

繰り返し回るプロセスを表現。PDCA、Build-Measure-Learn、継続改善サイクルなど。CSS では円形配置の代わりに「横並び＋最後に戻り矢印」で簡略化（印刷でも崩れない）。

```html
<figure class="diagram diagram-cycle">
  <div class="dc-track">
    <div class="dc-node">
      <div class="dc-marker">P</div>
      <div class="dc-label">Plan</div>
      <div class="dc-desc">仮説と KPI を設計</div>
    </div>
    <div class="dc-arrow"></div>
    <div class="dc-node accent">
      <div class="dc-marker">D</div>
      <div class="dc-label">Do</div>
      <div class="dc-desc">小規模に実行</div>
    </div>
    <div class="dc-arrow"></div>
    <div class="dc-node">
      <div class="dc-marker">C</div>
      <div class="dc-label">Check</div>
      <div class="dc-desc">結果を測定・比較</div>
    </div>
    <div class="dc-arrow"></div>
    <div class="dc-node">
      <div class="dc-marker">A</div>
      <div class="dc-label">Act</div>
      <div class="dc-desc">標準化または改善</div>
    </div>
  </div>
  <div class="dc-loop">↻ 繰り返す</div>
  <figcaption>Figure: PDCA サイクル</figcaption>
</figure>
```

**ルール**:
- ノード数は 3〜6。それ以上は線形フロー（Concept Flow）に切り替え
- `.dc-marker` は 1 文字のラベル（P/D/C/A 等）
- 強調は **現在実施中のフェーズ** に `.accent` を 1 つ
- 920px 未満では縦並びになり、`.dc-loop` は最下部に配置

---

## 27. Venn — ベン図（2 円 / 3 円）

集合の重なり・共通領域・差分を表現。SVG で実装（CSS だけでは円の重なりが扱いにくい）。

```html
<figure class="diagram diagram-venn">
  <svg viewBox="0 0 400 240" xmlns="http://www.w3.org/2000/svg" class="dv-svg" aria-label="Venn diagram">
    <circle cx="150" cy="120" r="90" class="dv-circle" />
    <circle cx="250" cy="120" r="90" class="dv-circle" />
    <text x="100" y="125" class="dv-label">領域A</text>
    <text x="300" y="125" class="dv-label">領域B</text>
    <text x="200" y="125" class="dv-label dv-label-center">重なり</text>
  </svg>
  <div class="dv-legend">
    <div class="dv-leg-item"><span class="dv-leg-tag">A</span>顧客視点（ニーズ・課題）</div>
    <div class="dv-leg-item"><span class="dv-leg-tag">B</span>技術視点（実現可能性）</div>
    <div class="dv-leg-item accent"><span class="dv-leg-tag">A ∩ B</span>事業機会（注力領域）</div>
  </div>
  <figcaption>Figure: 顧客ニーズと技術シーズの交差</figcaption>
</figure>
```

**3 円ベン図の場合**：
```html
<svg viewBox="0 0 400 320" xmlns="http://www.w3.org/2000/svg" class="dv-svg" aria-label="3-set Venn diagram">
  <circle cx="160" cy="140" r="95" class="dv-circle" />
  <circle cx="240" cy="140" r="95" class="dv-circle" />
  <circle cx="200" cy="210" r="95" class="dv-circle" />
  <text x="100" y="140" class="dv-label">A</text>
  <text x="300" y="140" class="dv-label">B</text>
  <text x="200" y="280" class="dv-label">C</text>
  <text x="200" y="180" class="dv-label dv-label-center">A∩B∩C</text>
</svg>
```

**ルール**:
- 円は **2 個または 3 個**。4 円以上は別の表現（マトリクス等）に
- アクセントは凡例側で 1 項目（注力領域）に付与する
- SVG `<text>` は短いラベル限定。詳細は `.dv-legend` で記述

---

## 28. Org Tree — 組織図（階層ツリー）

組織構造・意思決定階層・分類ツリーを表現。3 階層まで（それ以上は専用ツールへ）。

```html
<figure class="diagram diagram-org">
  <div class="dorg-level dorg-l1">
    <div class="dorg-node accent">
      <div class="dorg-label">代表</div>
      <div class="dorg-desc">最終意思決定</div>
    </div>
  </div>
  <div class="dorg-connector"></div>
  <div class="dorg-level dorg-l2">
    <div class="dorg-node">
      <div class="dorg-label">事業部</div>
      <div class="dorg-desc">P&L 責任</div>
    </div>
    <div class="dorg-node">
      <div class="dorg-label">管理部</div>
      <div class="dorg-desc">経理・人事</div>
    </div>
    <div class="dorg-node">
      <div class="dorg-label">技術部</div>
      <div class="dorg-desc">プロダクト開発</div>
    </div>
  </div>
  <figcaption>Figure: 2026 年新組織体制</figcaption>
</figure>
```

**ルール**:
- 階層数は 2〜3 段。`.dorg-l1` / `.dorg-l2` / `.dorg-l3` を使用
- 1 階層あたりのノード数は 4 個まで（多ければレイアウト崩れ）
- `.accent` は **最上位** または **意思決定ノード** に 1 つ

---

## 29. Layer Stack — レイヤー積層図

技術スタック・責任分担・アーキテクチャ層を表現。横帯を上から下へ積む形。

```html
<figure class="diagram diagram-layers">
  <div class="dl-layer">
    <div class="dl-tag">L4</div>
    <div class="dl-body">
      <div class="dl-label">UI / プレゼンテーション層</div>
      <div class="dl-desc">React, Tailwind</div>
    </div>
  </div>
  <div class="dl-layer accent">
    <div class="dl-tag">L3</div>
    <div class="dl-body">
      <div class="dl-label">アプリケーション層</div>
      <div class="dl-desc">Next.js API Routes, ビジネスロジック</div>
    </div>
  </div>
  <div class="dl-layer">
    <div class="dl-tag">L2</div>
    <div class="dl-body">
      <div class="dl-label">データアクセス層</div>
      <div class="dl-desc">Prisma, Drizzle ORM</div>
    </div>
  </div>
  <div class="dl-layer">
    <div class="dl-tag">L1</div>
    <div class="dl-body">
      <div class="dl-label">永続化層</div>
      <div class="dl-desc">PostgreSQL on Supabase</div>
    </div>
  </div>
  <figcaption>Figure: システム構成 4 層</figcaption>
</figure>
```

**ルール**:
- 層数は 3〜6
- `.dl-tag` は短いラベル（L1〜L6、または「層 1」「層 2」等）
- アクセントは **本ドキュメントの主役レイヤー** に 1 つ（例：今回の変更対象）

---

## コンポーネント選択ガイド（図解編）

| 表現したい内容 | 使うコンポーネント |
|--------------|------------------|
| 段階的な流れ・プロセスの概念表現 | 22. Concept Flow（横/縦） |
| 2 軸での分類・優先度判断 | 23. Quadrant Matrix |
| 階層・優先度・抽象度の構造 | 24. Pyramid |
| コンバージョン・絞り込み | 25. Funnel |
| 繰り返し回るループ・改善サイクル | 26. Cycle |
| 集合・重なり・共通領域 | 27. Venn |
| 組織・意思決定階層・分類ツリー | 28. Org Tree |
| 技術スタック・責任分担・アーキ層 | 29. Layer Stack |

迷ったら：流れがあるなら **Concept Flow**、判断軸が 2 つあるなら **Quadrant**、上下関係なら **Pyramid** か **Layer Stack**。

## 既存コンポーネントとの境界

| 既存（components.md） | 新規（本ファイル） | 違い |
|---|---|---|
| #11 State Grid | 23. Quadrant Matrix | State Grid は 2 列比較（As-Is/To-Be 等）。Quadrant は 2 軸 4 象限分類 |
| #16 Priority List | 24. Pyramid | Priority List は 3〜5 項目の縦リスト。Pyramid は階層構造の可視化 |
| #19 Roadmap | 22. Concept Flow | Roadmap は 4 フェーズ固定の時系列。Concept Flow は概念的な流れ |
| #21 Flow with Margin | 22. Concept Flow | Flow with Margin は業務手順の詳細＋注釈。Concept Flow は概念フローのみ |
| #20 Proposal Card | 28. Org Tree | Proposal Card はパッケージ提示。Org Tree は階層ツリー |

迷ったら：**情報パネルとして整理する**なら既存 21 種、**視覚的な構造を見せる**なら本ファイル。

## スライド文脈での利用（Slide Deck format）

Slide Deck format（16:9 HTML スライドデッキ）でも本ファイルの 8 種図解を **そのまま再利用**する。`assets/template-slides.html` にも同じ CSS（パディング・サイズを若干コンパクト化）が組み込み済み。

### スライド向けルール

- **1 スライドに図解は 1 つだけ**。`.title-bar` + `.message` の見出し部分に加えて、図解 1 つで完結させる。Body List や Insight 等の他コンポーネントと混在させない
- **ノード数・段数を控えめに**：1280×720 に対して情報を詰めすぎない
  - Concept Flow（横）: 3〜4 ノード
  - Pyramid / Funnel: 3〜4 段
  - Cycle: 3〜4 ノード
  - Quadrant: 4 象限固定（短い説明文）
  - Org Tree: 2 階層（最大 4 子ノード）
  - Layer Stack: 3〜5 層
  - Venn: 2 円推奨（3 円は凡例が窮屈）
- スライド内のフォントは template-slides.html 側の他コンポーネントと整合（17px message、14.5px body）するよう、図解内のラベルは Noto Sans JP 14px・説明は 11.5px のまま使う
- 縦長になる図（縦フロー 5 ノード等）は **複数スライドに分割**するか、横フローに切り替える
- 配色はメイン文書と同じ。テーマ切替（Terracotta / Navy / Forest / Charcoal / Mono）で `--accent` が変わる

## CSS の配置

すべての CSS は `assets/template.html` の `<style>` ブロック末尾（`/* ============ FLOW WITH MARGIN ============ */` の後）に組み込み済み。Slide Deck format 用の `assets/template-slides.html` にも同じ CSS をパディング微調整版で組み込み済み（SUMMARY セクション直前）。コンポーネント別の CSS セクション名：

- `/* ============ DIAGRAM COMMON ============ */`
- `/* ============ DIAGRAM CONCEPT FLOW ============ */`
- `/* ============ DIAGRAM QUADRANT ============ */`
- `/* ============ DIAGRAM PYRAMID ============ */`
- `/* ============ DIAGRAM FUNNEL ============ */`
- `/* ============ DIAGRAM CYCLE ============ */`
- `/* ============ DIAGRAM VENN ============ */`
- `/* ============ DIAGRAM ORG TREE ============ */`
- `/* ============ DIAGRAM LAYER STACK ============ */`

新規 CSS をここに追加しない（テーマ切り替えで壊れる）。色は `--accent` / `--ink` / `--rule` 等の既存変数のみを使う。

> **例外（Slide Deck format の作り込み図版）**：ここまでの 8 図解で表現しきれない構造のスライドに限り、`.fig-NN` 名前空間で per-figure scoped CSS を組む「作り込み図版」を許可する。テーマ切替を壊さないため、**配色は `--fig-accent`（既定 `--accent`）由来の `color-mix` 濃淡ランプ + 既存意味色トークン（`--good`/`--warn`）に限定**し、ハードコード色は使わない（ブランド色を効かせる場合もデッキ単位で `--fig-accent` を上書きする形にする）。条件と作図文法は `references/crafted-figures.md` を参照。8 図解で足りる構造はそちらを使う。
