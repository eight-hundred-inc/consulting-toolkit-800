# Diagram Components — 図解の統合リファレンス

業務文書 HTML 内に「概念フロー」「マトリクス」「ピラミッド」「サイクル」「関係図」「アーキ図」等の **図解** を埋め込むための統合リファレンス。components.md の 21 種では薄かった「純粋な図解表現」を補う位置付け。

**本ファイルは図解の 3 層をすべて収める**（前半＝固定 8 図解、後半＝レイアウトパターン＋作り込み図版。選び方は「図解の 3 層」節）。すべて **インライン HTML+CSS**（SVG はベン図・有向辺）で実装し、自己完結性（外部依存ゼロ）を保つ。配色は全層**単色**（`--fig-accent` 濃淡＋`--good`/`--warn`）。

外部 PNG を埋め込むのではなく、すべて **インライン HTML+CSS（SVG はベン図のみ）** で実装する。html-artifact の自己完結性（外部依存ゼロ）を維持する。

## デザイン方針

- **ハイブリッド：モノクロ基調＋アクセント 1 点**
  - 図全体は `--ink` / `--ink-soft` / `--ink-mute` / `--rule` / `--rule-soft` で構築
  - 強調は `--accent` を **1 箇所のみ**（最重要象限・推奨層・主役レイヤー等）
- テーマ（Terracotta/Navy/Forest/Charcoal）の切替に追随する（`--accent` 変数経由）
- 色は 1 色制約を維持。複数アクセントは禁止
- 図はあくまで業務文書の補助。装飾過多にしない（章タイトルの内側に置く想定）

## 利用ルール（共通）

**基本方針：積極利用**。章内容が構造的（フロー／対比／階層／サイクル／関係性）なら、テキスト＋表で済ませる前にまず図解化を検討する。図解密度の目安は `references/components.md` 末尾の付録「Markdown → HTML マッピング」の「図解への置換」節を参照。

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

> **8 図解で足りないとき**：以下に (A)「作り込み図版」と (B)「レイアウトパターン（image-generator-guide 取り込み）」を統合した。8 図解で表現できる構造はそちらを優先し、足りないときだけ下層を使う。

---

# 図解の 3 層（選び方）

図解は下から順に検討し、**下で表現できるなら上を使わない**。

1. **固定図解**（本ファイル前半の 8 種：Concept Flow / Quadrant / Pyramid / Funnel / Cycle / Venn / Org Tree / Layer Stack）。CSS 実装済み・クラスを書くだけ。
2. **レイアウトパターン**（後述 §レイアウトパターン）。スイムレーン / マトリクス / カード / ステップフロー / タイムライン。image-generator-guide の `design-patterns.md` を取り込んだ作図テンプレ。`.fig-NN` で組む。
3. **作り込み図版**（後述 §作り込み図版）。上記で形にならない、そのスライド固有の構造を per-figure CSS で 1 枚だけ作り込む。

**配色は全層共通で単色**：`--fig-accent` の濃淡ランプ（`color-mix`）＋意味色 `--good`/`--warn` のみ。色で区別せず、**濃淡・罫線・配置・ラベル・SVG 有向辺**で区別する（design-system.md「複数アクセント色禁止」を全層で遵守）。

---

# 作り込み図版（per-figure / Slide Deck 限定）

8 図解・レイアウトパターン・コンポーネントで表現しきれない、そのスライド固有の構造を `.fig-NN` 名前空間の per-figure CSS で 1 枚だけ組む。新規 CSS を足さない原則への**統制された例外**。Vertical Document には使わない。

## fig-canvas / scale 技術仕様

大きいネイティブサイズで設計し、`transform: scale` でスライド本文領域（padding 内 = **1152px** 幅）に縮小する。

```
scale = 1152 / （fig-canvas のネイティブ幅）
制約：ネイティブ高 × scale ≦ 図版領域高（Content スライドで概ね 440px）
```

