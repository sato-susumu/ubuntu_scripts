#!/bin/bash
# Remove AMD P-State EPP balance_power service
# This script removes the systemd service and restores default EPP.
#
# WARNING: This script has not been fully tested. Use at your own risk.

set -e

SERVICE_FILE="/etc/systemd/system/amd-epp-balance-power.service"

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root (sudo)"
    exit 1
fi

if [[ -f "$SERVICE_FILE" ]]; then
    systemctl stop amd-epp-balance-power.service 2>/dev/null || true
    systemctl disable amd-epp-balance-power.service 2>/dev/null || true
    rm -f "$SERVICE_FILE"
    systemctl daemon-reload
    echo "Service removed."
else
    echo "Service file not found. Nothing to remove."
fi

# Restore EPP to default (balance_performance or performance)
if [[ -f /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference ]]; then
    echo "balance_performance" | tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference > /dev/null
    echo ""
    echo "EPP restored to balance_performance."
    echo "Current EPP:"
    cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference
else
    echo "EPP not available on this system."
fi

echo ""
echo "Done. Reboot to confirm default settings are restored."
