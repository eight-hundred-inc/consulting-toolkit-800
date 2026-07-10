# Consulting Toolkit (800)

エイトハンドレッド（800）社向けに構成した、コンサルティングプロジェクトの立ち上げから最終報告書の作成まで、ワークフロー全体をAIがサポートするスキル・コマンド・エージェント群。

調査プロジェクトでは、提案書の論点を軸にインタビューガイド・報告書骨子まで一貫して設計する。各スキルに品質基準が組み込まれており、AIタスクと人間タスクを明確に分離した協調型ワークフローで運用する。

---

## インストール

Claude Code のプラグインとしてインストールします。OS・環境を問わず動作し、更新も 1 コマンドで済みます。

**手順**

1. Claude Code を開く
2. チャット欄に以下を1行ずつ入力する

```
/plugin marketplace add eight-hundred-inc/consulting-toolkit-800
```

```
/plugin install consulting-toolkit@consulting-toolkit-800
```

3. インストール完了。Skills / Agents / Commands が使えるようになる

**更新するとき**

```
/plugin update consulting-toolkit@consulting-toolkit-800
```

> 上級者向け: `~/.claude/settings.json` に直接追加することもできます。
>
> ```json
> {
>   "extraKnownMarketplaces": {
>     "consulting-toolkit-800": {
>       "source": {
>         "source": "github",
>         "repo": "eight-hundred-inc/consulting-toolkit-800"
>       }
>     }
>   },
>   "enabledPlugins": {
>     "consulting-toolkit@consulting-toolkit-800": true
>   }
> }
> ```

---

### 動作確認

インストール後、正しく認識されているか確認します。チャット欄で以下を実行:

```
/plugin list
/plugin validate
```

`consulting-toolkit` が表示されていれば OK です。

---

## Skills

### プロジェクト管理

| スキル | 説明 | トリガー |
|--------|------|----------|
| [project-manager](plugins/consulting-toolkit/skills/project-manager/SKILL.md) | ワークフローのオーケストレーター。状態管理・進捗追跡を行い、各ステップで適切なスキルを呼び出す | 「プロジェクトを開始」「進捗確認」「次のタスク」 |

### 調査プロジェクト

デスクリサーチとインタビューを組み合わせた調査に対応する。技術動向調査、市場調査、インタビュー中心、デューデリジェンスなど幅広いプロジェクト種類をカバーする。

| スキル | 説明 | トリガー |
|--------|------|----------|
| [project-proposal](plugins/consulting-toolkit/skills/project-proposal/SKILL.md)（調査型） | 与件情報と打ち合わせメモから調査プロジェクト提案書を作成（冒頭のタイプ判定で調査型として実行） | 「調査提案書を作成して」「リサーチ提案書を作って」 |
| [interview-guide-creator](plugins/consulting-toolkit/skills/interview-guide-creator/SKILL.md) | 提案書の論点に対応したインタビューガイドを作成 | 「インタビューガイドを作成して」「質問リストを作って」 |
| [interview-candidate-selector](plugins/consulting-toolkit/skills/interview-candidate-selector/SKILL.md) | 候補者リストから最適なインタビュー対象者を選定・評価 | 「インタビュー対象者を選定して」「候補者を評価して」 |
| [interview-minutes-creator](plugins/consulting-toolkit/skills/interview-minutes-creator/SKILL.md) | 文字起こしと質問リストから詳細なインタビュー議事録を作成 | 「インタビュー議事録を作成して」「ヒアリング内容を整理して」 |
| [slide-structure-designer](plugins/consulting-toolkit/skills/slide-structure-designer/SKILL.md) | ソースドキュメントからスライドのページ構成をMDで設計。各スライドにレイアウトパターン（SLIDE-PATTERN）を割り当てる | 「スライド構成を設計して」「ページ構成を考えて」 |
| [integrated-analysis-creator](plugins/consulting-toolkit/skills/integrated-analysis-creator/SKILL.md) | 骨子設計・本文執筆・改訂の3モードで最終報告書を仕上げる。骨子設計（章立て）→ 統合分析による本文執筆（3層ピラミッド構造）→ 指摘ID管理による改訂・版管理・PPT転記までを1スキルでカバー | 「報告書骨子を作成して」「最終報告書を作成して」「統合分析して」「この指摘を反映して」 |
| [research-project-workflow](plugins/consulting-toolkit/skills/research-project-workflow/SKILL.md) | 3フェーズ・11ステップのワークフロー定義 | project-managerから自動呼び出し |