- ネイティブ幅は 1300〜1500px を起点。例：1400px → `scale = 1152/1400 = 0.823`。
- `scale` は必ず `1152 / ネイティブ幅` で算出する（目分量にしない）。

マークアップ（`assets/template-slides.html` にスキャフォルド済み）：
```html
<div class="fig-wrap"><div class="fig-canvas fig-01"><!-- 図版 --></div></div>
```
per-figure 寸法はデッキの `<style>` に追記：
```css
.fig-01{ width:1400px; transform:scale(0.823); }
```

## 絶対配置キャンバスの高さ補正（重要・落とし穴）

`transform: scale` は**見た目を縮めてもレイアウト箱は縮まない**。grid/flex の図版は自然高さが出るが、**`position:absolute` で組む図版（ハブ&スポーク等）は内在高さが 0** なので `height` を明示する必要がある。ところが native 高を指定するとレイアウト箱がそのまま残り、後続要素を押し出して**スライドを突き破る**。

対処：`height` を指定したうえで **`margin-bottom: -(native高 − scaled高)`** で後続を視覚下端まで引き上げる。
```css
.fig-arch{ width:1600px; height:600px; transform:scale(0.72); transform-origin:top center;
           margin-bottom:-168px; }   /* 168 = 600 − 600×0.72 */
```

## per-figure scoped CSS 規約

- すべての独自 CSS を `.fig-NN` 配下にスコープ（`.fig-01 .cell{…}`）。グローバルな新規クラスを作らない。
- 配色は `--fig-accent`（既定 `--accent`）由来の `color-mix` 濃淡ランプ＋`--good`/`--warn` のみ。ハードコード色は使わない。
```css
.fig-01 .shade-1{ background:color-mix(in srgb, var(--fig-accent) 8%,  #fff); }
.fig-01 .shade-2{ background:color-mix(in srgb, var(--fig-accent) 18%, #fff); }
.fig-01 .shade-3{ background:color-mix(in srgb, var(--fig-accent) 30%, #fff); }
.fig-01 .bar    { background:var(--fig-accent); color:#fff; }
```
- フォントは Noto Sans JP（本文・見出し）／ JetBrains Mono（番号・ラベル・数値）。

## 作図文法

1. メッセージの構造型を見極める（分布→セル/マトリクス、時間×ワークストリーム→ガント、層→多層スタック、分解→ツリー、対比→並置、関係→ノード&エッジ）。
2. 情報の重みを視覚にマッピング（最重要＝最も濃い `--fig-accent`、補助＝淡ランプ、対象外＝`--bg-alt`）。
3. 読み順を作る（左上→右下、軸→セル、上流→下流）。
4. ネイティブ 1300〜1500px・文字 16〜24px で設計 → scale 算出 → トークン/ランプで塗る → 検証。

## 検証（3 経路・必須）

`.fig-canvas` の scale は `.slide` のビューポート scale、さらにサムネイルの `scale(0.125)` と三重に入れ子になる。**①ライブ ②印刷（PDF・`@page 1280×720`）③サムネイル** の 3 経路で、はみ出し・クリップ・重なりを確認する。`@media print` が `.slide` の transform だけ解除し、子孫 `.fig-canvas` の scale を消さないこと。

## ガードレール

- 複数アクセント色禁止 → `--fig-accent` 由来 ＋ `--good`/`--warn` のみ。
- グラデーション・テクスチャ・回転/斜め・浮遊・巨大装飾数字（200px超）・派手アニメ禁止。
- 対称的な並列対比でダーク背景にしない（VS は両側ライト）。
- 1 スライド 1 図版。8 図解・コンポーネントで表現できる構造はそちらを優先。

---

# レイアウトパターン（image-generator-guide / design-patterns.md 取り込み）

多エンティティの関係・連携・時系列・アーキを描く 5 つの汎用レイアウト。image-generator-guide の `design-patterns.md` を **丸ごと取り込み**、html-artifact 用に対応づけた。作り込み図版（`.fig-NN`）として組む。

## html-artifact への適用ルール（原典との差分）

