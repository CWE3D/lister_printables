#!/bin/bash

set -e

REPO_URL="https://github.com/CWE3D/lister_printables.git"
INSTALL_DIR="/home/pi/printer_data/gcodes/lister_printables"
SCRIPTS_DIR="$INSTALL_DIR/scripts"
LOG_DIR="/home/pi/printer_data/logs"
INSTALL_LOG="$LOG_DIR/lister_printables_install.log"

# Function to log messages
log_message() {
    echo "$(date): $1" | tee -a "$INSTALL_LOG"
}

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

log_message "Starting Lister Printables plugin installation/update"

# Check if the directory exists
if [ -d "$INSTALL_DIR" ]; then
    log_message "Lister Printables directory exists. Updating..."
    cd "$INSTALL_DIR"
    git pull origin main
    log_message "Update completed"
else
    log_message "Lister Printables directory does not exist. Cloning repository..."
    git clone "$REPO_URL" "$INSTALL_DIR"
    log_message "Clone completed"
fi

# Navigate to the plugin directory
cd "$INSTALL_DIR"

# Install Python requirements
log_message "Installing Python requirements"
pip3 install -r requirements.txt

# Make the scripts executable
log_message "Setting script permissions"
chmod +x "$SCRIPTS_DIR/update_lister_metadata.py"
chmod +x "$SCRIPTS_DIR/setup_cron_job.py"

# Setup cron job
log_message "Setting up cron job"
python3 "$SCRIPTS_DIR/setup_cron_job.py"

# Trigger immediate metadata scan
log_message "Triggering initial metadata scan"
python3 "$SCRIPTS_DIR/update_lister_metadata.py"

# Mark installation as complete
touch "$LOG_DIR/lister_printables_installed.log"

log_message "Lister printables plugin installed/updated successfully!"