### 汎用プロジェクト

調査以外のプロジェクト（戦略策定、コンテンツ制作、システム実装、事業計画等）に対応する。

| スキル | 説明 | トリガー |
|--------|------|----------|
| [project-proposal](plugins/consulting-toolkit/skills/project-proposal/SKILL.md)（汎用型） | 与件情報から汎用プロジェクト提案書を作成（戦略・実装・コンテンツ等）。調査型と同一スキルで、冒頭のタイプ判定で分岐 | 「プロジェクト提案書を作成して」「提案書を作って」 |

### ユーティリティ

| スキル | 説明 | トリガー |
|--------|------|----------|
| [desk-research](plugins/consulting-toolkit/skills/desk-research/SKILL.md) | Exa（セマンティック検索）/ WebSearch / WebFetch / Browser Use / Deep Research プロンプトの3層で情報収集し、調査レポートを出力 | 「デスクリサーチを実行して」「初期調査をして」「市場規模を調べて」「競合調査して」 |
| [meeting-minutes-creator](plugins/consulting-toolkit/skills/meeting-minutes-creator/SKILL.md) | 会議メモから議事録を作成 | 「会議メモから議事録を作って」「打ち合わせの議事録を作成して」 |
| [800-branded-pptx](plugins/consulting-toolkit/skills/800-branded-pptx/SKILL.md) | 800社のブランドデザイン（ダークグリーン・Meiryo UI）に沿ったPowerPointを作成。pptxスキルをラップし、デザイントークンとボイラープレートを提供する | 「800風のスライドを作成」「800のpptxを作成」 |
| [subagent-creator](plugins/consulting-toolkit/skills/subagent-creator/SKILL.md) | SubAgent（エージェント定義）を作成するガイド。Skillが適切かSubAgentが適切かを判断し、適切な方を作成する | 「エージェントを作成して」「SubAgentを作って」 |
| [chart-generator-guide](plugins/consulting-toolkit/skills/chart-generator-guide/SKILL.md) | matplotlibによるデータチャート生成ガイド。ブランドパレット対応、PNG+SVG二重出力。棒・レーダー・積み上げ等7パターンのテンプレート付き | image-creatorサブエージェント経由 |
| [image-generator-guide](plugins/consulting-toolkit/skills/image-generator-guide/SKILL.md) | HTML+CSSによる構造化図解の設計ガイド。イラスト・アート系は画像生成プロンプトを返却。image-creatorサブエージェントから読み込まれる | image-creatorサブエージェント経由 |
| [html-artifact](plugins/consulting-toolkit/skills/html-artifact/SKILL.md) | Markdown を業務文書スタイルの自己完結 HTML（縦長文書 / 16:9 スライドデッキ）に変換。30 コンポーネント＋8 図解＋作り込み図版。構成 MD のパターン指定＋図版指示で構造を組む（スケルトン HTML は比率採寸の任意参照）。生成のみ（公開は html-publish、PPTX 化はブランド pptx へ） | 「HTML にして」「16:9 スライドにして」「ブラウザでめくれるプレゼンを作って」 |
| [slide-pattern-creator](plugins/consulting-toolkit/skills/slide-pattern-creator/SKILL.md) | スライド1枚のコンテンツエリア構造（レイアウトパターン）の正本。画像・PPTX からパターンを言語化した定義 MD ＋グレースケール・スケルトン HTML を生成し、`library/` に蓄積（同梱 136 パターン） | 「スライドパターンを抽出して」「SLIDE-PATTERN を生成して」 |
| [circleback-meeting-minutes](plugins/consulting-toolkit/skills/circleback-meeting-minutes/SKILL.md) | Circleback MCP から過去1週間の会議を取得し、プロジェクト関連を自動分類して議事録 MD を一括生成。複数件は並列処理 | 「Circlebackから議事録を作って」「先週の会議の議事録を作成して」 |

