#!/usr/bin/env bash
set -e

APP_DIR="$(cd "$(dirname "$0")" && pwd)"
SERVICE_NAME="mailnotice"

echo "[INFO] Updating apt..."
sudo apt update -y || echo "[INFO] apt update had warnings, continuing..."

if [ -f "$APP_DIR/package_requirements.txt" ]; then
    echo "[INFO] Installing system packages..."
    sudo xargs -a "$APP_DIR/package_requirements.txt" apt install -y
fi

echo "[INFO] Setting up Python venv..."
python3 -m venv "$APP_DIR/venv"
source "$APP_DIR/venv/bin/activate"
pip install --upgrade pip
pip install -r "$APP_DIR/requirements.txt"

echo "[INFO] Installing systemd service..."
SERVICE_FILE="$HOME/.config/systemd/user/${SERVICE_NAME}.service"

mkdir -p "$(dirname "$SERVICE_FILE")"

cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=MailNotice App (User)
After=graphical-session.target

[Service]
Type=simple
ExecStart=$APP_DIR/venv/bin/python $APP_DIR/app.py
WorkingDirectory=$APP_DIR
Restart=always
Environment=DISPLAY=:0
Environment=DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable $SERVICE_NAME
systemctl --user start $SERVICE_NAME


echo "[INFO] Installation complete. The app is now running as a background user service."
