#!/bin/bash

sudoers_file="/etc/sudoers"
sudoers_tmp="/tmp/sudoers.tmp"

# 既に設定されているかを確認
if ! grep -q "^%users ALL=(ALL) NOPASSWD: /sbin/shutdown" "$sudoers_file"; then
    # 設定がない場合、sudoersファイルに新しい設定を追加
    echo "%users ALL=(ALL) NOPASSWD: /sbin/shutdown" | sudo tee -a "$sudoers_file" > /dev/null
    echo "Sudoersファイルが編集されました。"
else
    echo "Sudoersファイルにはすでに設定があります。何も変更されませんでした。"
fi
