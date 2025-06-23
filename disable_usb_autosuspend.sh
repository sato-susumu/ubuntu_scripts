#!/bin/bash

echo "=== USB自動サスペンド無効化スクリプト ==="
echo

if [ "$EUID" -ne 0 ]; then
    echo "このスクリプトはroot権限で実行する必要があります。"
    echo "sudo $0 で実行してください。"
    exit 1
fi

echo "【現在の設定確認】"
current_value=$(cat /sys/module/usbcore/parameters/autosuspend)
echo "現在の設定値: $current_value"

if grep -q "usbcore.autosuspend=-1" /etc/default/grub; then
    echo "恒久設定: 既に設定済み"
else
    echo "恒久設定: 未設定"
fi
echo

echo "【一時的な無効化 (即座に有効)】"
echo -1 > /sys/module/usbcore/parameters/autosuspend
new_value=$(cat /sys/module/usbcore/parameters/autosuspend)
echo "設定完了: $new_value"
echo

echo "【恒久的な無効化 (再起動後も有効)】"
if grep -q "usbcore.autosuspend=-1" /etc/default/grub; then
    echo "既にGRUB設定済みです。"
else
    echo "GRUB設定をバックアップしています..."
    cp /etc/default/grub /etc/default/grub.backup.$(date +%Y%m%d_%H%M%S)
    
    echo "GRUB設定を更新しています..."
    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="usbcore.autosuspend=-1 /' /etc/default/grub
    
    echo "GRUB設定を再生成しています..."
    update-grub
    
    echo "恒久設定完了: 次回再起動時から有効"
fi

echo
echo "=== 設定完了 ==="
echo "現在のセッション: USB自動サスペンド無効"
echo "次回再起動後: USB自動サスペンド無効"
echo
echo "設定を確認するには: ./check_usb_autosuspend.sh を実行してください"