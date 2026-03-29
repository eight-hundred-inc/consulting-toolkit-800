# Consulting Toolkit

コンサルティングプロジェクトの立ち上げから最終報告書の作成まで、ワークフロー全体をAIがサポートするスキル・コマンド・エージェント群。

調査プロジェクトでは、提案書の論点を軸にインタビューガイド・報告書骨子まで一貫して設計する。各スキルに品質基準が組み込まれており、AIタスクと人間タスクを明確に分離した協調型ワークフローで運用する。

---

## インストール

**Claude のアカウントをお持ちなら、方法1（Claude Code Plugin）でインストールしてください。** OS を問わず 2 コマンドで完了し、Cursor にも自動で反映されます。Git のインストールも不要です。

方法2（シェルスクリプト / PowerShell）は Claude Code を使わずに Cursor 単体で利用する場合の代替手段です。

```
Claude のアカウントを持っている？
  ├─ はい → 方法1（Claude Code Plugin）★推奨
  │         ※ Cursor にも自動で反映されるので、これだけでOK
  │
  └─ いいえ（Cursor だけ使う）
       ├─ Mac / Linux → 方法2a（シェルスクリプト）
       └─ Windows     → 方法2b（PowerShell スクリプト）
```

---

### 方法1: Claude Code Plugin としてインストール（★推奨）

Claude のアカウントがあれば、この方法が最も確実です。OS・環境を問わず動作し、更新も 1 コマンドで済みます。

**手順**

1. Claude Code を開く
2. チャット欄に以下を1行ずつ入力する

```
/plugin marketplace add masaki69/consulting-toolkit
```

```
/plugin install consulting-toolkit@consulting-toolkit
```

3. インストール完了。Skills / Agents / Commands が使えるようになる

**更新するとき**

```
/plugin update consulting-toolkit@consulting-toolkit
```

**Cursor でも使える？**

はい。Claude Code でインストールしたプラグインは `~/.claude/plugins/cache/` に保存され、Cursor からも自動的に認識されます。追加の設定は不要です。

> 上級者向け: `~/.claude/settings.json` に直接追加することもできます。
>
> ```json
> {
>   "extraKnownMarketplaces": {
>     "consulting-toolkit": {
>       "source": {
>         "source": "github",
>         "repo": "masaki69/consulting-toolkit"
>       }
>     }
>   },
>   "enabledPlugins": {
>     "consulting-toolkit@consulting-toolkit": true
>   }
> }
> ```

---

### 方法2a: Cursor のみ（Mac / Linux）

> Claude のアカウントをお持ちの場合は、方法1（Claude Code Plugin）の利用を推奨します。

Claude Code を使わずに Cursor 単体で利用する場合の方法です。Git が必要です。

**事前準備: Git の確認**

ターミナルを開いて以下を実行してください。バージョン番号が表示されれば Git はインストール済みです。

```bash
git --version
```

表示されない場合は Git をインストールしてください。

- **Mac**: ターミナルで `xcode-select --install` を実行
- **Linux（Ubuntu/Debian）**: `sudo apt install git`
- **Linux（その他）**: お使いのパッケージマネージャで `git` をインストール

**インストール手順**

ターミナルで以下を実行します（コピー&ペーストで OK）。

```bash
curl -fsSL https://raw.githubusercontent.com/masaki69/consulting-toolkit/main/install.sh | bash
```

これだけで完了です。内部では以下が行われます。

1. リポジトリを `~/.local/share/consulting-toolkit` にクローン
2. Skills / Agents / Commands を `~/.cursor/` 配下にシンボリックリンクで配置

| コピー元 | 配置先 |
|----------|--------|
| `plugins/consulting-toolkit/skills/*/` | `~/.cursor/skills/` |
| `plugins/consulting-toolkit/agents/*.md` | `~/.cursor/agents/` |
| `plugins/consulting-toolkit/commands/*.md` | `~/.cursor/commands/` |

**更新するとき**

```bash
bash ~/.local/share/consulting-toolkit/install.sh --update
```

**アンインストール**

```bash
bash ~/.local/share/consulting-toolkit/install.sh --uninstall
```

---

### 方法2b: Cursor のみ（Windows）

> Claude のアカウントをお持ちの場合は、方法1（Claude Code Plugin）の利用を推奨します。

