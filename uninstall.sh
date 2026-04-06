#!/usr/bin/env bash
# uninstall.sh — Remove sx

set -e

TARGET="${HOME}/.local/bin/sx"
CONFIG_DIR="${HOME}/.config/sx"

if [ -f "$TARGET" ]; then
    rm "$TARGET"
    echo "Removed $TARGET"
else
    echo "sx is not installed."
fi

if [ -d "$CONFIG_DIR" ]; then
    rm -rf "$CONFIG_DIR"
    echo "Removed $CONFIG_DIR"
fi

BASH_COMP="${HOME}/.local/share/bash-completion/completions/sx"
ZSH_COMP="${HOME}/.local/share/zsh/site-functions/_sx"

[ -f "$BASH_COMP" ] && rm "$BASH_COMP" && echo "Removed bash completions"
[ -f "$ZSH_COMP" ] && rm "$ZSH_COMP" && echo "Removed zsh completions"