---

## Agents

特定の役割に特化したサブエージェント。project-managerやワークフローの各ステップから自動的に呼び出される。

| エージェント | 説明 | 呼び出しタイミング |
|-------------|------|-------------------|
| [quality-reviewer](plugins/consulting-toolkit/agents/quality-reviewer.md) | 成果物の品質レビュー専門。指定された品質チェック項目＋デフォルト5軸評価（論理構造・具体性・読み手視点・整合性・網羅性）の2層で評価し、合格/条件付き合格/要修正を判定する。提出前最終検査モードでは出典照合・NG語彙辞書突合・クリスタライズ規範検査に加え、Playwright / soffice によるレンダリング検証（HTML・pptxのレイアウト崩れ確認）まで自己完結する | AIタスク完了後のレビューゲート（review_level=fullのみ）、提出前最終検査モード（親エージェントがモード指定して起動） |
| [desk-researcher](plugins/consulting-toolkit/agents/desk-researcher.md) | デスクトップリサーチ実行専門。Exa（セマンティック検索）/ WebSearch / WebFetch / Browser Use で情報を収集し、調査レポートと仮説検証シートを出力する | Step 3（初期調査）、Step 10（詳細調査） |
| [image-creator](plugins/consulting-toolkit/agents/image-creator.md) | 画像・図解・データチャートの生成。HTML+CSSで構造化図解をPNG化、matplotlibでデータチャートを生成。イラスト・アート系は画像生成プロンプトを返却 | 「画像にして」「図にして」「図解して」「グラフを作って」「データを可視化して」 |
| [circleback-minutes-worker](plugins/consulting-toolkit/agents/circleback-minutes-worker.md) | Circleback MCP から単一会議のトランスクリプトを取得し、meeting-minutes-creator / interview-minutes-creator に従って議事録 MD を生成する専門ワーカー | circleback-meeting-minutes スキルから並列起動 |
| [slide-figure-creator](plugins/consulting-toolkit/agents/slide-figure-creator.md) | html-artifact の HTML スライドデッキで、リッチ判定に該当する作り込み図版を 1 図 1 エージェントで生成する専門ワーカー。設計→レンダ→クロップ検証→修正を反復し、デッキに埋め込む HTML フラグメントを返す | html-artifact スキルから並列起動（Step 9.5・1 図ごと） |

---

## ワークフロー

project-manager は汎用オーケストレーターとして動作し、プロジェクト種類に応じたワークフロースキルにステップ実行を委譲する。状態管理・レビューゲート・進捗追跡は project-manager が担い、各ステップの具体的な手順はワークフロースキル側に定義する。

プロジェクトの状態は3ファイルで管理する:
- **CLAUDE.md**: 静的な基本情報（クライアント名・納期・ファイル配置）。全セッションで自動ロード
- **workflow.md**: プロセス進捗（チェックリスト・成果物リンク・履歴・重要な意思決定）
- **Output/プロジェクトサマリ.md**: 知識状態（論点・仮説検証状況・リスク・主要発見事項）。プロジェクト初期化時にスケルトンを作成し、以降随時更新

与件の内容に応じて3つのパスでワークフローを決定する:

- **パスA**: 定義済みワークフローをそのまま使う
- **パスB**: 定義済みをベースにステップを追加・省略・順序変更
- **パスC**: AIが与件から新規設計する（定義済みを参照パターンとして使う）

### 定義済みワークフロー

| プロジェクト種類 | ワークフロースキル | 状態 |
|------------------|-------------------|------|
| 調査プロジェクト | [research-project-workflow](plugins/consulting-toolkit/skills/research-project-workflow/SKILL.md) | 実装済み |
| コンテンツ作成 | - | 将来追加 |
| 事業計画・戦略策定 | - | 将来追加 |
| ソフトウェア開発 | - | 将来追加 |

