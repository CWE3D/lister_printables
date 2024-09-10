#!/bin/bash

# Exit if any command fails
set -e

# Navigate to the plugin directory
cd /home/pi/printer_data/gcodes/lister_printables

# Ensure pip is available
sudo apt-get update
sudo apt-get install -y python3-pip

# Install Python requirements
pip3 install -r requirements.txt

# Make the scripts executable
chmod +x /home/pi/printer_data/gcodes/lister_printables/.scripts/update_lister_metadata.py
chmod +x /home/pi/printer_data/gcodes/lister_printables/.scripts/setup_one_time_cron.py

touch /home/pi/printer_data/logs/lister_printables_installed.log

echo "Lister printables plugin installed successfully!"