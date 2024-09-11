#!/bin/bash
# File: /home/pi/lister_printables/scripts/setup_one_time_cron.sh

METADATA_SCRIPT="/home/pi/lister_printables/scripts/update_lister_metadata.py"

# Remove any existing cron jobs for our script
crontab -l | grep -v "$METADATA_SCRIPT" | crontab -

# Remove any existing cron jobs that were set to remove themselves
crontab -l | grep -v "crontab -r" | crontab -

# Calculate the next minute
NEXT_MINUTE=$(($(date +%M) + 1))
NEXT_MINUTE=$((NEXT_MINUTE % 60))

# Add the new cron job
(crontab -l ; echo "$NEXT_MINUTE * * * * (sleep 30 && python3 $METADATA_SCRIPT) && (crontab -l | grep -v '$METADATA_SCRIPT' | crontab -)") | crontab -

echo "One-time cron job set up successfully. Metadata scan will run in about 90 seconds."