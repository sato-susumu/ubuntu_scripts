#!/bin/bash

echo "=== USB自動サスペンド設定確認 ==="
echo

echo "【現在の設定値】"
current_value=$(cat /sys/module/usbcore/parameters/autosuspend 2>/dev/null)
if [ "$current_value" = "-1" ]; then
    echo "現在の設定: $current_value (無効化済み)"
else
    echo "現在の設定: $current_value 秒 (有効)"
fi
echo

echo "【GRUB設定確認】"
if grep -q "usbcore.autosuspend=-1" /etc/default/grub 2>/dev/null; then
    echo "恒久設定: 有効 (再起動後も無効化)"
    grub_line=$(grep "GRUB_CMDLINE_LINUX_DEFAULT" /etc/default/grub)
    echo "設定行: $grub_line"
else
    echo "恒久設定: 無効 (再起動後は初期値に戻る)"
fi
echo

echo "【USBデバイス電源制御状況】"
echo "電源制御モード統計:"
cat /sys/bus/usb/devices/*/power/control 2>/dev/null | sort | uniq -c
echo

echo "【最近のUSB切断ログ】"
journalctl --since "1 day ago" | grep -i "usb.*disconnect" | tail -5