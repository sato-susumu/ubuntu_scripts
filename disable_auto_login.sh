#!/bin/bash

backup_file="/etc/gdm3/custom.conf.backup"

original_file="/etc/gdm3/custom.conf"

if [ -f "$backup_file" ]; then
    sudo cp -f "$backup_file" "$original_file"
    echo "バックアップが元に戻されました。"
else
    echo "バックアップファイルが見つかりません。"
fi
