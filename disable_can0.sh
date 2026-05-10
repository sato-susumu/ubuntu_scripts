#!/bin/bash

# CAN0インターフェースの自動設定を無効化する
# systemdサービス・スクリプト・udevルールをすべて停止・削除

set -e

SERVICE_FILE="/etc/systemd/system/can0.service"
SLCAND_SERVICE_FILE="/etc/systemd/system/slcand-can0.service"
SLCAND_START_SCRIPT="/usr/local/bin/slcand-can0-start.sh"
UDEV_RULE_GESCHWISTER="/etc/udev/rules.d/99-canable2.rules"
UDEV_RULE_OPENLIGHT="/etc/udev/rules.d/99-canable2-openlight.rules"

echo "=== CAN0インターフェース 無効化スクリプト ==="
echo

# --- サービスの停止・無効化・削除 ---
for svc in can0.service slcand-can0.service; do
    svc_file="/etc/systemd/system/$svc"
    if [ -f "$svc_file" ]; then
        echo "【$svc を停止・無効化】"
        sudo systemctl disable --now "$svc" || true
        sudo rm "$svc_file"
        echo "削除完了: $svc_file"
        echo
    else
        echo "$svc のサービスファイルが見つかりません（スキップ）"
    fi
done

# --- スクリプトの削除 ---
if [ -f "$SLCAND_START_SCRIPT" ]; then
    sudo rm "$SLCAND_START_SCRIPT"
    echo "削除完了: $SLCAND_START_SCRIPT"
fi
echo

# --- udevルールの削除 ---
echo "【udevルールを削除】"
for rule in "$UDEV_RULE_GESCHWISTER" "$UDEV_RULE_OPENLIGHT"; do
    if [ -f "$rule" ]; then
        sudo rm "$rule"
        echo "削除完了: $rule"
    else
        echo "見つかりません（スキップ）: $rule"
    fi
done
sudo udevadm control --reload-rules
echo "udevルール 再読み込み完了"
echo

echo "【systemdを再読み込み】"
sudo systemctl daemon-reload
echo "daemon-reload 完了"
echo

echo "=== 無効化完了 ==="
echo "CAN0の自動設定を無効化しました。"
echo

if [ -e /sys/class/net/can0 ]; then
    echo "【CAN0インターフェース状態】"
    ip -details link show can0
fi
echo

echo "再度有効化するには: ./enable_can0.sh を実行してください。"
