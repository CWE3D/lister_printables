#!/bin/bash

PLUGIN_DIR="/home/pi/lister_printables"
GCODES_DIR="/home/pi/printer_data/gcodes/lister_printables"
SCRIPTS_DIR="$PLUGIN_DIR/scripts"
INSTALL_LOG="/home/pi/printer_data/logs/lister_printables_installing.log"
COMPLETE_LOG="/home/pi/printer_data/logs/lister_printables_installed.log"
VERSION_FILE="$PLUGIN_DIR/version.txt"

# Start installation/update
echo "Starting Lister Printables plugin installation/update at $(date)" > "$INSTALL_LOG"

# Check if this is a new installation or an update
if [ -f "$VERSION_FILE" ]; then
    OLD_VERSION=$(cat "$VERSION_FILE")
else
    OLD_VERSION="0.0.0"
fi

# Get new version (this assumes you maintain a version.txt in your repo)
NEW_VERSION=$(cat "$PLUGIN_DIR/version.txt")

echo "Old version: $OLD_VERSION" >> "$INSTALL_LOG"
echo "New version: $NEW_VERSION" >> "$INSTALL_LOG"

# Perform installation/update steps
mkdir -p "$GCODES_DIR"

echo "Syncing gcode files..." >> "$INSTALL_LOG"
rsync -av --delete "$PLUGIN_DIR/gcodes/" "$GCODES_DIR/" >> "$INSTALL_LOG" 2>&1

echo "Making scripts executable..." >> "$INSTALL_LOG"
chmod +x "$PLUGIN_DIR"/*.sh
chmod +x "$SCRIPTS_DIR"/*.py

# Run the one-time cron setup
echo "Setting up one-time cron job..." >> "$INSTALL_LOG"
bash "$SCRIPTS_DIR/setup_one_time_cron.sh" >> "$INSTALL_LOG" 2>&1

# Update version file
echo "$NEW_VERSION" > "$VERSION_FILE"

echo "Lister printables plugin installed/updated successfully!" | tee -a "$INSTALL_LOG" "$COMPLETE_LOG"
echo "Installation/update completed at $(date)" >> "$COMPLETE_LOG"