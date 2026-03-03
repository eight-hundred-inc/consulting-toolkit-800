#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/masaki69/consulting-toolkit.git"
INSTALL_DIR="${HOME}/.local/share/consulting-toolkit"
PLUGIN_DIR="${INSTALL_DIR}/plugins/consulting-toolkit"

usage() {
  cat <<EOF
consulting-toolkit installer

Usage: $0 [OPTIONS]

Options:
  --update    既存のインストールを更新する
  --uninstall シンボリックリンクとクローンを削除する
  -h, --help  このヘルプを表示する

Skills / Agents / Commands を Cursor のグローバルディレクトリにシンボリックリンクで配置する。
  ~/.cursor/skills/   ← plugins/consulting-toolkit/skills/*
  ~/.cursor/agents/   ← plugins/consulting-toolkit/agents/*.md
  ~/.cursor/commands/ ← plugins/consulting-toolkit/commands/*.md
EOF
  exit 0
}

log() { printf '\033[0;36m%s\033[0m\n' "$*"; }
warn() { printf '\033[0;33m%s\033[0m\n' "$*"; }
err() { printf '\033[0;31m%s\033[0m\n' "$*" >&2; exit 1; }

link_skills() {
  mkdir -p "${HOME}/.cursor/skills"
  for skill_dir in "${PLUGIN_DIR}/skills"/*/; do
    [ -d "$skill_dir" ] || continue
    local name
    name=$(basename "$skill_dir")
    local target="${HOME}/.cursor/skills/${name}"
    if [ -L "$target" ]; then
      rm "$target"
    elif [ -e "$target" ]; then
      warn "  skip: ${target} (既存のファイル/ディレクトリが存在)"
      continue
    fi
    ln -sf "$skill_dir" "$target"
    log "  linked: skills/${name}"
  done
}

link_agents() {
  mkdir -p "${HOME}/.cursor/agents"
  for agent_file in "${PLUGIN_DIR}/agents"/*.md; do
    [ -f "$agent_file" ] || continue
    local name
    name=$(basename "$agent_file")
    local target="${HOME}/.cursor/agents/${name}"
    if [ -L "$target" ]; then
      rm "$target"
    elif [ -e "$target" ]; then
      warn "  skip: ${target} (既存のファイルが存在)"
      continue
    fi
    ln -sf "$agent_file" "$target"
    log "  linked: agents/${name}"
  done
}

link_commands() {
  mkdir -p "${HOME}/.cursor/commands"
  for cmd_file in "${PLUGIN_DIR}/commands"/*.md; do
    [ -f "$cmd_file" ] || continue
    local name
    name=$(basename "$cmd_file")
    local target="${HOME}/.cursor/commands/${name}"
    if [ -L "$target" ]; then
      rm "$target"
    elif [ -e "$target" ]; then
      warn "  skip: ${target} (既存のファイルが存在)"
      continue
    fi
    ln -sf "$cmd_file" "$target"
    log "  linked: commands/${name}"
  done
}

do_install() {
  log "=== consulting-toolkit installer ==="

  if [ -d "$INSTALL_DIR" ]; then
    log "既存のインストールを検出: ${INSTALL_DIR}"
    log "更新します..."
    git -C "$INSTALL_DIR" pull --ff-only
  else
    log "クローン: ${REPO_URL}"
    git clone "$REPO_URL" "$INSTALL_DIR"
  fi

  log ""
  log "シンボリックリンクを作成..."
  link_skills
  link_agents
  link_commands

  log ""
  log "=== インストール完了 ==="
  log "Cursor を再起動すると Skills / Agents / Commands が認識されます。"
}

do_update() {
  [ -d "$INSTALL_DIR" ] || err "${INSTALL_DIR} が見つかりません。先に install を実行してください。"

  log "=== consulting-toolkit updater ==="
  git -C "$INSTALL_DIR" pull --ff-only

  log ""
  log "シンボリックリンクを更新..."
  link_skills
  link_agents
  link_commands

  log ""
  log "=== 更新完了 ==="
}

do_uninstall() {
  log "=== consulting-toolkit uninstaller ==="

  for skill_dir in "${HOME}/.cursor/skills"/*/; do
    [ -L "${skill_dir%/}" ] && [[ "$(readlink "${skill_dir%/}")" == *"${INSTALL_DIR}"* ]] && {
      rm "${skill_dir%/}"
      log "  removed: ${skill_dir%/}"
    }
  done

  for f in "${HOME}/.cursor/agents"/*.md "${HOME}/.cursor/commands"/*.md; do
    [ -L "$f" ] && [[ "$(readlink "$f")" == *"${INSTALL_DIR}"* ]] && {
      rm "$f"
      log "  removed: ${f}"
    }
  done

  if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
    log "  removed: ${INSTALL_DIR}"
  fi

  log ""
  log "=== アンインストール完了 ==="
}

case "${1:-}" in
  --update)    do_update ;;
  --uninstall) do_uninstall ;;
  -h|--help)   usage ;;
  "")          do_install ;;
  *)           err "不明なオプション: $1" ;;
esac
