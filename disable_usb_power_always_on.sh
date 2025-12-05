#!/bin/bash

# USB電源管理の常時ON設定を解除する
# udevルールを削除して、デフォルトの電源管理動作に戻す

set -e

RULE_FILE="/etc/udev/rules.d/50-usb-power-always-on.rules"

echo "=== USB電源管理 常時ON設定 解除スクリプト ==="
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
    echo "【udevルールを削除】"
    echo "削除するファイル: $RULE_FILE"
    echo "内容:"
    cat "$RULE_FILE"
    echo

    rm "$RULE_FILE"
    echo "削除完了"
    echo

    echo "【udevルールを再読み込み】"
    udevadm control --reload-rules
    echo "ルール再読み込み完了"
    echo

    echo "【既存デバイスをデフォルトに戻す】"
    for control in /sys/bus/usb/devices/*/power/control; do
        if [ -f "$control" ]; then
            echo 'auto' > "$control" 2>/dev/null || true
        fi
    done
    echo "適用完了"
    echo

    echo "=== 解除完了 ==="
    echo "USB電源管理の常時ON設定を解除しました。"
else
    echo "ルールファイルが見つかりません: $RULE_FILE"
    echo "常時ON設定は適用されていません。"
fi
echo

echo "【現在の状態】"
echo "power/control モード統計:"
cat /sys/bus/usb/devices/*/power/control 2>/dev/null | sort | uniq -c
