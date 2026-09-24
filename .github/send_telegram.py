import os
import sys
import requests
from datetime import datetime

def fix_encoding():
    # Force UTF-8 encoding in Windows
    if sys.platform == "win32":
        sys.stdout.reconfigure(encoding='utf-8')
        sys.stderr.reconfigure(encoding='utf-8')

def send_telegram_message(token, chat_id, file_path, message):
    url = f"https://api.telegram.org/bot{token}/sendDocument"
    try:
        with open(file_path, 'rb') as file:
            files = {'document': file}
            data = {'chat_id': chat_id, 'caption': message}
            response = requests.post(url, files=files, data=data)
            response.raise_for_status()
            return response.json()
    except Exception as e:
        print(f"Telegram API Error: {str(e)}", file=sys.stderr)
        return None

def main():
    fix_encoding()  # Apply encoding fix

    try:
        telegram_token = os.getenv('TELEGRAM_BOT_TOKEN')
        chat_id = os.getenv('TELEGRAM_CHAT_ID')
        version_name = os.getenv('VERSION_NAME')

        # Path handling for Windows
        file_path = os.path.join('build', 'app', 'outputs', 'flutter-apk', f'app-release-{version_name}.apk')

        if not os.path.exists(file_path):
            raise FileNotFoundError(f"APK file not found at {file_path}")

        # Prepare message (without emoji if issues persist)
        # message = (
        #     "New App Release\n\n"
        #     f"Repository: {os.getenv('GITHUB_REPOSITORY')}\n"
        #     f"Version: {version_name}\n"
        #     f"Commit: {os.getenv('GITHUB_SHA')[:7]}\n"
        #     f"Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n"
        #     f"Message: {os.getenv('GITHUB_COMMIT_MESSAGE')}"
        # )

        repository = os.getenv('GITHUB_REPOSITORY')
        commit_sha = os.getenv('GITHUB_SHA')
        commit_message = os.getenv('GITHUB_COMMIT_MESSAGE')
        commit_date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

        message = (
            f"🚀 New App Release\n\n"
            f"📦 Repository: {repository}\n"
            f"🔖 Version: {version_name}\n"
            f"📝 Commit: {commit_sha[:7]}\n"
            f"📅 Date: {commit_date}\n"
            f"💬 Message: {commit_message}"
        )

        print("Attempting to send to Telegram...")
        result = send_telegram_message(telegram_token, chat_id, file_path, message)

        if result:
            print("Successfully sent to Telegram")
        else:
            sys.exit(1)

    except Exception as e:
        print(f"Fatal Error: {str(e)}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
