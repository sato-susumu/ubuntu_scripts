#!/bin/bash

BACKUP_PATH="/etc/pam.d/gdm-password.backup"

if [ -f "/etc/pam.d/gdm-password" ]; then
    # バックアップを作成
    echo "gdm-passwordファイルのバックアップを作成しています..."
    sudo cp /etc/pam.d/gdm-password ${BACKUP_PATH}

    # pam_gnome_keyring.soを含む行をコメントアウト
    echo "pam_gnome_keyring.soを含む行をコメントアウトしています..."
    sudo sed -i '/pam_gnome_keyring.so/s/^/#/' /etc/pam.d/gdm-password

    echo "完了しました。変更を有効にするにはシステムを再起動してください。"
else
    echo "/etc/pam.d/gdm-passwordファイルが存在しません。GNOMEがインストールされていることを確認してください。"
fi
