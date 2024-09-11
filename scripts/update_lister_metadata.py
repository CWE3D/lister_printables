import os
import logging
from urllib.parse import quote
import time
import asyncio


class ListerPrintables:
    def __init__(self, config):
        self.server = config.get_server()
        self.moonraker_url = config.get('moonraker_url', "http://localhost:7125")
        self.lister_printables_path = config.get('lister_printables_path',
                                                 "/home/pi/printer_data/gcodes/lister_printables")
        self.log_file = config.get('log_file', "/home/pi/printer_data/logs/metadata_scan.log")
        self.gcodes_root = config.get('gcodes_root', "/home/pi/printer_data/gcodes")
        self.scan_interval = config.getint('scan_interval', 3600)  # Default to 1 hour

        # Setup logging
        logging.basicConfig(filename=self.log_file, level=logging.INFO,
                            format='%(asctime)s - %(levelname)s - %(message)s')

        self.server.register_event_handler("server:klippy_ready", self._handle_server_ready)
        self.scan_task = None

    async def _handle_server_ready(self):
        logging.info("Moonraker is ready. Starting Lister Printables background task.")
        if self.scan_task is not None:
            self.scan_task.cancel()
        self.scan_task = asyncio.create_task(self._background_scan_task())

    async def _background_scan_task(self):
        while True:
            await self._scan_metadata()
            await asyncio.sleep(self.scan_interval)

    async def _scan_metadata(self):
        logging.info("Starting Lister Printables metadata scan.")
        start_time = time.time()
        file_count = 0
        success_count = 0
        failed_files = []

        try:
            async for file_path in self._walk_directory(self.lister_printables_path):
                if await self._scan_file_metadata(file_path):
                    success_count += 1
                else:
                    failed_files.append(file_path)
                file_count += 1
                await asyncio.sleep(0.1)  # Small delay to prevent blocking

            end_time = time.time()
            duration = end_time - start_time
            logging.info(
                f"Lister metadata scan completed. Scanned {file_count} files, {success_count} successful, in {duration:.2f} seconds.")

            if failed_files:
                logging.warning(f"Failed to scan {len(failed_files)} files. Retrying...")
                for file_path in failed_files:
                    if await self._scan_file_metadata(file_path):
                        success_count += 1
                    await asyncio.sleep(0.1)

                logging.info(f"Retry completed. Total successful scans: {success_count}")

        except Exception as e:
            logging.exception(f"An unexpected error occurred during the scan: {str(e)}")

    async def _scan_file_metadata(self, file_path):
        relative_path = os.path.relpath(file_path, self.gcodes_root)
        encoded_path = quote(relative_path)
        url = f"{self.moonraker_url}/server/files/metascan"

        try:
            data = {"filename": encoded_path}
            result = await self.server.make_request("POST", url, json=data)
            logging.info(f"Successfully scanned metadata for {relative_path}")
            return True
        except self.server.error as e:
            logging.error(f"Error scanning metadata for {relative_path}: {str(e)}")
            return False

    async def _walk_directory(self, directory):
        for root, dirs, files in os.walk(directory):
            if '.thumbs' in dirs:
                dirs.remove('.thumbs')
            for file in files:
                if file.lower().endswith(('.gcode', '.g', '.gco')):
                    full_path = os.path.join(root, file)
                    logging.info(f"Found file: {full_path}")
                    yield full_path
            await asyncio.sleep(0.1)  # Allow other tasks to run


def load_component(config):
    return ListerPrintables(config)