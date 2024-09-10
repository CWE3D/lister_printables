#!/usr/bin/env python3

import os
import sys
from crontab import CronTab

METADATA_SCRIPT = "/home/pi/printer_data/gcodes/lister_printables/.scripts/update_lister_metadata.py"


def setup_one_time_cron_job():
    user_cron = CronTab(user='pi')

    # Remove any existing jobs that run our script
    user_cron.remove_all(command=METADATA_SCRIPT)

    # Create a new job
    job = user_cron.new(command=f'(sleep 30 && {sys.executable} {METADATA_SCRIPT}) && (crontab -r -u pi || true)')

    # Set it to run in one minute
    job.minute.on(int((os.times()[4] + 1) % 60))

    # Write the changes
    user_cron.write()


def main():
    setup_one_time_cron_job()
    print("One-time cron job set up successfully. Metadata scan will run in about 30 seconds.")


if __name__ == "__main__":
    main()