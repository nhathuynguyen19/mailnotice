#!/usr/bin/env bash
set -e

APP_DIR="$(cd "$(dirname "$0")" && pwd)"
SERVICE_NAME="mailnotice"
PKG_FILE="$APP_DIR/package_requirements.txt"

echo "Gỡ cài đặt MailNotice..."

# Dừng và xóa user service nếu có
if systemctl --user list-units --all --type=service | grep -q "${SERVICE_NAME}.service"; then
    echo "Stopping user service..."
    systemctl --user stop "$SERVICE_NAME" || true
    systemctl --user disable "$SERVICE_NAME" || true
    rm -f "$HOME/.config/systemd/user/${SERVICE_NAME}.service"
fi

# Xóa virtual environment
if [ -d "$APP_DIR/venv" ]; then
    echo "Removing virtual environment..."
    rm -rf "$APP_DIR/venv"
fi

echo "Hoàn tất gỡ cài đặt MailNotice!"
