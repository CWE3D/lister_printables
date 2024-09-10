#!/bin/bash

# File: /home/pi/lister_printables/scripts/setup_one_time_cron.sh

METADATA_SCRIPT="/home/pi/printer_data/config/lister_scripts/update_lister_metadata.py"

# Remove any existing cron jobs for our script
crontab -l | grep -v "$METADATA_SCRIPT" | crontab -

# Calculate the next minute
NEXT_MINUTE=$(($(date +%M) + 1))
NEXT_MINUTE=$((NEXT_MINUTE % 60))

# Add the new cron job
(crontab -l ; echo "$NEXT_MINUTE * * * * (sleep 30 && python3 $METADATA_SCRIPT) && (crontab -r)") | crontab -

echo "One-time cron job set up successfully. Metadata scan will run in about 90 seconds."

touch /home/pi/printer_data/logs/lister_printables_cron_created.log