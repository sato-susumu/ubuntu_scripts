#!/bin/bash
# Setup AMD P-State EPP balance_power service
# This script creates a systemd service that sets EPP to balance_power on boot.
# Safe to run on Intel PCs (will be skipped).
#
# WARNING: This script has not been fully tested. Use at your own risk.

set -e

SERVICE_FILE="/etc/systemd/system/amd-epp-balance-power.service"

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root (sudo)"
    exit 1
fi

cat > "$SERVICE_FILE" << 'EOF'
[Unit]
Description=Set AMD P-State EPP to balance_power
After=multi-user.target
ConditionPathExists=/sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'grep -q amd-pstate /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver 2>/dev/null && echo balance_power | tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference || true'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable amd-epp-balance-power.service
systemctl start amd-epp-balance-power.service

echo "Done. AMD EPP balance_power service installed and started."
echo ""
echo "Current EPP:"
cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference 2>/dev/null || echo "N/A (not AMD P-State)"
