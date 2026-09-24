# slide-generator MCP サーバーへ接続するためのトークンを払い出し、
# Claude Code への登録（claude mcp add）まで一括で行う（Windows 用）。
#
# Cognito の Hosted UI（Google Workspace の SAML）でログインし、得られた
# リフレッシュトークンで slide-generator を登録する（既存の同名登録は
# 置き換える）。claude コマンドが見つからないときは、そのまま貼れる
# `claude mcp add` の1行を表示する。
#
#     powershell -ExecutionPolicy Bypass -File scripts\issue_slide_generator_token.ps1
#
# Windows 10/11 標準の PowerShell 5.1 だけで動く（追加インストール不要）。
# 証明書は Windows の証明書ストアを参照するため、社内プロキシ（Zscaler 等）の
# 環境でも追加設定は要らない。接続先（development 環境）は既定値として
# 内蔵しているため通常は引数不要。別環境へ向けるときは環境変数
# COGNITO_DOMAIN / COGNITO_CLIENT_ID / MCP_ENDPOINT で上書きする。
#
# macOS の利用者は scripts/issue_slide_generator_token.sh を使うこと。
# slide_generator リポジトリの app/core/scripts/issue_mcp_token.py と同じ
# 認可フロー（認可コード + PKCE）の移植。認可フローを変えるときは
# .sh / .ps1 / 元の .py を揃えて直すこと。
#
# なぜ IDトークンではなくリフレッシュトークンなのか:
# Claude Code の MCP 設定には固定のヘッダしか書けない。IDトークンは有効期限が
# 1時間のため毎時貼り直しになる。リフレッシュトークン（30日）を持たせ、
# API Gateway の Authorizer 側で IDトークンへ引き換えて検証する。
#
# このトークンはパスワードと同じ。貼り付け先（~/.claude.json）以外へ
# 残さないこと。30日で切れるので、401/403 が返るようになったら再実行する。

$ErrorActionPreference = 'Stop'

# PowerShell 5.1 の既定では古い TLS を使おうとして接続に失敗することがある
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# development 環境の接続先。terraform output（cognito_hosted_ui_url /
# cognito_client_id / mcp_endpoint）の値と対応する
$Domain = 'slide-generator-development.auth.ap-northeast-1.amazoncognito.com'
if ($env:COGNITO_DOMAIN) { $Domain = $env:COGNITO_DOMAIN }
$ClientId = '6hbcjo51g7a66mt9dbun938kin'
if ($env:COGNITO_CLIENT_ID) { $ClientId = $env:COGNITO_CLIENT_ID }
$Endpoint = 'https://yhzeymkas8.execute-api.ap-northeast-1.amazonaws.com/mcp'
if ($env:MCP_ENDPOINT) { $Endpoint = $env:MCP_ENDPOINT }

# Cognito のアプリクライアントへ登録してある折り返し先と揃える
$CallbackPort = 8765
$RedirectUriEncoded = 'http%3A%2F%2Flocalhost%3A8765%2Fcallback'

# https:// 付きの URL をそのまま貼れるようにする（スキームとパスを外す）
$Domain = ($Domain -replace '^[a-z]+://', '').Split('/')[0]

# ── PKCE の検証子とチャレンジを作る ──
function ConvertTo-Base64Url {
    param([byte[]]$Bytes)
    return [Convert]::ToBase64String($Bytes).TrimEnd('=').Replace('+', '-').Replace('/', '_')
}

$randomBytes = New-Object byte[] 64
$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
$rng.GetBytes($randomBytes)
$verifier = ConvertTo-Base64Url -Bytes $randomBytes
$sha256 = [System.Security.Cryptography.SHA256]::Create()
$challenge = ConvertTo-Base64Url -Bytes $sha256.ComputeHash([Text.Encoding]::ASCII.GetBytes($verifier))

$authUrl = "https://$Domain/oauth2/authorize?response_type=code&client_id=$ClientId" +
    "&redirect_uri=$RedirectUriEncoded&scope=openid+email+profile" +
    "&code_challenge_method=S256&code_challenge=$challenge"

# ── 折り返し（認可コード）を localhost で受ける準備 ──
# localhost 宛の HttpListener は管理者権限が要らない
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$CallbackPort/")
try {
    $listener.Start()
} catch {
    Write-Host "エラー: ポート $CallbackPort を使えません。他のプロセスが使用中なら止めてから再実行してください。"
    Write-Host $_.Exception.Message
    exit 1
}

