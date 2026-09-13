#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

install_context_mode() {
    if ! command -v npm >/dev/null 2>&1; then
        error "npm is not installed. Ensure nodejs and npm packages are installed."
    fi

    local current_ver=""
    local latest_ver=""

    if command -v node >/dev/null 2>&1 && [[ -f "$HOME/.npm-global/lib/node_modules/context-mode/package.json" ]]; then
        current_ver=$(node -p "require('$HOME/.npm-global/lib/node_modules/context-mode/package.json').version" 2>/dev/null || true)
    fi

    latest_ver=$(npm view context-mode version 2>/dev/null || true)

    if [[ -n "$current_ver" && -n "$latest_ver" && "$current_ver" == "$latest_ver" ]]; then
        info "context-mode is already at latest version (v$current_ver). Skipping."
        mkdir -p "$HOME/.local/bin"
        ln -sf "$HOME/.npm-global/bin/context-mode" "$HOME/.local/bin/context-mode"
        return 0
    fi

    info "Installing/updating context-mode (current: ${current_ver:-none}, latest: ${latest_ver:-unknown})..."
    mkdir -p "$HOME/.npm-global" "$HOME/.local/bin"
    npm config set prefix "$HOME/.npm-global"
    npm config set allow-scripts=context-mode,better-sqlite3 --location=user

    npm install -g context-mode
    ln -sf "$HOME/.npm-global/bin/context-mode" "$HOME/.local/bin/context-mode"
    success "context-mode successfully installed/updated."
}

install_codebase_memory() {
    local bin_path="$HOME/.local/bin/codebase-memory-mcp"
    local current_ver=""
    local latest_ver=""

    if [[ -x "$bin_path" ]]; then
        current_ver=$("$bin_path" --version 2>/dev/null | awk '{print $2}' | sed 's/^v//' || true)
    elif command -v codebase-memory-mcp >/dev/null 2>&1; then
        current_ver=$(codebase-memory-mcp --version 2>/dev/null | awk '{print $2}' | sed 's/^v//' || true)
    fi

    latest_ver=$(curl -fsSI "https://github.com/DeusData/codebase-memory-mcp/releases/latest" 2>/dev/null | tr -d '\r' | sed -nE 's/^[Ll]ocation:.*\/tag\/v?([0-9.]+)/\1/p' || true)

    if [[ -n "$current_ver" && -n "$latest_ver" && "$current_ver" == "$latest_ver" ]]; then
        info "codebase-memory-mcp is already at latest version (v$current_ver). Skipping."
        return 0
    fi

    info "Installing/updating codebase-memory-mcp (current: ${current_ver:-none}, latest: ${latest_ver:-unknown})..."
    mkdir -p "$HOME/.local/bin"

    curl -fsSL https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/main/install.sh | bash -s -- --dir "$HOME/.local/bin" --skip-config

    if command -v "$bin_path" >/dev/null 2>&1; then
        "$bin_path" config set auto_index true >/dev/null 2>&1 || true
    fi
    success "codebase-memory-mcp successfully installed/updated."
}

main() {
    install_context_mode
    install_codebase_memory
    success "External MCP servers check completed."
}

main "$@"