定義済みに合わないプロジェクトでは、AIが与件を分析してカスタムワークフローを設計する。カスタムで繰り返し使ったパターンは定義済みワークフローに昇格させる。追加手順は [project-manager/SKILL.md](plugins/consulting-toolkit/skills/project-manager/SKILL.md) の「新しいワークフロースキルの追加」を参照。

### 調査プロジェクトのワークフロー

3フェーズ・11ステップで構成される。技術動向調査、市場調査、インタビュー中心、デューデリジェンスに対応する。

```
Phase 0: 提案
┌────────────────────────────────────────────────────────────────┐
│  Step 1.  論点・仮説の設計 [AI]         → desk-researcher          │
│  Step 2.  提案書作成 [AI]              → project-proposal（調査型）   │
│  Step 3.  提案用スライド構成設計 [AI]   → slide-structure-designer    │
│  Step 4.  インタビューガイド作成 [AI]   → interview-guide-creator     │
│  Step 5.  最終報告書骨子案作成 [AI]     → integrated-analysis-creator（骨子設計モード） │
└────────────────────────────────────────────────────────────────┘
                              ↓
Phase 1: 調査
┌────────────────────────────────────────────────────────────────┐
│  Step 6.  インタビュー対象者選定 [AI]   → interview-candidate-selector│
│  (インタビュー実施) [人間]                                           │
│  Step 7.  インタビュー議事メモ作成 [AI] → interview-minutes-creator   │
│  Step 8.  インタビューまとめ [AI]                                     │
│  Step 9.  デスクリサーチ [AI]           → desk-researcher             │
└────────────────────────────────────────────────────────────────┘
                              ↓
Phase 2: 分析・とりまとめ
┌────────────────────────────────────────────────────────────────┐
│  Step 10. 最終報告書作成 [AI]           → integrated-analysis-creator（本文執筆モード） │
│  Step 11. 報告用スライド構成設計 [AI]   → slide-structure-designer    │
└────────────────────────────────────────────────────────────────┘
```

各AIステップ完了後、レビューゲートを経て次へ進む。ステップごとに `review_level` が設定されており、`full` は quality-reviewer SubAgent + ユーザー確認、`light` はユーザー確認のみで進む。

#### スライド化フロー（Step 3 / Step 11 の下流）— 4 層アーキテクチャ

提案用（Step 3）・報告用（Step 11）のスライド構成 MD は、必要に応じて HTML スライドや PPTX へと実体化する（11 ステップの外側・任意工程）。スライド生成は **内容構成・レイアウトパターン・スライドマスター・実装** の 4 層に分離されており、どの出力経路でも同じレイアウトパターンに従う。

| 層 | 担当 | 責務 |
|---|---|---|
| 1 内容構成 | `slide-structure-designer` | 1 スライド 1 メッセージの構成 MD。各スライドに `パターン指定: SLIDE-PATTERN-{name}` を割り当てる |
| 2 レイアウトパターン | `slide-pattern-creator` / `library` | **コンテンツエリアの構造の正本**（structure YAML ＋スケルトン HTML）。html-artifact は既定でパターン名＋図版指示に従い、スケルトン HTML は比率採寸の任意参照 |
| 3 スライドマスター | ブランド pptx スキル（マスター選択式）／ html-artifact テーマ | 表紙・タイトル/メッセージ行・フッター・サイズ・フォント・配色トークンのみ |
| 4 実装 | `html-artifact`（主経路）／ ブランド pptx ／ image-creator（限定用途） | パターン（構造）×マスター（スキン）に従って出力 |

```
① スライド構成 MD            ②〜③ 実装（いずれも 2 層のパターンに従う）
  slide-structure-designer ──┬──▶ html-artifact（16:9 HTML デッキ・作り込み図版）＝主経路
  ＋ パターン割当              └──▶ ブランド pptx（ネイティブ・編集可能 PPTX。配色をブランド置換）
                     （限定用途）┄▶ image-creator（HTML→PNG 画像先行 → PPTX）
```

