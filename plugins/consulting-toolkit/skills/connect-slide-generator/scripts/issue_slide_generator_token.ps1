# slide-generator MCP サーバーへ接続するためのトークンを払い出し、
# Claude Code への登録（claude mcp add）まで一括で行う（Windows 用）。
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
#     powershell -ExecutionPolicy Bypass -File issue_slide_generator_token.ps1
#
# Windows 10/11 標準の PowerShell 5.1 だけで動く（追加インストール不要）。
# 証明書は Windows の証明書ストアを参照するため、社内プロキシ（Zscaler 等）の
# 環境でも追加設定は要らない。接続先（development 環境）は既定値として
# 内蔵しているため通常は引数不要。別環境へ向けるときは環境変数
# COGNITO_DOMAIN / COGNITO_CLIENT_ID / MCP_ENDPOINT で上書きする。
#
# macOS の利用者は issue_slide_generator_token.sh を使うこと。
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
#
# ── エージェントモード（-Agent / SG_TOKEN_AGENT=1）──
# Claude Code から実行されることを想定したモード。人間向けの文章の代わりに
# `SGTOKEN: <状態>` の1行マーカーを出し、**リフレッシュトークンを標準出力へ
# 一切出さない**（Claude の文脈＝保存される会話ログに秘密が残らないようにする）。
# 折り返し待ちは SG_TOKEN_WAIT_SECONDS 秒（既定 300）で打ち切る。放置された
# 待ち受けがポート 8765 を掴んだままにならないようにするため。
# マーカーの意味は SKILL.md の「スクリプトの出力マーカー」を参照。

param(
    [switch]$Agent
)

$ErrorActionPreference = 'Stop'

# PowerShell 5.1 の既定では古い TLS を使おうとして接続に失敗することがある
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$agentMode = $Agent.IsPresent -or ($env:SG_TOKEN_AGENT -eq '1')
$waitSeconds = 300
if ($env:SG_TOKEN_WAIT_SECONDS) { $waitSeconds = [int]$env:SG_TOKEN_WAIT_SECONDS }

# エージェントモードのときだけ機械可読マーカーを出す
function Emit-Marker {
    param([string]$Text)
    if ($agentMode) { Write-Host "SGTOKEN: $Text" }
}

# 人間向けの説明。エージェントモードでは Claude が言い換えて伝えるので出さない
function Say {
    param([string]$Text = '')
    if (-not $agentMode) { Write-Host $Text }
}

# 異常終了でも必ず DONE を出す。Claude 側はこの行をポーリングの打ち切り条件に使う
function Exit-Script {
    param([int]$Code = 0)
    Emit-Marker 'DONE'
    exit $Code
}

function Fail-Script {
    # $Reason = 機械可読の理由、$Message = 人間向けの説明
    param([string]$Reason, [string]$Message)
    Emit-Marker "ERROR $Reason"
    if ($agentMode) { Write-Host $Message } else { Write-Host "エラー: $Message" }
    Exit-Script 1
}

# 想定外の中断でも DONE を出す。これが無いと Claude のポーリングが終わらない
trap {
    Emit-Marker 'ERROR UNEXPECTED'
    Write-Host $_.Exception.Message
    Emit-Marker 'DONE'
    exit 1
}

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
    Fail-Script 'PORT_BUSY' "ポート $CallbackPort を使えません。他のプロセスが使用中なら止めてから再実行してください。 $($_.Exception.Message)"
}

Say 'ブラウザでログインしてください。開かない場合は次のURLを開いてください。'
Say "  $authUrl"
Say ''
Say "（ログインが終わるまで最大 $waitSeconds 秒待ちます。やめるときはこのウィンドウを閉じてください）"

# 認可 URL 自体は秘密ではない（含まれるのは PKCE のチャレンジのみ）。
# ブラウザが自動で開かなかったときに Claude が案内できるよう先に出しておく
Emit-Marker "AUTH_URL $authUrl"

Start-Process $authUrl | Out-Null

Emit-Marker "WAITING_LOGIN $waitSeconds"

# ブラウザでの完了表示
$completedPage = '<!doctype html><meta charset="utf-8"><title>接続用トークンの払い出し</title><p>受け取りました。Claude Code へ戻ってください。</p>'
$completedBytes = [Text.Encoding]::UTF8.GetBytes($completedPage)

