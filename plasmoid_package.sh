#!/bin/bash
# Package plasmoid for KDE Store

# The script must always be ran at its location
cd "$(dirname "$0")" || exit

# Remove existing package
file="thermalmonitor.plasmoid"
if [ -f $file ]; then
    rm $file
fi

# Check we can actually zip... (using zip)
if ! command -v zip &> /dev/null; then
    exit 1
fi

zip -r $file package

exit 0
