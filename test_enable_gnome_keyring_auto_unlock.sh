#!/bin/bash

# バックアップファイルのパスを設定
BACKUP_PATH="/etc/pam.d/gdm-password.backup"

# バックアップファイルの存在を確認
if [ -f "${BACKUP_PATH}" ]; then
    # 元のファイルにバックアップから復元
    echo "バックアップから/etc/pam.d/gdm-passwordを復元しています..."
    sudo cp ${BACKUP_PATH} /etc/pam.d/gdm-password

    # バックアップファイルを削除
    echo "バックアップファイルを削除しています..."
    sudo rm ${BACKUP_PATH}

    echo "復元が完了しました。変更を有効にするにはシステムを再起動してください。"
else
    echo "バックアップファイルが見つかりません。/etc/pam.d/gdm-password.backupが存在することを確認してください。"
fi
