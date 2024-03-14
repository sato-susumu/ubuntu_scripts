#!/bin/bash

# 設定がある場合は削除する
if grep -q "^%users ALL=(ALL) NOPASSWD: /sbin/shutdown" /etc/sudoers; then
    sudo visudo -c -q -f /etc/sudoers && \
    sudo sed -i '/^%users ALL=(ALL) NOPASSWD: \/sbin\/shutdown/d' /etc/sudoers && \
    echo "Sudoersファイルの設定が元に戻されました。"
else
    echo "Sudoersファイルに対する変更はありません。"
fi
