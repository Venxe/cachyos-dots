#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

install_context_mode() {
    info "Installing context-mode MCP server via npm..."
    if ! command -v npm >/dev/null 2>&1; then
        error "npm is not installed. Ensure nodejs and npm packages are installed."
    fi

    mkdir -p "$HOME/.npm-global" "$HOME/.local/bin"
    npm config set prefix "$HOME/.npm-global"
    npm config set allow-scripts=context-mode,better-sqlite3 --location=user

    npm install -g context-mode
    ln -sf "$HOME/.npm-global/bin/context-mode" "$HOME/.local/bin/context-mode"
    success "context-mode successfully installed."
}

install_codebase_memory() {
    info "Installing codebase-memory-mcp..."
    mkdir -p "$HOME/.local/bin"

    curl -fsSL https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/main/install.sh | bash -s -- --dir "$HOME/.local/bin" --skip-config

    if command -v "$HOME/.local/bin/codebase-memory-mcp" >/dev/null 2>&1; then
        "$HOME/.local/bin/codebase-memory-mcp" config set auto_index true >/dev/null 2>&1 || true
    fi
    success "codebase-memory-mcp successfully installed."
}

main() {
    install_context_mode
    install_codebase_memory
    success "External MCP servers setup completed."
}

main "$@"
