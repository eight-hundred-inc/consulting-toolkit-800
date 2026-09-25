#!/bin/bash
# slide-generator MCP サーバーへ接続するためのトークンを払い出し、
# Claude Code への登録（claude mcp add）まで一括で行う。
#
# Cognito の Hosted UI（Google Workspace の SAML）でログインし、得られた
# リフレッシュトークンで slide-generator を登録する（既存の同名登録は
# 置き換える）。claude コマンドが見つからないときは、そのまま実行できる
# 登録用スクリプトを書き出す。
#
# 通常の利用者は Claude Code に「slide-generator につないで」と頼めばよい
# （connect-slide-generator スキルが本スクリプトを代わりに実行する）。
# 手で動かすときは:
#
#     bash scripts/issue_slide_generator_token.sh
#
# macOS 標準のコマンド（openssl / curl / nc / open）だけで動く。
# Python も追加インストールも不要。接続先（development 環境）は既定値として
# 内蔵しているため通常は引数不要。別環境へ向けるときは環境変数
# COGNITO_DOMAIN / COGNITO_CLIENT_ID / MCP_ENDPOINT で上書きする。
#
# Windows の利用者は issue_slide_generator_token.ps1 を使うこと。
# slide_generator リポジトリの app/core/scripts/issue_mcp_token.py と同じ
# 認可フロー（認可コード + PKCE）の移植。利用者に配るのはこのリポジトリ
# だけのため、セットアップがここで完結するように置いてある。
# 認可フローを変えるときは .sh / .ps1 / 元の .py を揃えて直すこと。
#
# なぜ IDトークンではなくリフレッシュトークンなのか:
# Claude Code の MCP 設定には固定のヘッダしか書けない。IDトークンは有効期限が
# 1時間のため毎時貼り直しになる。リフレッシュトークン（30日）を持たせ、
# API Gateway の Authorizer 側で IDトークンへ引き換えて検証する。
#
# このトークンはパスワードと同じ。貼り付け先（~/.claude.json）以外へ
# 残さないこと。30日で切れるので、401/403 が返るようになったら再実行する。
#
# ── エージェントモード（--agent / SG_TOKEN_AGENT=1）──
# Claude Code から実行されることを想定したモード。人間向けの文章の代わりに
# `SGTOKEN: <状態>` の1行マーカーを出し、**リフレッシュトークンを標準出力へ
# 一切出さない**（Claude の文脈＝保存される会話ログに秘密が残らないようにする）。
# 折り返し待ちは SG_TOKEN_WAIT_SECONDS 秒（既定 300）で打ち切る。放置された
# 待ち受けがポート 8765 を掴んだままにならないようにするため。
# マーカーの意味は SKILL.md の「スクリプトの出力マーカー」を参照。

set -eu

AGENT_MODE=0
if [ "${SG_TOKEN_AGENT:-0}" = "1" ]; then AGENT_MODE=1; fi
for arg in "$@"; do
  case "$arg" in
    --agent) AGENT_MODE=1 ;;
  esac
done

WAIT_SECONDS="${SG_TOKEN_WAIT_SECONDS:-300}"

# エージェントモードのときだけ機械可読マーカーを出す
emit() {
  if [ "$AGENT_MODE" = "1" ]; then
    echo "SGTOKEN: $*"
  fi
}

# 人間向けの説明。エージェントモードでは Claude が言い換えて伝えるので出さない
say() {
  if [ "$AGENT_MODE" != "1" ]; then
    echo "$@"
  fi
}

# development 環境の接続先。terraform output（cognito_hosted_ui_url /
# cognito_client_id / mcp_endpoint）の値と対応する
DOMAIN="${COGNITO_DOMAIN:-slide-generator-development.auth.ap-northeast-1.amazoncognito.com}"
CLIENT_ID="${COGNITO_CLIENT_ID:-6hbcjo51g7a66mt9dbun938kin}"
ENDPOINT="${MCP_ENDPOINT:-https://yhzeymkas8.execute-api.ap-northeast-1.amazonaws.com/mcp}"

# Cognito のアプリクライアントへ登録してある折り返し先と揃える
CALLBACK_PORT=8765
REDIRECT_URI_ENCODED="http%3A%2F%2Flocalhost%3A${CALLBACK_PORT}%2Fcallback"

# https:// 付きの URL をそのまま貼れるようにする（スキームとパスを外す）
DOMAIN="${DOMAIN#*//}"
DOMAIN="${DOMAIN%%/*}"

# 異常終了でも必ず DONE を出す。Claude 側はこの行をポーリングの打ち切り条件に使う
WATCH_PID=""
cleanup() {
  [ -n "$WATCH_PID" ] && kill "$WATCH_PID" 2>/dev/null || true
  rm -f "${REQUEST_FILE:-}" "${RESPONSE_FILE:-}" 2>/dev/null || true
  emit "DONE"
}
trap cleanup EXIT

