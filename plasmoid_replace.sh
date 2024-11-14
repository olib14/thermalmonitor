#!/bin/bash
# Replace installed user plasmoid locally for testing

# The script must always be ran at its location
cd "$(dirname "$0")" || exit

mkdir -p ~/.local/share/plasma/plasmoids/org.kde.olib.thermalmonitor
cp -r package/* ~/.local/share/plasma/plasmoids/org.kde.olib.thermalmonitor
systemctl restart --user plasma-plasmashell.service

exit 0
