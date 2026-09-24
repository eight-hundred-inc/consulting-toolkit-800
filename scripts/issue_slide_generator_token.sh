#!/bin/bash
# slide-generator MCP サーバーへ接続するためのトークンを払い出し、
# Claude Code への登録（claude mcp add）まで一括で行う。
#
# Cognito の Hosted UI（Google Workspace の SAML）でログインし、得られた
# リフレッシュトークンで slide-generator を登録する（既存の同名登録は
# 置き換える）。claude コマンドが見つからないときは、そのまま貼れる
# `claude mcp add` の1行を表示する。
#
#     bash scripts/issue_slide_generator_token.sh
#
# macOS 標準のコマンド（openssl / curl / nc / open）だけで動く。
# Python も追加インストールも不要。接続先（development 環境）は既定値として
# 内蔵しているため通常は引数不要。別環境へ向けるときは環境変数
# COGNITO_DOMAIN / COGNITO_CLIENT_ID / MCP_ENDPOINT で上書きする。
#
# Windows の利用者は scripts/issue_slide_generator_token.ps1 を使うこと。
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

set -eu

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

# 折り返しを受けるポートが空いているか先に見る
if nc -z localhost "$CALLBACK_PORT" 2>/dev/null; then
  echo "エラー: ポート ${CALLBACK_PORT} が使用中です。他のプロセスを止めてから再実行してください。" >&2
  exit 1
fi

# ── PKCE の検証子とチャレンジを作る ──
# base64url（+/ を -_ に、パディング無し）。BSD/GNU の base64 の改行差は tr で吸収
VERIFIER=$(openssl rand 64 | base64 | tr '+/' '-_' | tr -d '=\n')
CHALLENGE=$(printf '%s' "$VERIFIER" | openssl dgst -sha256 -binary | base64 | tr '+/' '-_' | tr -d '=\n')

AUTH_URL="https://${DOMAIN}/oauth2/authorize?response_type=code&client_id=${CLIENT_ID}&redirect_uri=${REDIRECT_URI_ENCODED}&scope=openid+email+profile&code_challenge_method=S256&code_challenge=${CHALLENGE}"

# ── ブラウザで完了したときに表示するページと、その HTTP 応答を用意する ──
REQUEST_FILE=$(mktemp)
RESPONSE_FILE=$(mktemp)
trap 'rm -f "$REQUEST_FILE" "$RESPONSE_FILE"' EXIT

BODY='<!doctype html><meta charset="utf-8"><title>接続用トークンの払い出し</title><p>受け取りました。ターミナルへ戻ってください。</p>'
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

echo "ブラウザでログインしてください。開かない場合は次のURLを開いてください。"
echo "  $AUTH_URL"
echo
echo "（ログインが終わるまでこのまま待ちます。やめるときは Ctrl+C）"

if command -v open >/dev/null 2>&1; then
  open "$AUTH_URL" || true
elif command -v xdg-open >/dev/null 2>&1; then
  xdg-open "$AUTH_URL" || true
fi

# ── 折り返し（認可コード）を localhost で受ける ──
# ブラウザは中身の無い接続を先読みで張ることがあるため、認可コードか
# エラーを含むリクエストが来るまで待ち受けをやり直す
CODE=""
AUTH_ERROR=""
ATTEMPT=0
while [ -z "$CODE" ] && [ -z "$AUTH_ERROR" ]; do
  ATTEMPT=$((ATTEMPT + 1))
  if [ "$ATTEMPT" -gt 20 ]; then
    echo "エラー: 認可コードを受け取れませんでした。もう一度実行してください。" >&2
    exit 1
  fi
  nc -l "$CALLBACK_PORT" < "$RESPONSE_FILE" > "$REQUEST_FILE" || true
  REQUEST_LINE=$(head -1 "$REQUEST_FILE" | tr -d '\r')
  CODE=$(printf '%s' "$REQUEST_LINE" | sed -n 's/.*[?&]code=\([^& ]*\).*/\1/p')
  AUTH_ERROR=$(printf '%s' "$REQUEST_LINE" | sed -n 's/.*[?&]error_description=\([^& ]*\).*/\1/p')
  if [ -z "$AUTH_ERROR" ]; then
    AUTH_ERROR=$(printf '%s' "$REQUEST_LINE" | sed -n 's/.*[?&]error=\([^& ]*\).*/\1/p')
  fi
done

if [ -n "$AUTH_ERROR" ]; then
  echo "エラー: ログインに失敗しました: ${AUTH_ERROR}" >&2
  exit 1
fi

# ── 認可コードをトークンへ引き換える ──
TOKEN_RESPONSE=$(curl -sS -X POST "https://${DOMAIN}/oauth2/token" \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data "grant_type=authorization_code&client_id=${CLIENT_ID}&code=${CODE}&redirect_uri=${REDIRECT_URI_ENCODED}&code_verifier=${VERIFIER}")

REFRESH_TOKEN=$(printf '%s' "$TOKEN_RESPONSE" | sed -n 's/.*"refresh_token" *: *"\([^"]*\)".*/\1/p')

if [ -z "$REFRESH_TOKEN" ]; then
  echo "エラー: リフレッシュトークンが返りませんでした。応答: ${TOKEN_RESPONSE}" >&2
  exit 1
fi

# ── Claude Code へ登録する ──
print_manual_line() {
  echo
  echo "claude mcp add --scope user --transport http slide-generator \\"
  echo "  ${ENDPOINT} \\"
  echo "  --header \"Authorization: Bearer ${REFRESH_TOKEN}\""
}

if ! command -v claude >/dev/null 2>&1; then
  echo
  echo "claude コマンドが見つかりませんでした。次の1行を実行すると登録できます"
  echo "（トークンはパスワードと同じ扱いで）。"
  print_manual_line
  exit 0
fi

echo
echo "Claude Code へ登録します（既存の slide-generator の登録は置き換えます）。"
claude mcp remove --scope user slide-generator >/dev/null 2>&1 || true
if claude mcp add --scope user --transport http slide-generator "${ENDPOINT}" \
    --header "Authorization: Bearer ${REFRESH_TOKEN}"; then
  echo
  echo "登録が完了しました。新しく開いた Claude Code から使えます"
  echo "（開きっぱなしの Claude Code には、開き直すと反映されます）。"
  echo "確認するには: claude mcp list （slide-generator が ✔ Connected ならOK）"
else
  echo
  echo "エラー: 登録に失敗しました。次の1行を手動で実行してください。" >&2
  print_manual_line
  exit 1
fi
