#!/bin/bash

PLUGIN_DIR="/home/pi/lister_printables"
GCODES_DIR="/home/pi/printer_data/gcodes/lister_printables"

touch /home/pi/printer_data/logs/lister_printables_installing.log

# Create necessary directories
mkdir -p "$GCODES_DIR"

# Copy gcode files to the gcodes directory
cp -r "$PLUGIN_DIR"/gcodes/* "$GCODES_DIR"

# Run the one-time cron setup
bash "$PLUGIN_DIR/setup_one_time_cron.sh"

echo "Lister printables plugin installed successfully!"

touch /home/pi/printer_data/logs/lister_printables_installed.log