fail() {
  # $1 = 機械可読の理由、$2 = 人間向けの説明
  emit "ERROR $1"
  say "エラー: $2" >&2
  if [ "$AGENT_MODE" = "1" ]; then echo "$2" >&2; fi
  exit 1
}

# 折り返しを受けるポートが空いているか先に見る
if nc -z localhost "$CALLBACK_PORT" 2>/dev/null; then
  fail "PORT_BUSY" "ポート ${CALLBACK_PORT} が使用中です。他のプロセスを止めてから再実行してください。"
fi

# ── PKCE の検証子とチャレンジを作る ──
# base64url（+/ を -_ に、パディング無し）。BSD/GNU の base64 の改行差は tr で吸収
VERIFIER=$(openssl rand 64 | base64 | tr '+/' '-_' | tr -d '=\n')
CHALLENGE=$(printf '%s' "$VERIFIER" | openssl dgst -sha256 -binary | base64 | tr '+/' '-_' | tr -d '=\n')

AUTH_URL="https://${DOMAIN}/oauth2/authorize?response_type=code&client_id=${CLIENT_ID}&redirect_uri=${REDIRECT_URI_ENCODED}&scope=openid+email+profile&code_challenge_method=S256&code_challenge=${CHALLENGE}"

# ── ブラウザで完了したときに表示するページと、その HTTP 応答を用意する ──
REQUEST_FILE=$(mktemp)
RESPONSE_FILE=$(mktemp)

BODY='<!doctype html><meta charset="utf-8"><title>接続用トークンの払い出し</title><p>受け取りました。Claude Code へ戻ってください。</p>'
BODY_LENGTH=$(printf '%s' "$BODY" | wc -c | tr -d ' ')
# Content-Length を付けるとブラウザが本文の終わりを判断して接続を閉じ、
# それを合図に nc が終了する（付けないと両者が互いの切断を待って固まる）
{
  printf 'HTTP/1.1 200 OK\r\n'
  printf 'Content-Type: text/html; charset=utf-8\r\n'
  printf 'Content-Length: %s\r\n' "$BODY_LENGTH"
  printf 'Connection: close\r\n\r\n'
  printf '%s' "$BODY"
} > "$RESPONSE_FILE"

say "ブラウザでログインしてください。開かない場合は次のURLを開いてください。"
say "  $AUTH_URL"
say ""
say "（ログインが終わるまで最大 ${WAIT_SECONDS} 秒待ちます。やめるときは Ctrl+C）"

# 認可 URL 自体は秘密ではない（含まれるのは PKCE のチャレンジのみ）。
# ブラウザが自動で開かなかったときに Claude が案内できるよう先に出しておく
emit "AUTH_URL ${AUTH_URL}"

if command -v open >/dev/null 2>&1; then
  open "$AUTH_URL" || true
elif command -v xdg-open >/dev/null 2>&1; then
  xdg-open "$AUTH_URL" || true
fi

emit "WAITING_LOGIN ${WAIT_SECONDS}"

# ── 折り返し（認可コード）を localhost で受ける ──
# ブラウザは中身の無い接続を先読みで張ることがあるため、認可コードか
# エラーを含むリクエストが来るまで待ち受けをやり直す。
# 待ち受けは締め切りで打ち切る。放置された nc がポートを掴み続けると、
# 次回の実行が PORT_BUSY で始まらなくなるため
DEADLINE=$(( $(date +%s) + WAIT_SECONDS ))
CODE=""
AUTH_ERROR=""
ATTEMPT=0
while [ -z "$CODE" ] && [ -z "$AUTH_ERROR" ]; do
  ATTEMPT=$((ATTEMPT + 1))
  if [ "$ATTEMPT" -gt 20 ]; then
    fail "NO_CODE" "認可コードを受け取れませんでした。もう一度実行してください。"
  fi
  REMAIN=$(( DEADLINE - $(date +%s) ))
  if [ "$REMAIN" -le 0 ]; then
    fail "TIMEOUT" "ログインが ${WAIT_SECONDS} 秒以内に終わりませんでした。もう一度実行してください。"
  fi

  nc -l "$CALLBACK_PORT" < "$RESPONSE_FILE" > "$REQUEST_FILE" 2>/dev/null &
  NC_PID=$!
  # 締め切りが来たら待ち受けを畳む見張り役
  ( sleep "$REMAIN"; kill "$NC_PID" 2>/dev/null || true ) >/dev/null 2>&1 &
  WATCH_PID=$!
  wait "$NC_PID" 2>/dev/null || true
  kill "$WATCH_PID" 2>/dev/null || true
  wait "$WATCH_PID" 2>/dev/null || true
  WATCH_PID=""

  REQUEST_LINE=$(head -1 "$REQUEST_FILE" | tr -d '\r')
  CODE=$(printf '%s' "$REQUEST_LINE" | sed -n 's/.*[?&]code=\([^& ]*\).*/\1/p')
  AUTH_ERROR=$(printf '%s' "$REQUEST_LINE" | sed -n 's/.*[?&]error_description=\([^& ]*\).*/\1/p')
  if [ -z "$AUTH_ERROR" ]; then
    AUTH_ERROR=$(printf '%s' "$REQUEST_LINE" | sed -n 's/.*[?&]error=\([^& ]*\).*/\1/p')
  fi