Claude Code を使わずに Cursor 単体で利用する Windows ユーザー向けです。Git for Windows が必要です。

**事前準備: Git for Windows のインストール**

1. https://git-scm.com/downloads/win にアクセス
2. 「Click here to download」からインストーラをダウンロード
3. インストーラを実行（設定はすべてデフォルトのままで OK）
4. インストール後、PowerShell を開いて確認:

```powershell
git --version
```

バージョン番号が表示されれば準備完了です。

**インストール手順**

PowerShell を開いて、以下をまとめてコピー&ペーストして実行します。

```powershell
$url = "https://raw.githubusercontent.com/masaki69/consulting-toolkit/main/install.ps1"
$f = "$env:TEMP\ct-install.ps1"
(New-Object Net.WebClient).DownloadFile($url, $f)
powershell -ExecutionPolicy Bypass -File $f
```

これだけで完了です。内部では以下が行われます。

1. リポジトリを `%USERPROFILE%\.local\share\consulting-toolkit` にクローン
2. Skills / Agents / Commands を `%USERPROFILE%\.cursor\` 配下にコピー

| コピー元 | 配置先 |
|----------|--------|
| `plugins\consulting-toolkit\skills\*\` | `%USERPROFILE%\.cursor\skills\` |
| `plugins\consulting-toolkit\agents\*.md` | `%USERPROFILE%\.cursor\agents\` |
| `plugins\consulting-toolkit\commands\*.md` | `%USERPROFILE%\.cursor\commands\` |

**更新するとき**

```powershell
powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.local\share\consulting-toolkit\install.ps1" -Update
```

**アンインストール**

```powershell
powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.local\share\consulting-toolkit\install.ps1" -Uninstall
```

---

### トラブルシューティング

**Windows: PowerShell で `ParserError` / `UnexpectedToken` が出る**

スクリプト内の日本語が文字化けし、構文エラーになっています。原因は Windows PowerShell 5.1 のエンコーディング処理です。

上記のインストールコマンド（`(New-Object Net.WebClient).DownloadFile(...)` を使う方法）で解決します。もし `Invoke-WebRequest -OutFile` を使っていた場合は、上記のコマンドに差し替えてください。

それでも解決しない場合は、ダウンロード後にエンコーディングを変換してから実行してください。

```powershell
$url = "https://raw.githubusercontent.com/masaki69/consulting-toolkit/main/install.ps1"
$f = "$env:TEMP\ct-install.ps1"
(New-Object Net.WebClient).DownloadFile($url, $f)
$c = [IO.File]::ReadAllText($f, [Text.Encoding]::UTF8)
[IO.File]::WriteAllText($f, $c, [Text.UTF8Encoding]::new($true))
powershell -ExecutionPolicy Bypass -File $f
```

---

### 動作確認

インストール後、正しく認識されているか確認します。

**Claude Code の場合**

チャット欄で以下を実行:

```
/plugin list
/plugin validate
```

`consulting-toolkit` が表示されていれば OK です。

**Cursor の場合**

1. Cursor を再起動する（インストール後の初回のみ）
2. Cursor Settings を開く
3. 「Rules」「Skills」「Subagents」の各タブに consulting-toolkit の要素が表示されていることを確認

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
| [interview-research-proposal](plugins/consulting-toolkit/skills/interview-research-proposal/SKILL.md) | 与件情報と打ち合わせメモから調査提案書を作成 | 「提案書を作成して」「プロポーザルを作って」 |
| [interview-guide-creator](plugins/consulting-toolkit/skills/interview-guide-creator/SKILL.md) | 提案書の論点に対応したインタビューガイドを作成 | 「インタビューガイドを作成して」「質問リストを作って」 |
| [interview-candidate-selector](plugins/consulting-toolkit/skills/interview-candidate-selector/SKILL.md) | 候補者リストから最適なインタビュー対象者を選定・評価 | 「インタビュー対象者を選定して」「候補者を評価して」 |
| [interview-minutes-creator](plugins/consulting-toolkit/skills/interview-minutes-creator/SKILL.md) | 文字起こしと質問リストから詳細なインタビュー議事録を作成 | 「インタビュー議事録を作成して」「ヒアリング内容を整理して」 |
| [report-outline-creator](plugins/consulting-toolkit/skills/report-outline-creator/SKILL.md) | 提案書・調査結果から最終報告書の骨子を設計 | 「報告書骨子を作成して」「章立てを設計して」 |
| [slide-structure-designer](plugins/consulting-toolkit/skills/slide-structure-designer/SKILL.md) | ソースドキュメントからスライドのページ構成をMDで設計 | 「スライド構成を設計して」「ページ構成を考えて」 |
| [integrated-analysis-creator](plugins/consulting-toolkit/skills/integrated-analysis-creator/SKILL.md) | 調査結果を論点構造に沿って統合分析し、3層ピラミッド構造の分析結果文書を作成 | 「分析結果を作成して」「統合分析して」 |
| [research-project-workflow](plugins/consulting-toolkit/skills/research-project-workflow/SKILL.md) | 3フェーズ・13ステップのワークフロー定義 | project-managerから自動呼び出し |

### ユーティリティ

| スキル | 説明 | トリガー |
|--------|------|----------|
| [desk-research](plugins/consulting-toolkit/skills/desk-research/SKILL.md) | 論点・仮説に基づくデスクトップリサーチを実行し、調査レポートを出力 | 「デスクリサーチを実行して」「初期調査をして」 |
| [agent-team-playbook](plugins/consulting-toolkit/skills/agent-team-playbook/SKILL.md) | Agent Teamの適否を判断し、適切なら要件書MDを生成する | 「Agent Teamで〜」「並行処理で〜」 |
| [meeting-minutes-creator](plugins/consulting-toolkit/skills/meeting-minutes-creator/SKILL.md) | 会議メモから議事録を作成 | 「会議メモから議事録を作って」「打ち合わせの議事録を作成して」 |
| [docx-to-markdown-with-references](plugins/consulting-toolkit/skills/docx-to-markdown-with-references/SKILL.md) | Word文書をMarkdownに変換し、参考文献を整理 | 「Wordをマークダウンに変換して」 |
| [pptx](plugins/consulting-toolkit/skills/pptx/SKILL.md) | PowerPoint（.pptx）ファイルの作成・読み込み・編集を包括的にサポート。テンプレート編集、新規作成、テキスト抽出、スライド結合・分割に対応 | 「スライドを作成して」「プレゼンを作って」「.pptxファイルを編集して」 |
| [subagent-creator](plugins/consulting-toolkit/skills/subagent-creator/SKILL.md) | SubAgent（エージェント定義）を作成するガイド。Skillが適切かSubAgentが適切かを判断し、適切な方を作成する | 「エージェントを作成して」「SubAgentを作って」 |
| [chart-generator-guide](plugins/consulting-toolkit/skills/chart-generator-guide/SKILL.md) | matplotlibによるデータチャート生成ガイド。ブランドパレット対応、PNG+SVG二重出力。棒・レーダー・積み上げ等7パターンのテンプレート付き | image-creatorサブエージェント経由 |
| [image-generator-guide](plugins/consulting-toolkit/skills/image-generator-guide/SKILL.md) | HTML+CSS／SVGによる構造化図解とGenerateImageの使い分けガイド。SVGではタイムライン・ロードマップ型の図解に対応。image-creatorサブエージェントから読み込まれる | image-creatorサブエージェント経由 |

---

## Agents

特定の役割に特化したサブエージェント。project-managerやワークフローの各ステップから自動的に呼び出される。

| エージェント | 説明 | 呼び出しタイミング |
|-------------|------|-------------------|
| [quality-reviewer](plugins/consulting-toolkit/agents/quality-reviewer.md) | 成果物の品質レビュー専門。指定された品質チェック項目＋デフォルト5軸評価（論理構造・具体性・読み手視点・整合性・網羅性）の2層で評価し、合格/条件付き合格/要修正を判定する | AIタスク完了後のレビューゲート（review_level=fullのみ） |
| [desk-researcher](plugins/consulting-toolkit/agents/desk-researcher.md) | デスクトップリサーチ実行専門。WebSearch/WebFetch/Browser Useで情報を収集し、調査レポートと仮説検証シートを出力する | Step 3（初期調査）、Step 10（詳細調査） |
| [image-creator](plugins/consulting-toolkit/agents/image-creator.md) | 画像・図解・データチャートの生成。HTML+CSSで構造化図解をPNG化、matplotlibでデータチャートを生成、またはGenerateImageでイメージ画像を生成する | 「画像にして」「図にして」「図解して」「グラフを作って」「データを可視化して」 |

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

3フェーズ・12ステップで構成される。技術動向調査、市場調査、インタビュー中心、デューデリジェンスに対応する。

```
Phase 0: 提案
┌────────────────────────────────────────────────────────────────┐
│  Step 1.  提案書作成 [AI]              → interview-research-proposal │
│  Step 2.  提案用スライド構成設計 [AI]   → slide-structure-designer    │
│  Step 3.  初期デスクトップ調査 [AI]     → desk-researcher             │
│  Step 4.  提案書更新 [AI]              → interview-research-proposal │
│  Step 5.  インタビューガイド作成 [AI]   → interview-guide-creator     │
│  Step 6.  報告書骨子案作成 [AI]         → report-outline-creator      │
└────────────────────────────────────────────────────────────────┘
                              ↓
