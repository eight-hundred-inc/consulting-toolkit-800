---
name: connect-slide-generator
description: slide-generator MCP サーバー（HTML デッキ → 編集可能 PPTX 変換）への接続をセットアップ・更新するスキル。Cognito の接続用トークンを払い出し、Claude Code への登録（claude mcp add）まで代行する。利用者がやるのはブラウザでのログインだけで、コマンド入力は不要。「slide-generator につないで」「pptx 変換の設定をして」「MCP を登録して」「デッキ変換が使えない」「接続が切れた」「トークンを更新して」「403 / 401 が返る」「/mcp に slide-generator が出ない」などのリクエスト時、および html-to-deck / deck スキルが MCP 未登録・認証切れで止まったときに使用する。接続済みかどうかの確認だけを頼まれた場合もこのスキルで扱う。
---

# slide-generator MCP への接続

**このスキルの目的は、非プログラマーの利用者が 1 つもコマンドを打たずに
`slide-generator` MCP へ接続できるようにすること。** 利用者にやってもらうのは
「開いたブラウザでログインする」だけで、トークンの払い出しから
`claude mcp add` までは Claude が代行する。

接続用トークンは **30 日で切れる**。切れると `html-to-deck` / `deck` が
401 / 403 で止まるので、その復旧もこのスキルで行う（手順は同じ）。

## 何をするスクリプトか

`scripts/issue_slide_generator_token.sh`（macOS / Linux）と
`scripts/issue_slide_generator_token.ps1`（Windows）は、同じ認可フロー
（認可コード + PKCE）の OS 別の実装。次を 1 回の実行で行う。

1. ローカルの折り返し受け（`http://localhost:8765/callback`）を立てる
2. Cognito の Hosted UI をブラウザで開く（**ここだけ利用者の操作**）
3. 戻ってきた認可コードをリフレッシュトークン（30 日）へ引き換える
4. `claude mcp remove` → `claude mcp add --scope user` で登録を置き換える

**トークンを Claude の文脈に取り込まないこと。** そのためにエージェント
モード（`SG_TOKEN_AGENT=1`）があり、このモードではトークンは標準出力へ
一切出ない。**このスキルの実行では必ずエージェントモードを使う**。会話ログは
ディスクに残るため、素の実行（トークンが画面に出る）を Claude から呼ぶと
秘密がログに焼き付く。

---

## 手順

### 1. いまの状態を見る

先に `~/.claude.json` の登録有無だけ確認する。トークンそのものは読まない
（`grep -c` で件数だけ見る。`grep` で行を出すとトークンが文脈に入る）。

```bash
grep -c '"slide-generator"' "$HOME/.claude.json" 2>/dev/null || echo 0
```

| 状態 | 判断 |
|------|------|
| 0 件 | 未登録。**2** へ進む |
| 1 件以上あり、利用者が「接続できているか確認したい」だけ | セッション内に `mcp__slide-generator__*` ツールが見えているかで判定して答える。見えていれば接続済み。見えていなければ「登録はあるが今のセッションに読み込まれていない」ので Claude Code の開き直しを案内する |
| 1 件以上あるのに 401 / 403 で失敗している | トークン切れ。**2** へ進む（古い登録は自動で置き換わる） |

### 2. 実行前の確認

- **ポート 8765 が空いているか**: `nc -z localhost 8765` が成功（＝使用中）なら、
  前回の待ち受けが残っている可能性がある。`lsof -ti :8765` で PID を調べ、
  利用者に断ってから止める。無断で kill しない
- **`claude` コマンドがあるか**: `command -v claude`。無くても実行はできる
  （後述の `MANUAL` 経路になる）

### 3. 利用者へ先に一声かける

実行するとブラウザが勝手に開くので、**開く前に**何が起きるか伝える。
ここを飛ばすと「知らないログイン画面が出た」で止まってしまう。

> これから接続用のログイン画面をブラウザで開きます。会社の Google アカウントで
> ログインしてください。終わったら自動で設定まで進みます（3〜5 分で切れるので、
> 開いたらそのまま進めてください）。

Bash の実行許可を求められる場合があることも添える。

### 4. スクリプトを実行する（バックグラウンド）

ログイン待ちで数分ブロックするため、**必ず `run_in_background: true`** で
起動する。前景で走らせるとタイムアウトで切られる。

スクリプトの場所は `${CLAUDE_PLUGIN_ROOT}/skills/connect-slide-generator/scripts/`。
`${CLAUDE_PLUGIN_ROOT}` が解決できないときは
`find "$HOME/.claude/plugins" -path '*connect-slide-generator/scripts/*' 2>/dev/null | head -2`
で絶対パスを得る。

**macOS / Linux**:

```bash
SG_TOKEN_AGENT=1 bash "${CLAUDE_PLUGIN_ROOT}/skills/connect-slide-generator/scripts/issue_slide_generator_token.sh"
```

**Windows**（Claude Code の Bash は Git Bash。PowerShell を呼び出す）:

```bash
SG_TOKEN_AGENT=1 powershell.exe -ExecutionPolicy Bypass -File "$(cygpath -w "${CLAUDE_PLUGIN_ROOT}/skills/connect-slide-generator/scripts/issue_slide_generator_token.ps1")"
```

