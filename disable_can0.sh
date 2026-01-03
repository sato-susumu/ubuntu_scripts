#!/bin/bash

# CAN0インターフェースの自動設定を無効化する
# systemdサービスを停止・削除

set -e

SERVICE_FILE="/etc/systemd/system/can0.service"

echo "=== CAN0インターフェース 無効化スクリプト ==="
echo

if [ -f "$SERVICE_FILE" ]; then
    echo "【現在のサービス状態】"
    sudo systemctl status can0.service --no-pager || true
    echo

    echo "【サービスを停止・無効化】"
    sudo systemctl disable --now can0.service || true
    echo "停止・無効化 完了"
    echo

    echo "【サービスファイルを削除】"
    echo "削除するファイル: $SERVICE_FILE"
    sudo rm "$SERVICE_FILE"
    echo "削除完了"
    echo

    echo "【systemdを再読み込み】"
    sudo systemctl daemon-reload
    echo "daemon-reload 完了"
    echo

    echo "=== 無効化完了 ==="
    echo "CAN0の自動設定を無効化しました。"
else
    echo "サービスファイルが見つかりません: $SERVICE_FILE"
    echo "CAN0の自動設定は適用されていません。"
fi
echo

if [ -e /sys/class/net/can0 ]; then
    echo "【CAN0インターフェース状態】"
    ip -details link show can0
fi
echo

echo "再度有効化するには: ./enable_can0.sh を実行してください。"
