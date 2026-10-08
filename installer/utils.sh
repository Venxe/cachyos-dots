#!/usr/bin/env bash

# Bash Strict Mode & Error Handling
set -Eeuo pipefail
trap 'error "Failed at line $LINENO: $BASH_COMMAND"' ERR

# Constants
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

# Helper Functions
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; exit 1; }
