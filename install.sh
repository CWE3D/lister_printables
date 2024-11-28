#!/bin/bash

set -e

REPO_URL="https://github.com/CWE3D/lister_printables.git"
INSTALL_DIR="/home/pi/printer_data/gcodes/lister_printables"
SCRIPTS_DIR="$INSTALL_DIR/scripts"
LOG_DIR="/home/pi/printer_data/logs"
INSTALL_LOG="$LOG_DIR/lister_printables_install.log"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to log messages with severity
log_message() {
    local severity=$1
    local message=$2
    local color=$GREEN
    
    case $severity in
        "ERROR") color=$RED ;;
        "WARN") color=$YELLOW ;;
        *) color=$GREEN ;;
    esac
    
    echo -e "${color}$(date): [$severity] $message${NC}" | tee -a "$INSTALL_LOG"
}

# Function to check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_message "ERROR" "Please run as root (sudo)"
        exit 1
    fi
}

# Function to fix permissions
fix_permissions() {
    log_message "INFO" "Fixing permissions for installation"
    
    if [ -d "$INSTALL_DIR" ]; then
        # Fix owner and group recursively
        chown -R pi:pi "$INSTALL_DIR"
        
        # Fix directory permissions
        find "$INSTALL_DIR" -type d -exec chmod 755 {} \;
        
        # Reset all file permissions to 644 first
        find "$INSTALL_DIR" -type f -exec chmod 644 {} \;
        
        # Let git set the correct executable bits based on .gitattributes
        if [ -d "$INSTALL_DIR/.git" ]; then
            (cd "$INSTALL_DIR" && git diff --quiet || {
                git reset --hard
                git config core.fileMode true
                git checkout --force HEAD
            })
        fi
    fi

    # Fix log directory permissions
    log_message "INFO" "Fixing permissions for log directory"
    chown -R pi:pi "$LOG_DIR"
    chmod 755 "$LOG_DIR"
}

# Main installation process
main() {
    check_root

    # Create log directory if it doesn't exist
    mkdir -p "$LOG_DIR"

    log_message "INFO" "Starting Lister Printables plugin installation/update"

    # Install Git LFS
    log_message "INFO" "Installing Git LFS"
    apt-get update
    apt-get install -y git-lfs

    # Check if the directory exists
    if [ -d "$INSTALL_DIR" ]; then
        log_message "INFO" "Lister Printables directory exists. Updating..."
        cd "$INSTALL_DIR"
        
        git lfs install
        
        log_message "INFO" "Fetching LFS files..."
        git lfs fetch --all
        git lfs checkout
        
        git reset --hard
        git clean -fd
        git pull --force origin main
        log_message "INFO" "Update completed"
    else
        log_message "INFO" "Lister Printables directory does not exist. Cloning repository..."
        git lfs install
        git clone "$REPO_URL" "$INSTALL_DIR"
        log_message "INFO" "Clone completed"
    fi

    # Navigate to the plugin directory
    cd "$INSTALL_DIR"

    # Fix permissions after repository operations
    fix_permissions

    # Install Python requirements
    log_message "INFO" "Installing Python requirements"
    pip3 install -r requirements.txt

    # Setup cron job
    log_message "INFO" "Setting up cron job"
    python3 "$SCRIPTS_DIR/setup_one_time_cron.py"

    # Trigger immediate metadata scan
    log_message "INFO" "Triggering initial metadata scan"
    python3 "$SCRIPTS_DIR/update_lister_metadata.py"

    # Mark installation as complete
    touch "$LOG_DIR/lister_printables_installed.log"

    # Final permission check
    fix_permissions

    log_message "INFO" "Lister printables plugin installed/updated successfully!"
}

# Run the installation
main