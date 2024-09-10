import os
import requests
import logging
from urllib.parse import quote
import time
import json
from requests.exceptions import RequestException

# Configuration
MOONRAKER_URL = "http://localhost:7125"
LISTER_PRINTABLES_PATH = "/home/pi/printer_data/gcodes/lister_printables"
LOG_FILE = "/home/pi/printer_data/logs/metadata_scan.log"
MAX_RETRIES = 10
RETRY_DELAY = 30  # seconds
SCAN_DELAY = 0.5  # seconds


def setup_logging():
    os.makedirs(os.path.dirname(LOG_FILE), exist_ok=True)
    logging.basicConfig(filename=LOG_FILE, level=logging.INFO,
                        format='%(asctime)s - %(levelname)s - %(message)s')


def is_moonraker_ready():
    try:
        response = requests.get(f"{MOONRAKER_URL}/server/info", timeout=5)
        return response.status_code == 200
    except RequestException:
        return False


def wait_for_moonraker():
    for attempt in range(MAX_RETRIES):
        if is_moonraker_ready():
            logging.info("Moonraker is ready.")
            return True
        logging.info(
            f"Waiting for Moonraker to be ready. Attempt {attempt + 1}/{MAX_RETRIES}. Retrying in {RETRY_DELAY} seconds...")
        time.sleep(RETRY_DELAY)
    return False


def scan_file_metadata(file_path):
    relative_path = os.path.relpath(file_path, "/home/pi/printer_data/gcodes")
    encoded_path = quote(relative_path)
    url = f"{MOONRAKER_URL}/server/files/metascan"

    try:
        data = {"filename": encoded_path}
        response = requests.post(url, json=data, timeout=60)
        response.raise_for_status()
        logging.info(f"Successfully scanned metadata for {relative_path}")
        return True
    except RequestException as e:
        logging.error(f"Error scanning metadata for {relative_path}: {str(e)}")
        if hasattr(e, 'response') and e.response is not None:
            logging.error(f"Response content: {e.response.content}")
        return False


def walk_directory(directory):
    for root, dirs, files in os.walk(directory):
        if '.thumbs' in dirs:
            dirs.remove('.thumbs')
        for file in files:
            if file.lower().endswith(('.gcode', '.g', '.gco')):
                yield os.path.join(root, file)


def main():
    setup_logging()
    logging.info("Starting Lister metadata scan")

    if not wait_for_moonraker():
        logging.error("Moonraker is not ready after maximum retries. Aborting metadata scan.")
        return

    start_time = time.time()
    file_count = 0
    success_count = 0
    failed_files = []

    try:
        for file_path in walk_directory(LISTER_PRINTABLES_PATH):
            if scan_file_metadata(file_path):
                success_count += 1
            else:
                failed_files.append(file_path)
            file_count += 1
            time.sleep(SCAN_DELAY)

        end_time = time.time()
        duration = end_time - start_time
        logging.info(
            f"Lister metadata scan completed. Scanned {file_count} files, {success_count} successful, in {duration:.2f} seconds.")

        if failed_files:
            logging.warning(f"Failed to scan {len(failed_files)} files. Retrying...")
            for file_path in failed_files:
                if scan_file_metadata(file_path):
                    success_count += 1
                time.sleep(SCAN_DELAY)

            logging.info(f"Retry completed. Total successful scans: {success_count}")

    except Exception as e:
        logging.exception(f"An unexpected error occurred during the scan: {str(e)}")


if __name__ == "__main__":
    main()