| 観点 | 原典（image-generator-guide） | html-artifact |
|---|---|---|
| フォント | Meiryo UI | **Noto Sans JP / JetBrains Mono** |
| 出力 | PNG（screenshot.py・body自動クロップ） | **デッキ内インライン**。スライドは fig-canvas に載せ scale フィット、Vertical Document は幅可変で可 |
| 配色 | グレースケール既定＋色分けオプション | **トークン化**（下表）。色分けオプション（4P色・ステップ別色）は**既定で使わない**＝単色。意味区分のみ `--good`/`--warn` |
| 影 | shadow 可 | 抑制的な単一影 `0 2px 8px rgba(0,0,0,0.06)` まで可 |
| キャンバス | body 幅固定・高さ自動 | スライドは fig-canvas（§作り込み図版の高さ補正に従う） |

### 配色トークン対応表（原典の直値 → html-artifact）

| 原典 | 用途 | html-artifact トークン |
|---|---|---|
| `#1a1a1a` | プライマリ／ヘッダー／強調 | `var(--ink)`（強調は `var(--fig-accent)`） |
| `#333` | 本文 | `var(--ink-soft)` |
| `#555`/`#666` | ラベル・注釈 | `var(--ink-soft)` / `var(--ink-mute)` |
| `#777`/`#888`/`#999` | サブ・補助 | `var(--ink-mute)` |
| `#ccc` | ボーダー濃 | `var(--rule)` |
| `#e0e0e0` | ボーダー淡 | `var(--rule-soft)` |
| `#f5f5f5`/`#f8f8f8` | カード背景 | `var(--bg-alt)` |
| `#ffffff` | パネル | `var(--panel)` |
| フェーズ進行（濃→淡 `#1a1a1a→#888`） | 段階の進行 | `--fig-accent` の濃淡ランプ（`color-mix` 100%→淡） |
| 意味色（積極投資=緑／維持=黄／縮小=灰） | 優先度・評価 | `--good`/`--good-bg` ／ `--warn`/`--warn-bg` ／ `--bg-alt` |

## 共通部品（template-slides.html に同梱・`.fig-NN` 内で使う）

```css
/* バッジ（SSoT ピル等） */
.dgram-badge{ font-family:"JetBrains Mono",monospace; font-size:10px; font-weight:700;
  color:#fff; background:var(--fig-accent); border-radius:4px; padding:2px 9px; letter-spacing:.02em; }
/* 角丸カード */
.dgram-card{ background:var(--panel); border:1px solid var(--rule); border-radius:8px;
  padding:12px 14px; box-shadow:0 2px 8px rgba(0,0,0,0.06); }
/* 廃止/非活性ノード */
.dgram-ghost{ background:var(--bg-alt); border:1.5px dashed var(--rule); opacity:.78; box-shadow:none; }
.dgram-ghost .name{ color:var(--ink-mute); text-decoration:line-through; }
```
図版内のヘッダー（タイトル/サブタイトル）は持たせず、**スライドの `title-bar` + `message` に逃がす**のが基本。

## SVG 有向辺（idiom）

ノード間の引き渡しは inline `<svg>` の `<path>`（直線/Bézier）＋ `<marker>` 矢じり、ラベルは絶対配置の小ボックス。実線＝主、点線（`stroke-dasharray`）＝従/フィードバック。色は `--fig-accent`（意味があれば `--good`/`--warn`）。
```html
<svg class="fig-edges" viewBox="0 0 W H">
  <defs><marker id="ah" markerWidth="9" markerHeight="9" refX="6.5" refY="3.2" orient="auto">
    <path d="M0,0 L7,3.2 L0,6.4 Z" fill="currentColor"/></marker></defs>
  <path d="M..." fill="none" stroke="var(--fig-accent)" stroke-width="2.4" marker-end="url(#ah)"/>
</svg>
```

## パターン1：スイムレーン型

