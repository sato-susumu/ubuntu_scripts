#!/bin/bash

# CAN0インターフェースを有効化する（250kbps）
# 対応デバイス:
#   CANable2 Geschwister Schneider (VID 1d50:606f) - gs_usbモード
#   CANable2 Openlight Labs        (VID 16d0:117e) - slcanモード（slcand経由）

set -e

SERVICE_FILE="/etc/systemd/system/can0.service"
SLCAND_SERVICE_FILE="/etc/systemd/system/slcand-can0.service"
SLCAND_START_SCRIPT="/usr/local/bin/slcand-can0-start.sh"
UDEV_RULE_GESCHWISTER="/etc/udev/rules.d/99-canable2.rules"
UDEV_RULE_OPENLIGHT="/etc/udev/rules.d/99-canable2-openlight.rules"

echo "=== CAN0インターフェース 有効化スクリプト ==="
echo

# can0インターフェースの存在確認
if [ ! -e /sys/class/net/can0 ]; then
    echo "【警告】can0インターフェースが見つかりません。"
    echo "CANアダプタが接続されていない可能性があります。"
    echo "サービスは作成しますが、can0が存在しない場合は自動でスキップされます。"
    echo
fi

if [ -f "$SERVICE_FILE" ]; then
    echo "既存のサービスファイルが見つかりました: $SERVICE_FILE"
    echo "内容:"
    cat "$SERVICE_FILE"
    echo
    echo "【サービス状態】"
    sudo systemctl status can0.service --no-pager || true
    echo
    echo "既に設定済みです。再設定する場合は先に disable_can0.sh を実行してください。"
else
    # --- udevルール ---
    echo "【udevルールを作成】"

    sudo tee "$UDEV_RULE_GESCHWISTER" > /dev/null << 'EOF'
# CANable2 (Geschwister Schneider) gs_usb mode -> /dev/ttyCAN0
SUBSYSTEM=="tty", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="606f", SYMLINK+="ttyCAN0", TAG+="systemd"
EOF
    echo "作成完了: $UDEV_RULE_GESCHWISTER"

    sudo tee "$UDEV_RULE_OPENLIGHT" > /dev/null << 'EOF'
# CANable2 (Openlight Labs) slcan mode -> /dev/ttyCAN0
SUBSYSTEM=="tty", ATTRS{idVendor}=="16d0", ATTRS{idProduct}=="117e", SYMLINK+="ttyCAN0", TAG+="systemd"
EOF
    echo "作成完了: $UDEV_RULE_OPENLIGHT"

    sudo udevadm control --reload-rules
    echo "udevルール 再読み込み完了"
    echo

    # --- slcand起動スクリプト（Openlight Labsのときのみslcandを起動）---
    echo "【slcand起動スクリプトを作成】"
    sudo tee "$SLCAND_START_SCRIPT" > /dev/null << 'EOF'
#!/bin/bash
# 接続されているCANable2がslcanモード（16d0:117e）のときのみslcandを起動する
VID=$(cat /sys/bus/usb/devices/*/idVendor 2>/dev/null | grep -x '16d0')
if [ -z "$VID" ]; then
    # gs_usbモードのデバイスのみ接続中 -> slcand不要
    echo "gs_usb device detected, skipping slcand" >&2
    exit 0
fi
exec /usr/bin/slcand -o -s5 -t hw -S 3000000 /dev/ttyCAN0 can0
EOF
    sudo chmod +x "$SLCAND_START_SCRIPT"
    echo "作成完了: $SLCAND_START_SCRIPT"
    echo

    # --- slcand-can0.service ---
    echo "【slcand-can0.service を作成】"
    sudo tee "$SLCAND_SERVICE_FILE" > /dev/null << 'EOF'
[Unit]
Description=slcand bridge for CANable2 slcan mode (ttyCAN0 -> can0)
After=dev-ttyCAN0.device
BindsTo=dev-ttyCAN0.device

[Service]
Type=forking
ExecStart=/usr/local/bin/slcand-can0-start.sh
ExecStartPost=/usr/sbin/ip link set can0 up
Restart=on-failure
RestartSec=3

[Install]
WantedBy=dev-ttyCAN0.device
EOF
    echo "作成完了: $SLCAND_SERVICE_FILE"
    echo

    # --- can0.service ---
    echo "【can0.service を作成】"
    sudo tee "$SERVICE_FILE" > /dev/null << 'EOF'
[Unit]
Description=Set up CAN interface can0 (250k)
After=sys-subsystem-net-devices-can0.device
BindsTo=sys-subsystem-net-devices-can0.device

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/sh -c 'pgrep -f "slcand.*can0" > /dev/null && exit 0; /usr/sbin/ip link set can0 up type can bitrate 250000'
ExecStop=/usr/sbin/ip link set can0 down

[Install]
WantedBy=sys-subsystem-net-devices-can0.device
EOF
    echo "作成完了: $SERVICE_FILE"
    echo

    echo "【systemdを再読み込み】"
    sudo systemctl daemon-reload
    echo "daemon-reload 完了"
    echo

    echo "【サービスを有効化】"
    sudo systemctl enable slcand-can0.service
    sudo systemctl enable can0.service
    echo "有効化完了"
    echo

    echo "【slcand-can0.service を起動】"
    sudo systemctl start slcand-can0.service || true
    echo

    echo "=== 設定完了 ==="
fi

echo
echo "【サービス状態】"
sudo systemctl status slcand-can0.service --no-pager || true
echo
sudo systemctl status can0.service --no-pager || true
echo

if [ -e /sys/class/net/can0 ]; then
    echo "【CAN0インターフェース詳細】"
    ip -details link show can0
else
    echo "【注意】can0インターフェースが存在しないため、詳細は表示できません。"
fi
echo

echo "解除するには: ./disable_can0.sh を実行してください。"
