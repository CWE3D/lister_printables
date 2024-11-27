#!/bin/bash

# Update script for lister_printables plugin.
# Define colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Define paths
REPO_DIR="/home/pi/printer_data/gcodes/lister_printables"
LOG_DIR="/home/pi/printer_data/logs"
UPDATE_LOG="$LOG_DIR/lister_printables_update.log"
SCRIPTS_DIR="$REPO_DIR/scripts"

# Function to log messages
log_message() {
    echo -e "${GREEN}$(date): $1${NC}" | tee -a "$UPDATE_LOG"
}

log_error() {
    echo -e "${RED}$(date): $1${NC}" | tee -a "$UPDATE_LOG"
}

log_warning() {
    echo -e "${YELLOW}$(date): $1${NC}" | tee -a "$UPDATE_LOG"
}

# Function to check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "Please run as root (sudo)"
        exit 1
    fi
}

# Function to update repository
update_repo() {
    log_message "Updating lister printables repository..."

    if [ ! -d "$REPO_DIR" ]; then
        log_message "Repository not found. Cloning..."
        # Initialize Git LFS before cloning
        git lfs install
        git clone https://github.com/CWE3D/lister_printables.git "$REPO_DIR"
    else
        cd "$REPO_DIR" || exit 1
        
        # Initialize Git LFS for this repository
        git lfs install
        
        # Fetch all LFS files
        log_message "Fetching LFS files..."
        git lfs fetch --all
        git lfs checkout
        
        git fetch

        LOCAL=$(git rev-parse @)
        REMOTE=$(git rev-parse @{u})

        if [ "$LOCAL" != "$REMOTE" ]; then
            log_message "Updates found. Pulling changes..."
            git pull
            
            # Fetch and checkout LFS files after pull
            git lfs fetch --all
            git lfs checkout
            
            return 0
        else
            log_message "Already up to date"
            return 1
        fi
    fi
}

# Function to update metadata
update_metadata() {
    log_message "Updating printables metadata..."
    if [ -f "$SCRIPTS_DIR/update_lister_metadata.py" ]; then
        python3 "$SCRIPTS_DIR/update_lister_metadata.py"
    else
        log_error "Metadata update script not found"
        return 1
    fi
}

# Main update process
main() {
    log_message "Starting lister printables update process..."

    check_root

    # Update repository
    if update_repo; then
        # Update metadata if there were repository updates
        update_metadata
    else
        log_message "No updates found. Skipping metadata update."
    fi

    log_message "Update process completed!"

    # Print verification steps
    echo -e "\n${GREEN}Verify the update:${NC}"
    echo -e "1. Check metadata logs: ${YELLOW}tail -f ${LOG_DIR}/lister_printables_metadata.log${NC}"
    echo -e "2. Verify printables directory: ${YELLOW}ls -l ${REPO_DIR}${NC}"
}

# Run the update
main 