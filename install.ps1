#Requires -Version 5.1
<#
.SYNOPSIS
    consulting-toolkit installer for Windows (Cursor)
.DESCRIPTION
    Skills / Agents / Commands を Cursor のグローバルディレクトリにコピーする。
    シンボリックリンクではなくファイルコピーを使用するため、管理者権限は不要。
.PARAMETER Update
    既存のインストールを更新する
.PARAMETER Uninstall
    コピーしたファイルとクローンを削除する
#>
param(
    [switch]$Update,
    [switch]$Uninstall
)

$ErrorActionPreference = "Stop"

$REPO_URL = "https://github.com/masaki69/consulting-toolkit.git"
$INSTALL_DIR = Join-Path $env:USERPROFILE ".local\share\consulting-toolkit"
$PLUGIN_DIR = Join-Path $INSTALL_DIR "plugins\consulting-toolkit"
$CURSOR_DIR = Join-Path $env:USERPROFILE ".cursor"
$MARKER = ".consulting-toolkit-managed"

function Write-Info($msg)  { Write-Host $msg -ForegroundColor Cyan }
function Write-Warn($msg)  { Write-Host $msg -ForegroundColor Yellow }
function Write-Err($msg)   { Write-Host $msg -ForegroundColor Red; exit 1 }

function Copy-Skills {
    $skillsDir = Join-Path $CURSOR_DIR "skills"
    if (-not (Test-Path $skillsDir)) { New-Item -ItemType Directory -Path $skillsDir -Force | Out-Null }

    $sourceSkills = Join-Path $PLUGIN_DIR "skills"
    if (-not (Test-Path $sourceSkills)) { return }

    foreach ($dir in Get-ChildItem -Path $sourceSkills -Directory) {
        $target = Join-Path $skillsDir $dir.Name
        if (Test-Path $target) {
            $markerFile = Join-Path $target $MARKER
            if (Test-Path $markerFile) {
                Remove-Item -Recurse -Force $target
            } else {
                Write-Warn "  skip: $target (既存のディレクトリが存在)"
                continue
            }
        }
        Copy-Item -Recurse -Force $dir.FullName $target
        New-Item -ItemType File -Path (Join-Path $target $MARKER) -Force | Out-Null
        Write-Info "  copied: skills/$($dir.Name)"
    }
}

function Copy-Agents {
    $agentsDir = Join-Path $CURSOR_DIR "agents"
    if (-not (Test-Path $agentsDir)) { New-Item -ItemType Directory -Path $agentsDir -Force | Out-Null }

    $sourceAgents = Join-Path $PLUGIN_DIR "agents"
    if (-not (Test-Path $sourceAgents)) { return }

    foreach ($file in Get-ChildItem -Path $sourceAgents -Filter "*.md") {
        $target = Join-Path $agentsDir $file.Name
        if ((Test-Path $target) -and -not (Test-Path (Join-Path $agentsDir "$($file.BaseName)$MARKER"))) {
            Write-Warn "  skip: $target (既存のファイルが存在)"
            continue
        }
        Copy-Item -Force $file.FullName $target
        New-Item -ItemType File -Path (Join-Path $agentsDir "$($file.BaseName)$MARKER") -Force | Out-Null
        Write-Info "  copied: agents/$($file.Name)"
    }
}

function Copy-Commands {
    $commandsDir = Join-Path $CURSOR_DIR "commands"
    if (-not (Test-Path $commandsDir)) { New-Item -ItemType Directory -Path $commandsDir -Force | Out-Null }

    $sourceCommands = Join-Path $PLUGIN_DIR "commands"
    if (-not (Test-Path $sourceCommands)) { return }

    foreach ($file in Get-ChildItem -Path $sourceCommands -Filter "*.md") {
        $target = Join-Path $commandsDir $file.Name
        if ((Test-Path $target) -and -not (Test-Path (Join-Path $commandsDir "$($file.BaseName)$MARKER"))) {
            Write-Warn "  skip: $target (既存のファイルが存在)"
            continue
        }
        Copy-Item -Force $file.FullName $target
        New-Item -ItemType File -Path (Join-Path $commandsDir "$($file.BaseName)$MARKER") -Force | Out-Null
        Write-Info "  copied: commands/$($file.Name)"
    }
}

function Do-Install {
    Write-Info "=== consulting-toolkit installer (Windows) ==="

    if (Test-Path $INSTALL_DIR) {
        Write-Info "既存のインストールを検出: $INSTALL_DIR"
        Write-Info "更新します..."
        git -C $INSTALL_DIR pull --ff-only
        if ($LASTEXITCODE -ne 0) { Write-Err "git pull に失敗しました" }
    } else {
        Write-Info "クローン: $REPO_URL"
        $parentDir = Split-Path $INSTALL_DIR -Parent
        if (-not (Test-Path $parentDir)) { New-Item -ItemType Directory -Path $parentDir -Force | Out-Null }
        git clone $REPO_URL $INSTALL_DIR
        if ($LASTEXITCODE -ne 0) { Write-Err "git clone に失敗しました" }
    }

    Write-Info ""
    Write-Info "ファイルをコピー..."
    Copy-Skills
    Copy-Agents
    Copy-Commands

    Write-Info ""
    Write-Info "=== インストール完了 ==="
    Write-Info "Cursor を再起動すると Skills / Agents / Commands が認識されます。"
}

function Do-Update {
    if (-not (Test-Path $INSTALL_DIR)) {
        Write-Err "$INSTALL_DIR が見つかりません。先にインストールを実行してください。"
    }

    Write-Info "=== consulting-toolkit updater (Windows) ==="
    git -C $INSTALL_DIR pull --ff-only
    if ($LASTEXITCODE -ne 0) { Write-Err "git pull に失敗しました" }

    Write-Info ""
    Write-Info "ファイルを更新..."
    Copy-Skills
    Copy-Agents
    Copy-Commands

    Write-Info ""
    Write-Info "=== 更新完了 ==="
}

function Do-Uninstall {
    Write-Info "=== consulting-toolkit uninstaller (Windows) ==="

    $skillsDir = Join-Path $CURSOR_DIR "skills"
    if (Test-Path $skillsDir) {
        foreach ($dir in Get-ChildItem -Path $skillsDir -Directory) {
            $markerFile = Join-Path $dir.FullName $MARKER
            if (Test-Path $markerFile) {
                Remove-Item -Recurse -Force $dir.FullName
                Write-Info "  removed: $($dir.FullName)"
            }
        }
    }

    foreach ($subDir in @("agents", "commands")) {
        $dir = Join-Path $CURSOR_DIR $subDir
        if (-not (Test-Path $dir)) { continue }
        foreach ($marker in Get-ChildItem -Path $dir -Filter "*$MARKER") {
            $baseName = $marker.BaseName
            $mdFile = Join-Path $dir "$baseName.md"
            if (Test-Path $mdFile) {
                Remove-Item -Force $mdFile
                Write-Info "  removed: $mdFile"
            }
            Remove-Item -Force $marker.FullName
        }
    }

    if (Test-Path $INSTALL_DIR) {
        Remove-Item -Recurse -Force $INSTALL_DIR
        Write-Info "  removed: $INSTALL_DIR"
    }

    Write-Info ""
    Write-Info "=== アンインストール完了 ==="
}

if ($Uninstall) {
    Do-Uninstall
} elseif ($Update) {
    Do-Update
} else {
    Do-Install
}
