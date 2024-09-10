#!/bin/bash

PLUGIN_DIR="/home/pi/lister_printables"
GCODES_DIR="/home/pi/printer_data/gcodes/lister_printables"
SCRIPTS_DIR="/home/pi/printer_data/config/lister_scripts"

# Create necessary directories
mkdir -p "$GCODES_DIR"
mkdir -p "$SCRIPTS_DIR"

# Copy gcode files to the gcodes directory
cp -r "$PLUGIN_DIR"/gcodes/* "$GCODES_DIR"

# Copy scripts to the config directory
cp "$PLUGIN_DIR"/scripts/*.py "$SCRIPTS_DIR"
cp "$PLUGIN_DIR"/scripts/*.sh "$SCRIPTS_DIR"

# Make scripts executable
chmod +x "$SCRIPTS_DIR"/*.py
chmod +x "$SCRIPTS_DIR"/*.sh

# Run the one-time cron setup
bash "$SCRIPTS_DIR/setup_one_time_cron.sh"

echo "Lister printables plugin installed successfully!"
touch /home/pi/printer_data/logs/lister_printables_installed.log