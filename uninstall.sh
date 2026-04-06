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