- **2 層（パターン）が構造の正本**。html-artifact の 30 コンポーネント・8 図解や diagram-components は「スライド 1 枚の中の部品・図版内部構造」を担い、スライド全体のレイアウトは扱わない
- **html-artifact はパターン名＋図版指示で構造を組み、スケルトン HTML は比率の採寸源として任意参照する**（実験4で、スケルトン HTML 未読でも構図維持・品質ほぼ同等＝差 0.1 前後・入力トークン約半減と確認）。優先順位は 構成 MD 構図 ＞ 図版指示 ＞ HTML 寸法採寸
- **image-creator の画像先行経路は限定用途**（ビジュアル探索・画像納品時のみ。実験3・4で最も重く html-artifact で代替可能）。ただし成果物への図解・データチャート（matplotlib）の PNG 埋め込みは image-creator の本来の役割で、html-artifact が扱わない実数値チャートの唯一の生成経路
- パターン指定がないスライドは従来どおり構図の自由記述で動く（後方互換）
- ①から②③のどれに渡してもよい

---

## 使い方

### プロジェクト全体をワークフローで進める場合

1. 与件があれば `Input/` に配置しておく
2. 「プロジェクトを開始」と入力
3. プロジェクト名・クライアント名・納期・スコープを入力
4. AIが与件を分析し、ワークフローを提案:
   - 定義済みワークフローが合えばそのまま使用
   - 合わない場合はカスタム設計（既存の修正、またはゼロから設計）
5. 提案されたワークフローを確認し、承認する
6. 「次のタスク」で各ステップを順に実行（状態に応じて自動で次のアクションを提示）
7. AIステップ完了後、成果物を確認して承認または修正指示
8. 「進捗確認」で進捗をいつでも確認

### 個別スキルだけを使う場合

トリガーワードをチャットに入力する。

```
「調査提案書を作成して」       → project-proposal が起動（調査型として作成）
「提案書を作成して」           → project-proposal が起動（汎用型として作成）
「会議メモから議事録を作って」 → meeting-minutes-creator が起動
「インタビュー議事録を作成して」→ interview-minutes-creator が起動
「デスクリサーチを実行して」   → desk-research が起動
「スライド構成を設計して」     → slide-structure-designer が起動
「16:9 のスライドにして」       → html-artifact（Slide Deck format）が起動
「この構造を図解して」         → image-creator が起動
```

---

## 成果物の格納先

| 成果物 | パス |
|--------|------|
| プロジェクトサマリ | `Output/プロジェクトサマリ.md` |
| 論点・仮説 | `Output/論点・仮説.md` |
| 提案書 | `Output/提案書.md` |
| スライド構成（提案） | `Output/スライド構成_提案.md` |
| インタビューガイド | `Output/インタビューガイド.md` |
| インタビュー対象者 | `Output/インタビュー対象者.md` |
| 報告書骨子 | `Output/報告書骨子.md` |
| 議事録 | `Output/議事録/` |
| インタビューまとめ | `Output/インタビューまとめ.md` |
| 最終報告書 | `Output/最終報告書.md` |
| スライド構成（報告） | `Output/スライド構成_報告.md` |
| 進捗状況 | `workflow.md` |

---

## 推奨MCPサーバー: Exa（セマンティック検索）

