import os
import requests
import logging
from urllib.parse import quote
import time

# Configuration
MOONRAKER_URL = "http://localhost:7125"  # Adjust if necessary
LISTER_PRINTABLES_PATH = "/home/pi/printer_data/gcodes/lister_printables"  # Adjust path as needed
LOG_FILE = "/home/pi/printer_data/gcodes/lister_printables/metadata_scan.log"


def setup_logging():
    # Delete the old log file if it exists
    if os.path.exists(LOG_FILE):
        os.remove(LOG_FILE)

    # Set up logging
    logging.basicConfig(filename=LOG_FILE, level=logging.INFO,
                        format='%(asctime)s - %(levelname)s - %(message)s')


def scan_file_metadata(file_path):
    relative_path = os.path.relpath(file_path, "/home/pi/printer_data/gcodes")
    encoded_path = quote(relative_path)
    url = f"{MOONRAKER_URL}/server/files/metascan"

    try:
        data = {"filename": encoded_path}
        response = requests.post(url, json=data)
        response.raise_for_status()
        logging.info(f"Successfully scanned metadata for {relative_path}")
    except requests.exceptions.RequestException as e:
        logging.error(f"Error scanning metadata for {relative_path}: {str(e)}")
        if hasattr(e, 'response') and e.response is not None:
            logging.error(f"Response content: {e.response.content}")


def walk_directory(directory):
    for root, dirs, files in os.walk(directory):
        if '.thumbs' in dirs:
            dirs.remove('.thumbs')  # don't visit .thumbs directories
        for file in files:
            if file.lower().endswith(('.gcode', '.g', '.gco')):
                yield os.path.join(root, file)


def main():
    setup_logging()
    logging.info("Starting Lister metadata scan")
    start_time = time.time()

    try:
        file_count = 0
        for file_path in walk_directory(LISTER_PRINTABLES_PATH):
            scan_file_metadata(file_path)
            file_count += 1
            time.sleep(0.1)  # Small delay to avoid overwhelming Moonraker

        end_time = time.time()
        duration = end_time - start_time
        logging.info(f"Lister metadata scan completed. Scanned {file_count} files in {duration:.2f} seconds.")
    except Exception as e:
        logging.exception(f"An unexpected error occurred during the scan: {str(e)}")


if __name__ == "__main__":
    main()