$code = ''
$authError = ''
$timedOut = $false
$deadline = (Get-Date).AddSeconds($waitSeconds)
try {
    # favicon 等の関係ないリクエストは 404 で受け流し、/callback が来るまで待つ。
    # 待ち受けは締め切りで打ち切る（放置されたリスナーがポートを掴み続けないように）
    while (-not $code -and -not $authError) {
        $remainingMs = [int]([Math]::Max(0, ($deadline - (Get-Date)).TotalMilliseconds))
        if ($remainingMs -le 0) { $timedOut = $true; break }

        $task = $listener.GetContextAsync()
        if (-not $task.Wait($remainingMs)) { $timedOut = $true; break }
        $context = $task.Result

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

if ($timedOut) {
    Fail-Script 'TIMEOUT' "ログインが $waitSeconds 秒以内に終わりませんでした。もう一度実行してください。"
}
if ($authError) {
    Fail-Script "AUTH_FAILED $authError" "ログインに失敗しました: $authError"
}
if (-not $code) {
    Fail-Script 'NO_CODE' '認可コードを受け取れませんでした。もう一度実行してください。'
}

Emit-Marker 'CODE_RECEIVED'

# ── 認可コードをトークンへ引き換える ──
$tokenBody = "grant_type=authorization_code&client_id=$ClientId&code=$code" +
    "&redirect_uri=$RedirectUriEncoded&code_verifier=$verifier"
try {
    $tokenResponse = Invoke-RestMethod -Method Post -Uri "https://$Domain/oauth2/token" `
        -ContentType 'application/x-www-form-urlencoded' -Body $tokenBody
} catch {
    $original = $_
    $detail = $original.Exception.Message
    if (-not $agentMode) {
        # 応答本文が読めるなら読む（エージェントモードでは出さない）
        try {
            $reader = New-Object System.IO.StreamReader($original.Exception.Response.GetResponseStream())
            $detail = $reader.ReadToEnd()
        } catch { }
    }
    Fail-Script 'TOKEN_EXCHANGE_FAILED' "トークンの取得に失敗しました。 $detail"
}

$refreshToken = $tokenResponse.refresh_token
if (-not $refreshToken) {
    Fail-Script 'TOKEN_EXCHANGE_FAILED' 'リフレッシュトークンが返りませんでした。時間をおいて再実行してください。'
}

# ── Claude Code へ登録する ──
# ここからは claude コマンド（外部プログラム）の実行が主になるため、
# stderr への出力を例外へ変換させない
$ErrorActionPreference = 'Continue'

# claude コマンドが見つからない／登録に失敗したときの逃げ道。トークンを画面へ
# 出さずに済むよう、「実行するだけで登録が終わるスクリプト」を書き出す。
# 利用者（や Claude）が打つのは実行の1行だけで、秘密を含まない
function Write-ManualScript {
    $manualDir = Join-Path $env:TEMP 'slide-generator-setup'
    New-Item -ItemType Directory -Force -Path $manualDir | Out-Null
    $manualScript = Join-Path $manualDir 'register_slide_generator.ps1'
    $content = @"
# slide-generator を Claude Code へ登録する。実行すると自分を消す。
# このファイルには接続用トークン（パスワード相当）が入っている。他人へ渡さないこと。
cmd /c 'claude mcp remove --scope user slide-generator >nul 2>&1'
claude mcp add --scope user --transport http slide-generator $Endpoint --header "Authorization: Bearer $refreshToken"
if (`$LASTEXITCODE -eq 0) { Write-Host '登録が完了しました。' }
Remove-Item -LiteralPath `$PSCommandPath -Force
"@
    Set-Content -LiteralPath $manualScript -Value $content -Encoding UTF8

    # 作成者だけが読めるようにする（継承を切って自分の ACL だけ残す）
    try {
        $acl = Get-Acl -LiteralPath $manualScript
        $acl.SetAccessRuleProtection($true, $false)
        @($acl.Access) | ForEach-Object { $acl.RemoveAccessRule($_) | Out-Null }
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            $env:USERNAME, 'FullControl', 'Allow')
        $acl.SetAccessRule($rule)
        Set-Acl -LiteralPath $manualScript -AclObject $acl
    } catch { }

    return $manualScript
}

$claudeCommand = Get-Command claude -ErrorAction SilentlyContinue
if (-not $claudeCommand) {
    $manualScript = Write-ManualScript
    Emit-Marker "MANUAL $manualScript"
    Say ''
    Say 'claude コマンドが見つかりませんでした。次の1行を実行すると登録できます。'
    Say ''
    Say "  powershell -ExecutionPolicy Bypass -File `"$manualScript`""
    Exit-Script 0
}

Say ''
Say 'Claude Code へ登録します（既存の slide-generator の登録は置き換えます）。'
cmd /c 'claude mcp remove --scope user slide-generator >nul 2>&1'
# claude mcp add はヘッダ（＝トークン）を復唱することがあるため出力を捨てる
claude mcp add --scope user --transport http slide-generator $Endpoint --header "Authorization: Bearer $refreshToken" *> $null
if ($LASTEXITCODE -eq 0) {
    Emit-Marker 'REGISTERED'
    Say ''
    Say '登録が完了しました。新しく開いた Claude Code から使えます'
    Say '（開きっぱなしの Claude Code には、開き直すと反映されます）。'
    Say '確認するには: claude mcp list （slide-generator が Connected ならOK）'
    Exit-Script 0
} else {
    $manualScript = Write-ManualScript
    Emit-Marker "MANUAL $manualScript"
    Say ''
    Say '登録に失敗しました。次の1行を実行してください。'
    Say ''
    Say "  powershell -ExecutionPolicy Bypass -File `"$manualScript`""
    Exit-Script 0
}