`cygpath` が無ければ `/c/Users/...` を `C:\Users\...` へ手で置き換える。

> **サンドボックスで弾かれたら**: `Operation not permitted` や
> ブラウザが開かない・ポートを掴めない類のエラーで即座に終わったときは、
> 同じコマンドを `dangerouslyDisableSandbox: true` で 1 度だけやり直す
> （ローカルの待ち受けとブラウザ起動が要るため）。利用者には
> 「ブラウザを開くために許可が要ります」と伝える。

### 5. 完了を待つ

バックグラウンドの出力ファイルを読み、`SGTOKEN: DONE` が出るまで待つ。
**30〜60 秒おきに 1 回**見る。それより短い間隔で叩かない。

待っている間、利用者へ「ブラウザでログインが終わるのを待っています」と
一言伝えておく。無言で数分空けない。

### 6. 結果を伝える

最後の `SGTOKEN:` マーカーで分岐する（次節の表）。

成功時（`REGISTERED`）に必ず伝えること:

> 接続設定が終わりました。**いま開いている Claude Code には反映されないので、
> 一度終了してから開き直してください。** 開き直したあとに「pptx にして」と
> 頼めば変換できます。設定は 30 日で切れるので、また使えなくなったら
> 同じように「slide-generator につないで」と言ってください。

**登録直後に `mcp__slide-generator__*` を呼ばないこと。** 現セッションには
読み込まれていないため必ず失敗する。`html-to-deck` の続きがある場合も、
開き直しを案内していったん止める。

---

## スクリプトの出力マーカー

エージェントモードでは次の 1 行マーカーだけが出る（トークンは出ない）。

| マーカー | 意味 | Claude の対応 |
|----------|------|---------------|
| `SGTOKEN: AUTH_URL <url>` | 認可 URL（秘密ではない） | ブラウザが自動で開かなかったと利用者が言ったら、この URL を渡す |
| `SGTOKEN: WAITING_LOGIN <秒>` | 折り返し待ちに入った。この秒数で打ち切る | 待つ。利用者へ進行中と伝える |
| `SGTOKEN: CODE_RECEIVED` | ログイン成功、トークン引き換えへ | そのまま待つ（数秒） |
| `SGTOKEN: REGISTERED` | 登録完了 | 成功として伝え、Claude Code の開き直しを案内する |
| `SGTOKEN: MANUAL <パス>` | トークンは取れたが `claude` コマンドで登録できなかった | 下の「MANUAL のとき」へ |
| `SGTOKEN: ERROR PORT_BUSY` | ポート 8765 が使用中 | 手順 2 のポート確認へ戻る |
| `SGTOKEN: ERROR TIMEOUT` | 時間内にログインが終わらなかった | 利用者に確認したうえで、もう一度手順 4 から |
| `SGTOKEN: ERROR AUTH_FAILED <理由>` | ログイン自体が失敗（権限が無い等） | 理由をそのまま伝える。アカウントの権限問題は Claude 側では直せない |
| `SGTOKEN: ERROR NO_CODE` | 認可コードを受け取れなかった | もう一度手順 4 から |
| `SGTOKEN: ERROR TOKEN_EXCHANGE_FAILED` | トークン引き換えに失敗 | 時間をおいて再実行。続くようなら管理者へ |
| `SGTOKEN: ERROR UNEXPECTED` | 想定外の中断 | 直前の行をそのまま伝え、もう一度手順 4 から |
| `SGTOKEN: DONE` | 終了（成否によらず必ず最後に出る） | ポーリングを止める |

**`REGISTERED` も `MANUAL` も無いまま `DONE` が出たら失敗**。成功と読み違えて
`html-to-deck` へ進まない。stderr の行を読んで原因を伝える。

### MANUAL のとき

`MANUAL` で示されるパスは「実行するだけで登録が終わるスクリプト」で、
中にトークンが入っている（0600 / 本人のみ読める）。**中身を読まないこと。**
読むとトークンが会話ログへ入る。

1. まず Claude が実行してみる（`claude` が Bash の PATH には居ることがある）

   - macOS / Linux: `bash "<パス>"`
   - Windows: `powershell.exe -ExecutionPolicy Bypass -File "<パス>"`

   成功すると「登録が完了しました。」と出て、スクリプトは自分を消す

2. それでも失敗するなら、利用者にその 1 行だけ実行してもらう。
   **この行に秘密は含まれない**ので、そのまま提示してよい

## 別環境へ向けるとき

接続先は development 環境が既定値として埋め込んである。別環境なら
`COGNITO_DOMAIN` / `COGNITO_CLIENT_ID` / `MCP_ENDPOINT` を環境変数で渡す
（`SG_TOKEN_AGENT=1` と並べて指定する）。

## 関連

- 接続後に使うスキル: `html-to-deck`（HTML デッキ → PPTX）、`deck`（構成 MD → HTML → PPTX）
- 手で動かす場合や仕組みの詳細: README の「slide-generator（見本 HTML → PPTX）」節
- 認可フローの正本: slide_generator リポジトリの `app/core/scripts/issue_mcp_token.py`
  （`.sh` / `.ps1` / `.py` は揃えて直すこと）
