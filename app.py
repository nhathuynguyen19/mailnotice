from imapclient import IMAPClient
from utils import *
import email
import time

CONFIG_FILE = "config.json"

def main():
    config = wait_for_config(CONFIG_FILE)
    try:
        with IMAPClient(config['host']) as server:
            server.login(config['username'], config['password'])
            folder_info = server.select_folder('INBOX', readonly=True)
            mailnotice(server)
    except IMAPClient.Error as e:
        print(f"[ERROR] IMAP Error: {e}")
    except Exception as e:
        print(f"[ERROR] Unexpected Error: {e}")

if __name__ == "__main__":
    main()
