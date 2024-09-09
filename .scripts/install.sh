#!/bin/bash

# Exit if any command fails
set -e

# Navigate to the plugin directory
cd /home/pi/printer_data/gcodes/lister_printables

# Install Python requirements
pip3 install -r requirements.txt

# Make the script executable
chmod +x /home/pi/printer_data/gcodes/lister_printables/.scripts/update_lister_metadata.py

echo "Lister printables plugin installed successfully!"
EOF