複数の横レーン × 縦（または横）フェーズ。プロジェクト計画・業務プロセスのツール分担に。
- 左にレーンラベル列（固定幅）、上にフェーズ/ステップヘッダー、本体はセル。`grid 132px repeat(N,1fr)` または flex。
- レーンラベル・基盤・矢印・ゴールは固定幅、本体だけ `flex:1`。
- ヘッダー＝`--fig-accent`、レーン＝中立、所有セル＝`--fig-accent` 濃淡、空セル＝`--bg-alt` 破線。
- ラベルは `white-space:nowrap`。

```css
/* CSS スケルトン（原典 design-patterns.md パターン1 をトークン化） */
.fig-swim{display:grid;grid-template-columns:138px repeat(11,1fr);gap:5px}      /* レーン列 + N ステップ列 */
.fig-swim .colh{display:flex;flex-direction:column;align-items:center;justify-content:flex-end;padding-bottom:7px;text-align:center}
.fig-swim .colh .cn{font-family:"JetBrains Mono",monospace;font-size:12px;font-weight:700;color:var(--fig-accent)}
.fig-swim .colh .cl{font-size:10.5px;color:var(--ink-soft);line-height:1.25}
.fig-swim .lane-lbl{display:flex;flex-direction:column;justify-content:center;padding:8px 12px;background:var(--panel);border:1px solid var(--rule);border-left:3px solid var(--fig-accent);border-radius:4px;font-weight:700;white-space:nowrap}
.fig-swim .sc{min-height:46px;border-radius:5px;background:var(--bg-alt);border:1px dashed var(--rule-soft)}             /* 空セル */
.fig-swim .sc.on{background:color-mix(in srgb,var(--fig-accent) 26%,#fff);border:1.5px solid var(--fig-accent)}        /* 所有セル */
.fig-swim .sc.on.sec{background:color-mix(in srgb,var(--fig-accent) 11%,#fff);border:1px solid color-mix(in srgb,var(--fig-accent) 35%,var(--rule))}
```

## パターン2：マトリクス型（N×M）

行＝カテゴリ、列＝軸のクロス。市場マップ・正本（SSoT）所有・優先度評価に。
- `display:grid; grid-template-columns:<行ラベル> repeat(N,1fr);`
- ヘッダー＝`--fig-accent`、行ラベル＝`--bg-alt`。
- セルは**密度＝`--fig-accent` 濃淡**で塗り、左端アクセントバー（`border-left:3px`）で強弱。
- 優先度 3 段が要る場合のみ：積極＝`--good`/`--good-bg`、維持＝`--warn`/`--warn-bg`、縮小＝`--bg-alt`（＝原典の緑/黄/灰の意味色対応。新規アクセント色は足さない）。
- 凡例を下部に置く。

```css
/* CSS スケルトン（原典 design-patterns.md パターン2 をトークン化） */
.fig-mtx{display:grid;grid-template-columns:300px repeat(5,1fr);gap:6px}        /* 行ラベル列 + N 軸列 */
.fig-mtx .hc{display:flex;align-items:flex-end;justify-content:center;padding:6px 4px 9px;font-weight:700;color:var(--ink);border-bottom:2px solid var(--fig-accent);text-align:center}
.fig-mtx .rh{display:flex;align-items:center;padding:8px 12px;font-weight:600;color:var(--ink);background:var(--bg-alt);border-radius:4px}
.fig-mtx .cell{min-height:56px;display:flex;flex-direction:column;align-items:center;justify-content:center;background:var(--bg-alt);border:1px dashed var(--rule);border-radius:6px}
.fig-mtx .cell.own{background:color-mix(in srgb,var(--fig-accent) 15%,#fff);border:1.5px solid var(--fig-accent);border-left:3px solid var(--fig-accent)}
/* 優先度3段（意味区分が要る場合のみ。新規アクセント色は足さない） */
.fig-mtx .cell.invest{background:var(--good-bg);border-left:3px solid var(--good)}
.fig-mtx .cell.maintain{background:var(--warn-bg);border-left:3px solid var(--warn)}
.fig-mtx .cell.shrink{background:var(--bg-alt);border-left:3px solid var(--rule)}
```

