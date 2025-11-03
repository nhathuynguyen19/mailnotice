#!/usr/bin/env bash
set -e

APP_DIR="$(cd "$(dirname "$0")" && pwd)"
SERVICE_NAME="mailnotice"
BIN_DIR="$HOME/.local/bin"
SERVICE_FILE="$HOME/.config/systemd/user/${SERVICE_NAME}.service"

echo "[INFO] Setting up Python venv..."
python3 -m venv "$APP_DIR/venv"
source "$APP_DIR/venv/bin/activate"
pip install -r "$APP_DIR/requirements.txt"

echo "[INFO] Installing systemd service..."

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

# -------------------------------
# Tạo lệnh mailnotice-config
# -------------------------------
mkdir -p "$BIN_DIR"

cat > "$BIN_DIR/mailnotice-config" <<EOF
#!/usr/bin/env bash
APP_DIR="$APP_DIR"

read -p "IMAP Host: " host
read -p "Username: " username
read -s -p "App password: " password
echo ""

CONFIG_FILE="\$APP_DIR/config.json"

cat > "\$CONFIG_FILE" <<JSON
{
    "host": "\$host",
    "username": "\$username",
    "password": "\$password"
}
JSON

echo "[INFO] Saved configuration to \$CONFIG_FILE"
EOF

chmod +x "$BIN_DIR/mailnotice-config"

if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    echo "[INFO] Added ~/.local/bin to PATH. Please restart terminal or run:"
    echo "    source ~/.bashrc"
fi

echo "[INFO] Installation complete."
echo "[TIP] Run: mailnotice-config  → to set IMAP host/username/password."
