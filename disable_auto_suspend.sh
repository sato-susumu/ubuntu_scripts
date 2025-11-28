#!/bin/bash

# Disable automatic suspend for both AC and battery power

set -e

echo "Disabling automatic suspend..."

# Disable suspend on AC power
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'

# Disable suspend on battery power
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'

echo ""
echo "Automatic suspend disabled successfully!"
echo ""
echo "Current settings:"
echo "  AC power:      $(gsettings get org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type)"
echo "  Battery power: $(gsettings get org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type)"