done

if [ -n "$AUTH_ERROR" ]; then
  fail "AUTH_FAILED ${AUTH_ERROR}" "ログインに失敗しました: ${AUTH_ERROR}"
fi

emit "CODE_RECEIVED"

# ── 認可コードをトークンへ引き換える ──
TOKEN_RESPONSE=$(curl -sS -X POST "https://${DOMAIN}/oauth2/token" \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data "grant_type=authorization_code&client_id=${CLIENT_ID}&code=${CODE}&redirect_uri=${REDIRECT_URI_ENCODED}&code_verifier=${VERIFIER}")

REFRESH_TOKEN=$(printf '%s' "$TOKEN_RESPONSE" | sed -n 's/.*"refresh_token" *: *"\([^"]*\)".*/\1/p')

if [ -z "$REFRESH_TOKEN" ]; then
  # エージェントモードでは応答本文を出さない（誤って別のトークンが載る可能性があるため）
  emit "ERROR TOKEN_EXCHANGE_FAILED"
  say "エラー: リフレッシュトークンが返りませんでした。応答: ${TOKEN_RESPONSE}" >&2
  if [ "$AGENT_MODE" = "1" ]; then
    echo "リフレッシュトークンが返りませんでした。時間をおいて再実行してください。" >&2
  fi
  exit 1
fi

# ── Claude Code へ登録する ──
# claude コマンドが見つからないときの逃げ道。トークンを画面へ出さずに済むよう、
# 「実行するだけで登録が終わるスクリプト」を 0600 で書き出す。
# 利用者（や Claude）が打つのは `bash <パス>` の1行だけで、秘密を含まない
write_manual_script() {
  MANUAL_DIR="${TMPDIR:-/tmp}/slide-generator-setup"
  mkdir -p "$MANUAL_DIR"
  chmod 700 "$MANUAL_DIR" 2>/dev/null || true
  MANUAL_SCRIPT="${MANUAL_DIR}/register_slide_generator.sh"
  umask 077
  cat > "$MANUAL_SCRIPT" <<MANUAL_EOF
#!/bin/bash
# slide-generator を Claude Code へ登録する。実行すると自分を消す。
# このファイルには接続用トークン（パスワード相当）が入っている。他人へ渡さないこと。
set -eu
claude mcp remove --scope user slide-generator >/dev/null 2>&1 || true
claude mcp add --scope user --transport http slide-generator \\
  "${ENDPOINT}" \\
  --header "Authorization: Bearer ${REFRESH_TOKEN}"
echo "登録が完了しました。"
rm -f -- "\$0"
MANUAL_EOF
  chmod 600 "$MANUAL_SCRIPT"
}

if ! command -v claude >/dev/null 2>&1; then
  write_manual_script
  emit "MANUAL ${MANUAL_SCRIPT}"
  say ""
  say "claude コマンドが見つかりませんでした。次の1行を実行すると登録できます。"
  say ""
  say "  bash ${MANUAL_SCRIPT}"
  exit 0
fi

say ""
say "Claude Code へ登録します（既存の slide-generator の登録は置き換えます）。"
claude mcp remove --scope user slide-generator >/dev/null 2>&1 || true
if claude mcp add --scope user --transport http slide-generator "${ENDPOINT}" \
    --header "Authorization: Bearer ${REFRESH_TOKEN}" >/dev/null 2>&1; then
  emit "REGISTERED"
  say ""
  say "登録が完了しました。新しく開いた Claude Code から使えます"
  say "（開きっぱなしの Claude Code には、開き直すと反映されます）。"
  say "確認するには: claude mcp list （slide-generator が ✔ Connected ならOK）"
else
  write_manual_script
  emit "MANUAL ${MANUAL_SCRIPT}"
  say ""
  say "登録に失敗しました。次の1行を実行してください。" >&2
  say ""
  say "  bash ${MANUAL_SCRIPT}" >&2
  exit 0
fi
