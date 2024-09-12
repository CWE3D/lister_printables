# Lister Printables Plugin

## Overview

The Lister Printables plugin is a specialized tool designed exclusively for Lister 3D printers. This plugin enhances your printing experience by providing easy access to the latest sliced gcode files for every part of your Lister printer.

## Key Features

- Automatic updates of printable parts
- Easy access to the latest gcode files
- Regular metadata scans to keep your file information up-to-date
- Seamless integration with your Lister printer's interface

## Purpose

The primary purpose of this plugin is to allow Lister printer users to easily print updated parts as soon as they are released. This ensures that your printer always has access to the most recent improvements and modifications, keeping your Lister printer in optimal condition.

## How It Works

The Lister Printables plugin operates through several key components:

1. **Installation Script**: This script sets up the plugin and its dependencies on your Lister printer.

2. **Cron Job**: The installation process creates a cron job that runs daily. This automated task ensures regular updates and maintenance of the plugin.

3. **Metadata Scanning**: A Python script runs daily to scan all gcode files in the Lister Printables directory. It updates the metadata for each file, which includes information like print time, filament usage, and thumbnail images.

4. **File Management**: The plugin maintains a directory of the latest gcode files for all printable Lister printer parts. These files are regularly updated from the official Lister repository.

5. **Integration with Moonraker**: The plugin interacts with Moonraker (the API for Klipper) to provide seamless access to the printable files through your printer's web interface.

This automated system ensures that your Lister printer always has access to the most up-to-date parts without requiring manual intervention.

## Installation

To install or update the Lister Printables plugin, you can use the following command. This command will work from any computer that has SSH access to your Lister printer.

```bash
ssh pi@printername.local 'bash -s' << EOF
  curl -fsSL https://raw.githubusercontent.com/CWE3D/lister_printables/main/install.sh -o /tmp/install.sh && 
  chmod +x /tmp/install.sh && 
  /tmp/install.sh
EOF