Phase 1: 調査
┌────────────────────────────────────────────────────────────────┐
│  Step 7.  インタビュー対象者選定 [AI]   → interview-candidate-selector│
│  (インタビュー実施) [人間]                                           │
│  Step 8.  議事メモ作成 [AI]             → interview-minutes-creator   │
│  Step 9.  インタビューまとめ [AI]                                     │
│  Step 10. デスクリサーチ [AI]           → desk-researcher             │
└────────────────────────────────────────────────────────────────┘
                              ↓
Phase 2: 分析・とりまとめ
┌────────────────────────────────────────────────────────────────┐
│  Step 11. 最終報告書作成 [AI]           → integrated-analysis-creator  │
│  Step 12. 報告用スライド構成設計 [AI]   → slide-structure-designer    │
└────────────────────────────────────────────────────────────────┘
```

各AIステップ完了後、レビューゲートを経て次へ進む。ステップごとに `review_level` が設定されており、`full` は quality-reviewer SubAgent + ユーザー確認、`light` はユーザー確認のみで進む。

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
「提案書を作成して」         → interview-research-proposal が起動
「会議メモから議事録を作って」 → meeting-minutes-creator が起動
「インタビュー議事録を作成して」→ interview-minutes-creator が起動
「デスクリサーチを実行して」   → desk-research が起動
「スライドを作成して」         → pptx が起動
「この構造を図解して」         → image-creator が起動
```

