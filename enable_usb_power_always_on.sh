#!/bin/bash

# すべてのUSBデバイスの電源管理を常にON（サスペンド無効）にする
# udevルールを作成して、デバイス接続時に自動的にpower/control=onを設定

set -e

RULE_FILE="/etc/udev/rules.d/50-usb-power-always-on.rules"

echo "=== USB電源管理 常時ON設定スクリプト ==="
echo

if [ "$EUID" -ne 0 ]; then
    echo "このスクリプトはroot権限で実行する必要があります。"
    echo "sudo $0 で実行してください。"
    exit 1
fi

echo "【現在の状態】"
echo "power/control モード統計:"
cat /sys/bus/usb/devices/*/power/control 2>/dev/null | sort | uniq -c
echo

if [ -f "$RULE_FILE" ]; then
    echo "既存のルールファイルが見つかりました: $RULE_FILE"
    echo "内容:"
    cat "$RULE_FILE"
    echo
    echo "既に設定済みです。"
else
    echo "【udevルールを作成】"
    cat > "$RULE_FILE" << 'EOF'
# すべてのUSBデバイスの電源管理を無効化（常にon）
# Created by enable_usb_power_always_on.sh
ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="on"
EOF
    echo "作成完了: $RULE_FILE"
    cat "$RULE_FILE"
    echo

    echo "【udevルールを再読み込み】"
    udevadm control --reload-rules
    echo "ルール再読み込み完了"
    echo

    echo "【既存デバイスに適用】"
    for control in /sys/bus/usb/devices/*/power/control; do
        if [ -f "$control" ]; then
            echo 'on' > "$control" 2>/dev/null || true
        fi
    done
    echo "適用完了"
    echo
fi

echo "【適用後の状態】"
echo "power/control モード統計:"
cat /sys/bus/usb/devices/*/power/control 2>/dev/null | sort | uniq -c
echo

echo "=== 設定完了 ==="
echo "すべてのUSBデバイスが常時ON（サスペンド無効）になりました。"
echo "この設定は再起動後も有効です。"
echo
echo "解除するには: sudo ./disable_usb_power_always_on.sh を実行してください。"