Write-Host 'ブラウザでログインしてください。開かない場合は次のURLを開いてください。'
Write-Host "  $authUrl"
Write-Host ''
Write-Host '（ログインが終わるまでこのまま待ちます。やめるときはこのウィンドウを閉じてください）'

Start-Process $authUrl | Out-Null

# ブラウザでの完了表示
$completedPage = '<!doctype html><meta charset="utf-8"><title>接続用トークンの払い出し</title><p>受け取りました。ターミナルへ戻ってください。</p>'
$completedBytes = [Text.Encoding]::UTF8.GetBytes($completedPage)

$code = ''
$authError = ''
try {
    # favicon 等の関係ないリクエストは 404 で受け流し、/callback が来るまで待つ
    while (-not $code -and -not $authError) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        if ($request.Url.AbsolutePath -ne '/callback') {
            $response.StatusCode = 404
            $response.Close()
            continue
        }

        $query = $request.QueryString
        $code = $query['code']
        $authError = $query['error_description']
        if (-not $authError) { $authError = $query['error'] }

        $response.ContentType = 'text/html; charset=utf-8'
        $response.ContentLength64 = $completedBytes.Length
        $response.OutputStream.Write($completedBytes, 0, $completedBytes.Length)
        $response.Close()
    }
} finally {
    $listener.Stop()
    $listener.Close()
}

if ($authError) {
    Write-Host "エラー: ログインに失敗しました: $authError"
    exit 1
}
if (-not $code) {
    Write-Host 'エラー: 認可コードを受け取れませんでした。もう一度実行してください。'
    exit 1
}

# ── 認可コードをトークンへ引き換える ──
$tokenBody = "grant_type=authorization_code&client_id=$ClientId&code=$code" +
    "&redirect_uri=$RedirectUriEncoded&code_verifier=$verifier"
try {
    $tokenResponse = Invoke-RestMethod -Method Post -Uri "https://$Domain/oauth2/token" `
        -ContentType 'application/x-www-form-urlencoded' -Body $tokenBody
} catch {
    Write-Host 'エラー: トークンの取得に失敗しました。'
    $original = $_
    # PowerShell 5.1 では応答本文を読めるので読む（7 では型が違うため素通し）
    try {
        $reader = New-Object System.IO.StreamReader($original.Exception.Response.GetResponseStream())
        Write-Host $reader.ReadToEnd()
    } catch {
        Write-Host $original.Exception.Message
    }
    exit 1
}

$refreshToken = $tokenResponse.refresh_token
if (-not $refreshToken) {
    Write-Host 'エラー: リフレッシュトークンが返りませんでした。'
    exit 1
}

# ── Claude Code へ登録する ──
# ここからは claude コマンド（外部プログラム）の実行が主になるため、
# stderr への出力を例外へ変換させない
$ErrorActionPreference = 'Continue'

$manualLine = "claude mcp add --scope user --transport http slide-generator $Endpoint --header ""Authorization: Bearer $refreshToken"""

$claudeCommand = Get-Command claude -ErrorAction SilentlyContinue
if (-not $claudeCommand) {
    Write-Host ''
    Write-Host 'claude コマンドが見つかりませんでした。次の1行を実行すると登録できます'
    Write-Host '（トークンはパスワードと同じ扱いで）。'
    Write-Host ''
    Write-Host $manualLine
    exit 0
}

Write-Host ''
Write-Host 'Claude Code へ登録します（既存の slide-generator の登録は置き換えます）。'
cmd /c 'claude mcp remove --scope user slide-generator >nul 2>&1'
claude mcp add --scope user --transport http slide-generator $Endpoint --header "Authorization: Bearer $refreshToken"
if ($LASTEXITCODE -eq 0) {
    Write-Host ''
    Write-Host '登録が完了しました。新しく開いた Claude Code から使えます'
    Write-Host '（開きっぱなしの Claude Code には、開き直すと反映されます）。'
    Write-Host '確認するには: claude mcp list （slide-generator が Connected ならOK）'
} else {
    Write-Host ''
    Write-Host 'エラー: 登録に失敗しました。次の1行を手動で実行してください。'
    Write-Host ''
    Write-Host $manualLine
    exit 1
}