---

## Agent Team による並列実行

Claude Code の Agent Team は、リードエージェントが複数のチームメイトを動的に生成し、独立したタスクを並列実行する機能。各チームメイトは独立したコンテキストで動作し、共有タスクリストとメッセージでリードと連携する。

通常のワークフローはステップを順に実行するが、複数の独立した成果物を同時に作れる場面では Agent Team で処理時間を短縮できる。

### いつ使うか

以下の条件をすべて満たす場面で有効に機能する。

- 同時並列で回せる独立タスクが3つ以上ある
- 各タスクが異なるファイルを出力する（競合しない）
- 1セッション内で完結できる規模
- 逐次実行と比べて時間短縮の実益がある

いずれかを満たさない場面では、project-manager + 個別スキルによる逐次ワークフローのほうがシンプルで品質管理しやすい。

### 逐次ワークフローとの使い分け

| 場面 | 推奨 | 理由 |
|------|------|------|
| 与件受領 → 提案一式 | Agent Team | 提案書と調査を並列で作成でき、成果物が独立している |
| 文字起こしが複数溜まった場合 | Agent Team | 複数議事録 + 調査を並列で処理する。ファイル数が多いほど効果が出る |
| 報告書ドラフト + レビュー | Agent Team | 多角レビューの並列実行 |
| クライアントフィードバック反映 | 逐次 | 単一ファイル修正。並列の必要がない |
| インタビュー1件の議事録 | 逐次 | 単一タスク。チーム生成がオーバーヘッドになる |
| 分析の方向性検討 | 逐次 | 人間との対話的探索が必要 |
| スライド作成 | 逐次 | pptx スキルで逐次処理 |

### 実行方法