`desk-research` スキルと `desk-researcher` エージェントは、[Exa](https://exa.ai/) のセマンティック検索 MCP（`mcp__claude_ai_Exa__web_search_exa` / `mcp__claude_ai_Exa__web_fetch_exa`）を **Layer 1 の主軸ツールの一つ** として利用します。Exa はキーワード一致ではなく意味で検索するため、技術文献・研究論文・GitHub / Stack Overflow・公式ドキュメント・「○○のような事例」型の類似探索・英語ソースに強く、WebSearch（最新ニュース・日本語メディア・公的統計に強い）と相互補完します。

未設定でも `WebSearch` / `WebFetch` で動作はしますが、調査の質と網羅性を最大化するために有効化を推奨します。

**Claude Code での有効化**

Claude.ai 経由（推奨・無料枠あり）か、Exa の API key を直接設定する方法があります。詳細は [Exa MCP ドキュメント](https://exa.ai/mcp) を参照してください。

| 方式 | 推奨度 | 備考 |
|------|--------|------|
| Claude.ai のコネクタ経由 | ◎ | `/mcp` で Exa を有効化。API key 管理不要 |
| Exa API key を `.mcp.json` に設定 | ○ | カスタム制御が必要な場合 |

ツールの詳細な使い分け（Exa を選ぶ基準・WebSearch を選ぶ基準・併用パターン）は [desk-research/references/tool-selection.md](plugins/consulting-toolkit/skills/desk-research/references/tool-selection.md) を参照。

---

## 併用推奨: Anthropic 公式スキルプラグイン

本プラグインはコンサルティングワークフローに特化しているため、ドキュメント操作（PPTX・Excel・PDF・Word）やスキル作成、クリエイティブ・デザイン系の参考実装といった汎用機能は [anthropics/skills](https://github.com/anthropics/skills) の公式プラグインとの併用を推奨します。

| プラグイン | 主なスキル | 用途 |
|-----------|-----------|------|
| `document-skills` | pptx, xlsx, pdf, docx, skill-creator, algorithmic-art, frontend-design, brand-guidelines 等 | ドキュメントの作成・編集・変換、スキルの新規作成・評価、クリエイティブ・デザイン・開発系の参考実装 |

Claude Code で以下を実行するとインストールできます。

```
/plugin marketplace add anthropics/skills
/plugin install document-skills@anthropic-agent-skills
```

> 本プラグインに含まれる pptx スキルは Anthropic 公式版をベースにカスタマイズしたものですが、公式版と併用しても問題ありません。

---

## 外部依存（任意）

以下のスキルは本プラグインには同梱されていない。ドキュメント中で参照している連携はこれらがインストールされている場合のみ有効で、なくても各スキルの主機能はそのまま動作する。

| スキル | 参照元 | 用途 |
|--------|--------|------|
| ブランド pptx スキル（branded-pptx 等） | スライド化フローの第 3 経路 | ネイティブ・編集可能な PPTX の作成（納品形式が PPTX のとき） |
| html-publish | html-artifact の下流 | 生成 HTML の共有 URL 公開（作者の私的インフラ前提） |
| note-article-writer / html-diagram-generator | html-artifact の「使わない」境界 | note 記事執筆・記事用図解 PNG（作者の個人スキル） |

---

## ファイル構成

| 種類 | パス |
|------|------|
| マーケットプレイスカタログ | `.claude-plugin/marketplace.json` |
| プラグインマニフェスト | `plugins/consulting-toolkit/.claude-plugin/plugin.json` |
| Skills | `plugins/consulting-toolkit/skills/` |
| Commands | `plugins/consulting-toolkit/commands/` |
| Agents | `plugins/consulting-toolkit/agents/` |

---

## ディレクトリ構成

```
consulting-toolkit-800/
├── .claude-plugin/
│   └── marketplace.json              # マーケットプレイスカタログ
├── README.md
├── LICENSE.md
└── plugins/
    └── consulting-toolkit/           # プラグイン本体
        ├── .claude-plugin/
        │   └── plugin.json           # プラグインマニフェスト
        ├── commands/
        │   └── pm.md
        ├── skills/
        │   ├── project-manager/
        │   ├── interview-guide-creator/
        │   ├── interview-candidate-selector/
        │   ├── interview-minutes-creator/
        │   ├── slide-structure-designer/
        │   ├── slide-pattern-creator/        # レイアウトパターンの正本（library/ に 136 パターン）
        │   ├── integrated-analysis-creator/
        │   ├── research-project-workflow/
        │   ├── project-proposal/
        │   ├── desk-research/
        │   ├── meeting-minutes-creator/
        │   ├── chart-generator-guide/
        │   ├── image-generator-guide/
        │   ├── html-artifact/
        │   ├── circleback-meeting-minutes/
        │   ├── _shared/                  # スキル共通のライティング原則
        │   └── 800-branded-pptx/         # 800社ブランドPPTX（800 固有）
        └── agents/
            ├── quality-reviewer.md
            ├── desk-researcher.md
            ├── image-creator.md
            ├── circleback-minutes-worker.md
            └── slide-figure-creator.md
```
