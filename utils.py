import os
import getpass
import json
import email
from imapclient import IMAPClient
from email.header import decode_header
import gi
gi.require_version('Notify', '0.7')
from gi.repository import Notify
import subprocess
import re

CONFIG_FILE = "config.json"

def wait_for_config(config_file: str) -> dict:
    flag_info = True
    while not os.path.exists(config_file):
        if flag_info:
            print("[INFO] Waiting for config.json... (run mailnotice-config)")
            flag_info = False
        time.sleep(3)
    print("[INFO] Detected config.json")
    return load_config(config_file)

def load_config(config_file: str) -> dict:
    if os.path.exists(config_file):
        with open(config_file, "r") as f:
            config = json.load(f)
    return config

def decode_mime_words(s):
    if not s:
        return ""
    decoded = decode_header(s)
    return ''.join(
        part.decode(enc or 'utf-8') if isinstance(part, bytes) else part
        for part, enc in decoded
    )

def get_message(server: IMAPClient):
    uids = server.search(['ALL'])
    if uids:
        latest_uid = uids[-1]
        raw_data = server.fetch([latest_uid], ['RFC822'])
        raw_msg = raw_data[latest_uid][b'RFC822']
        return email.message_from_bytes(raw_msg)

def get_body_message(message, body: str = "") -> str:
    if message.is_multipart():
        for part in message.walk():
            content_type = part.get_content_type()
            disposition = str(part.get("Content-Disposition"))
            if content_type == "text/plain" and "attachment" not in disposition:
                body += part.get_payload(decode=True).decode(errors="ignore")
        return body
    else:
        return message.get_payload(decode=True).decode(errors="ignore")

def system_popup(subject: str, body: str):
    Notify.init("Notifier")
    n = Notify.Notification.new(f"{subject}", f"{body}")
    n.set_timeout(0)
    n.show()
    subprocess.Popen(["paplay", "/usr/share/sounds/freedesktop/stereo/message.oga"])
    
def mailnotice(server: IMAPClient):
    while True:
        server.idle()
        print("Waiting for responses...")
        responses = server.idle_check(timeout=500)
        server.idle_done()
        if responses:
            message = get_message(server)
            subject = decode_mime_words(message.get("Subject"))
            body = get_body_message(message)
            system_popup(subject=subject, body=body)
        time.sleep(1)

def main():
    system_popup("test", "test")

if __name__ == "__main__":
    main()