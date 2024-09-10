#!/bin/bash

PLUGIN_DIR="/home/pi/lister_printables"
GCODES_DIR="/home/pi/printer_data/gcodes/lister_printables"
SCRIPTS_DIR="$PLUGIN_DIR/scripts"
INSTALL_LOG="/home/pi/printer_data/logs/lister_printables_installing.log"
COMPLETE_LOG="/home/pi/printer_data/logs/lister_printables_installed.log"

# Start installation
echo "Starting Lister Printables plugin installation/update at $(date)" > "$INSTALL_LOG"

# Create necessary directory for gcodes
mkdir -p "$GCODES_DIR"

# Sync gcode files to the gcodes directory
echo "Syncing gcode files..." >> "$INSTALL_LOG"
rsync -av --delete "$PLUGIN_DIR/gcodes/" "$GCODES_DIR/" >> "$INSTALL_LOG" 2>&1

# Make scripts executable
echo "Making scripts executable..." >> "$INSTALL_LOG"
chmod +x "$SCRIPTS_DIR"/*.sh
chmod +x "$SCRIPTS_DIR"/*.py

# Run the one-time cron setup
echo "Setting up one-time cron job..." >> "$INSTALL_LOG"
bash "$SCRIPTS_DIR/setup_one_time_cron.sh" >> "$INSTALL_LOG" 2>&1

echo "Lister printables plugin installed/updated successfully!" | tee -a "$INSTALL_LOG" "$COMPLETE_LOG"
echo "Installation/update completed at $(date)" >> "$COMPLETE_LOG"