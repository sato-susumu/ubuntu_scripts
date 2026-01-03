#!/bin/bash

# CAN0インターフェースを有効化する（250kbps）
# systemdサービスを作成して起動時に自動でcan0を設定

set -e

SERVICE_FILE="/etc/systemd/system/can0.service"

echo "=== CAN0インターフェース 有効化スクリプト ==="
echo

# can0インターフェースの存在確認
if [ ! -e /sys/class/net/can0 ]; then
    echo "【警告】can0インターフェースが見つかりません。"
    echo "CANアダプタが接続されていない可能性があります。"
    echo "サービスは作成しますが、can0が存在しない場合は自動でスキップされます。"
    echo
fi

if [ -f "$SERVICE_FILE" ]; then
    echo "既存のサービスファイルが見つかりました: $SERVICE_FILE"
    echo "内容:"
    cat "$SERVICE_FILE"
    echo
    echo "【サービス状態】"
    sudo systemctl status can0.service --no-pager || true
    echo
    echo "既に設定済みです。再設定する場合は先に disable_can0.sh を実行してください。"
else
    echo "【systemdサービスを作成】"
    sudo tee "$SERVICE_FILE" > /dev/null << 'EOF'
[Unit]
Description=Set up CAN interface can0 (250k)
# can0 が無いマシンでは自動でスキップ
ConditionPathExists=/sys/class/net/can0

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/sbin/ip link set can0 up type can bitrate 250000
ExecStop=/usr/sbin/ip link set can0 down

[Install]
WantedBy=multi-user.target
EOF
    echo "作成完了: $SERVICE_FILE"
    cat "$SERVICE_FILE"
    echo

    echo "【systemdを再読み込み】"
    sudo systemctl daemon-reload
    echo "daemon-reload 完了"
    echo

    echo "【サービスを有効化・起動】"
    sudo systemctl enable --now can0.service
    echo "有効化・起動 完了"
    echo

    echo "=== 設定完了 ==="
fi

echo
echo "【サービス状態】"
sudo systemctl status can0.service --no-pager || true
echo

if [ -e /sys/class/net/can0 ]; then
    echo "【CAN0インターフェース詳細】"
    ip -details link show can0
else
    echo "【注意】can0インターフェースが存在しないため、詳細は表示できません。"
fi
echo

echo "解除するには: ./disable_can0.sh を実行してください。"