Claude Code でプロジェクトフォルダを開き、自然言語で指示する。

```
「Agent Teamで提案を作成して」
「インタビュー結果をAgent Teamで並行処理して」
「報告書をAgent Teamで作成して」
```

AIが [agent-team-playbook](plugins/consulting-toolkit/skills/agent-team-playbook/SKILL.md) を参照し、適否を判断した上で要件書MDを生成する。ユーザーが確認後、Claude Code にその内容を渡して実行する。

> Agent Team は Claude Code 固有の機能であり、Cursor では利用できない。Cursor で逐次ワークフローを進める場合は project-manager スキルを自然言語で呼び出す。

---

## 成果物の格納先

| 成果物 | パス |
|--------|------|
| プロジェクトサマリ | `Output/プロジェクトサマリ.md` |
| 提案書 | `Output/提案書.md` |
| スライド構成（提案） | `Output/スライド構成_提案.md` |
| インタビューガイド | `Output/インタビューガイド.md` |
| インタビュー対象者 | `Output/インタビュー対象者.md` |
| 報告書骨子 | `Output/報告書骨子.md` |
| 議事録 | `Output/議事録/` |
| インタビューまとめ | `Output/インタビューまとめ.md` |
| 最終報告書 | `Output/最終報告書.md` |
| スライド構成（報告） | `Output/スライド構成.md` |
| 進捗状況 | `workflow.md` |

---

## 併用推奨: Anthropic 公式スキルプラグイン

本プラグインはコンサルティングワークフローに特化しているため、ドキュメント操作（PPTX・Excel・PDF・Word）やスキル作成といった汎用機能は [anthropics/skills](https://github.com/anthropics/skills) の公式プラグインとの併用を推奨します。

| プラグイン | 主なスキル | 用途 |
|-----------|-----------|------|
| `document-skills` | pptx, xlsx, pdf, docx, skill-creator 等 | ドキュメントの作成・編集・変換、スキルの新規作成・評価 |
| `example-skills` | algorithmic-art, frontend-design, brand-guidelines 等 | クリエイティブ・デザイン・開発系の参考実装 |

Claude Code で以下を実行するとインストールできます。

```
/plugin marketplace add anthropics/skills
/plugin install document-skills@anthropic-agent-skills
```

> 本プラグインに含まれる pptx スキルは Anthropic 公式版をベースにカスタマイズしたものですが、公式版と併用しても問題ありません。

---

## ファイル構成

| 種類 | パス |
|------|------|
| マーケットプレイスカタログ | `.claude-plugin/marketplace.json` |
| プラグインマニフェスト | `plugins/consulting-toolkit/.claude-plugin/plugin.json` |
| インストールスクリプト（Mac/Linux） | `install.sh` |
| インストールスクリプト（Windows） | `install.ps1` |
| Skills | `plugins/consulting-toolkit/skills/` |
| Commands | `plugins/consulting-toolkit/commands/` |
| Agents | `plugins/consulting-toolkit/agents/` |

---

## ディレクトリ構成

```
consulting-toolkit/
├── .claude-plugin/
│   └── marketplace.json              # マーケットプレイスカタログ
├── README.md
├── LICENSE.md
├── install.sh                        # Mac/Linux 用インストーラ
├── install.ps1                       # Windows 用インストーラ
└── plugins/
    └── consulting-toolkit/           # プラグイン本体
        ├── .claude-plugin/
        │   └── plugin.json           # プラグインマニフェスト
        ├── commands/
        │   └── pm.md
        ├── skills/
        │   ├── project-manager/
        │   ├── interview-research-proposal/
        │   ├── interview-guide-creator/
        │   ├── interview-candidate-selector/
        │   ├── interview-minutes-creator/
        │   ├── research-project-workflow/
        │   ├── agent-team-playbook/
        │   ├── desk-research/
        │   ├── docx-to-markdown-with-references/
        │   ├── integrated-analysis-creator/
        │   ├── image-generator-guide/
        │   ├── meeting-minutes-creator/
        │   ├── pptx/
        │   ├── report-outline-creator/
        │   ├── slide-structure-designer/
        │   └── subagent-creator/
        └── agents/
            ├── quality-reviewer.md
            ├── desk-researcher.md
            └── image-creator.md
```