## パターン3：カード型

ヘッダー＋複数カラムのカードを縦に並べる。戦略方針・比較分析に。
- ヘッダー＝`--fig-accent`（白文字）、ボディ＝`grid repeat(N,1fr)`、カラム区切り＝`--rule`。
- 原典は 4P をカラム色で区別するが、**html-artifact では色分けせずカラムラベル＋区切り線で区別**（単色）。
- ※ 既存の **Proposal Card（components #20）／Budget Grid（#17）** と機能が重なる。**まず既存を使い**、絶対配置や SVG が要るときだけ本パターンで組む。

## パターン4：ステップフロー型

横並びのステップカードを矢印で接続。手順・プロセスに。
- 各ステップ `flex:1`、間に矢印（固定幅・SVG `▶`）。
- バッジ・仕切り線は**ステップ別色にせず**、番号＋`--fig-accent` 濃淡で段階を示す（単色）。
- フッターに出典（`.fact-list .src` 相当）を `margin-top:auto` で下端固定。
- ※ 既存の **Concept Flow（diagram 22）／Roadmap（#19）／Flow with Margin（#21）** と重なる。**まず既存を使い**、足りないときだけ本パターン。

## パターン5：タイムライン/ロードマップ型

横軸＝時間（クォーター等）、縦軸＝レーン、施策バー＋◆マイルストーン。ガント・ロードマップに。
- フェーズヘッダー＝`--fig-accent` の**濃淡ランプ**で進行を表現（原典の濃→淡グレースケールに対応）。
- レーン間＝破線（`border-bottom:1px dashed var(--rule)`）、施策バー＝`--fig-accent` 濃淡。
- マイルストーンは `◆`（疑似要素）または SVG `<polygon>`。
- ※ 既存 Roadmap（#19）は 4 相固定。**レーン付きガント**が要るときに本パターンで組む。

```css
/* CSS スケルトン（原典 design-patterns.md パターン5 をトークン化。濃→淡で進行を表現） */
.fig-tl{display:flex;flex-direction:column;gap:0}
.fig-tl .ph-row{display:flex;gap:2px;margin-left:140px}                          /* フェーズヘッダー行 */
.fig-tl .ph{flex:1;padding:10px 16px;text-align:center;font-weight:700;color:#fff;border-radius:4px 4px 0 0}
.fig-tl .ph:nth-child(1){background:var(--fig-accent)}
.fig-tl .ph:nth-child(2){background:color-mix(in srgb,var(--fig-accent) 75%,#fff)}
.fig-tl .ph:nth-child(3){background:color-mix(in srgb,var(--fig-accent) 55%,#fff)}
.fig-tl .ph:nth-child(4){background:color-mix(in srgb,var(--fig-accent) 38%,#fff)}
.fig-tl .lane{display:flex;align-items:center;min-height:48px;border-bottom:1px dashed var(--rule)}
.fig-tl .lane-lbl{width:140px;flex-shrink:0;text-align:right;padding-right:12px;font-weight:700;white-space:nowrap}
.fig-tl .lane-content{flex:1;display:flex;gap:4px;position:relative}
.fig-tl .bar{height:28px;border-radius:6px;display:flex;align-items:center;padding:0 10px;color:#fff;font-size:10px;font-weight:600;white-space:nowrap;background:var(--fig-accent)}
.fig-tl .bar.sec{background:color-mix(in srgb,var(--fig-accent) 60%,#fff)}
.fig-tl .ms::before{content:"◆";margin-right:4px;color:var(--fig-accent)}      /* マイルストーン */
```

## カラーパレット（既定＝モノトーン）

原典どおり、ブランド/意味の指定が無ければ **単色**（`--fig-accent` 濃淡＋中立トークン）。意味区分が要る箇所のみ `--good`/`--warn`。多色（4P色・ステップ別色）は**使わない**。
