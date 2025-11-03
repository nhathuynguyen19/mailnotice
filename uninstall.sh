#!/usr/bin/env bash
set -e

APP_DIR="$(cd "$(dirname "$0")" && pwd)"
SERVICE_NAME="mailnotice"
PKG_FILE="$APP_DIR/package_requirements.txt"
CONFIG_CMD="$HOME/.local/bin/mailnotice-config"

echo "[INFO] Uninstalling MailNotice..."

# Dừng và xóa user service nếu có
if systemctl --user list-units --all --type=service | grep -q "${SERVICE_NAME}.service"; then
    echo "[INFO] Stopping user service..."
    systemctl --user stop "$SERVICE_NAME" || true
    systemctl --user disable "$SERVICE_NAME" || true
    rm -f "$HOME/.config/systemd/user/${SERVICE_NAME}.service"
    systemctl --user daemon-reload
fi

# Xóa virtual environment
if [ -d "$APP_DIR/venv" ]; then
    echo "[INFO] Removing virtual environment..."
    rm -rf "$APP_DIR/venv"
fi

# Xóa lệnh mailnotice-config
if [ -f "$CONFIG_CMD" ]; then
    echo "[INFO] Removing mailnotice-config command..."
    rm -f "$CONFIG_CMD"
fi

echo "[INFO] MailNotice has been uninstalled!"
