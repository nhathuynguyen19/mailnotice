from imapclient import IMAPClient
from utils import *
import email

config = load_config("config.json")

def main():
    try:
        with IMAPClient(config['host']) as server:
            server.login(config['username'], config['password'])
            folder_info = server.select_folder('INBOX', readonly=True)
            mailnotice(server)
    except IMAPClient.Error as e:
        print("IMAP Error")
    except Exception as e:
        print("Invalid Error")

if __name__ == "__main__":
    main()
