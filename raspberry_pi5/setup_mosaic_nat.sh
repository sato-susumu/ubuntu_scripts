#!/usr/bin/env bash
#
# setup_mosaic_nat.sh — mosaic-go Web UI/全ポートを LAN 内の他 PC へ公開する設定
#
# ※※ 注意: このスクリプトは新規 OS での動作を未確認 ※※
#    2026-07-25 に既存環境 (Ubuntu / NetworkManager 管理) で手動実行した
#    手順をスクリプト化したもの。新規 OS で実行した実績はまだない。
#    実行後は必ず「動作確認」節のチェックが通ることを確認すること。
#
# 概要:
#   Septentrio mosaic-go (USB 接続, 固定 IP 192.168.3.1) はラズパイとの
#   USB ネットワーク内にしか存在しないため、他 PC から直接アクセスできない。
#   本スクリプトは eth0 に専用の第2 IP (192.168.1.77) を追加し、
#   その IP 宛の全ポート (TCP/UDP) を 192.168.3.1 へ DNAT 転送する。
#   他 PC からは http://192.168.1.77 (Web UI) や 192.168.1.77:28784
#   (コマンドポート) で mosaic-go にそのままアクセスできるようになる。
#
# 実装メモ:
#   - IP 追加は nmcli で行い、`netplan apply` は使わない。
#     netplan apply は全インターフェースを再構成するため、wlan0 の
#     再作成と競合してクラッシュした実績あり (2026-07-25)。
#     nmcli の変更は NM の netplan バックエンド経由で自動永続化される。
#   - NAT ルールは systemd サービス (mosaic-nat.service) として登録し、
#     起動時に自動で張られる。
#   - 再実行しても安全（冪等）。
#
# 使い方:
#   bash setup_mosaic_nat.sh
#   ※ sudo 権限が必要。
#
set -euo pipefail

# --- 設定値 -----------------------------------------------------------------
SECONDARY_IP="192.168.1.77"     # 他PCからのアクセス用に eth0 へ追加する IP
TARGET_IP="192.168.3.1"         # mosaic-go の固定 IP
ETH_IF="eth0"                   # LAN 側インターフェース
SERVICE="mosaic-nat.service"

info()  { echo -e "\e[32m[INFO]\e[0m $*"; }
warn()  { echo -e "\e[33m[WARN]\e[0m $*"; }
error() { echo -e "\e[31m[ERROR]\e[0m $*" >&2; }

# --- 前提チェック -----------------------------------------------------------
if [[ $EUID -eq 0 ]]; then
    error "root で直接実行せず、一般ユーザーから sudo 経由で実行してください。"
    exit 1
fi

if ! command -v nmcli >/dev/null; then
    error "nmcli が見つかりません。NetworkManager 管理の環境専用です。"
    exit 1
fi

info "sudo 権限を確認します（パスワードを求められたら入力してください）..."
sudo -v

# --- eth0 の NetworkManager 接続名を特定 ------------------------------------
CON="$(nmcli -t -f NAME,DEVICE con show --active | awk -F: -v d="$ETH_IF" '$2==d{print $1; exit}')"
if [[ -z "$CON" ]]; then
    error "$ETH_IF のアクティブな NetworkManager 接続が見つかりません。"
    exit 1
fi
info "$ETH_IF の接続プロファイル: $CON"

# --- 第2 IP を追加（DHCP との併用） ------------------------------------------
if nmcli -g ipv4.addresses con show "$CON" | grep -q "$SECONDARY_IP"; then
    info "$SECONDARY_IP は接続プロファイルに設定済みです。スキップします。"
else
    info "$CON に $SECONDARY_IP/24 を追加します..."
    sudo nmcli con mod "$CON" +ipv4.addresses "$SECONDARY_IP/24"
    # netplan apply は使わず、対象デバイスのみ再適用する
    sudo nmcli device reapply "$ETH_IF"
fi

# reapply で即時反映されない場合があるため、付いていなければ手動で付与
# （永続化は上の NM プロファイルで担保済み。これは今回限りの即時反映）
if ! ip -4 addr show dev "$ETH_IF" | grep -q "inet $SECONDARY_IP/"; then
    warn "reapply では即時反映されませんでした。ip addr add で付与します..."
    sudo ip addr add "$SECONDARY_IP/24" dev "$ETH_IF"
fi

# --- IP フォワーディングの有効化・永続化 -------------------------------------
info "IPv4 フォワーディングを有効化します..."
echo 'net.ipv4.ip_forward=1' | sudo tee /etc/sysctl.d/99-mosaic-forward.conf >/dev/null
sudo sysctl -q -p /etc/sysctl.d/99-mosaic-forward.conf

# --- NAT ルールの systemd サービスを登録 -------------------------------------
info "$SERVICE を登録します..."
sudo tee "/etc/systemd/system/$SERVICE" >/dev/null <<EOF
[Unit]
Description=NAT: forward all ports on $SECONDARY_IP to mosaic-go ($TARGET_IP)
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/sbin/iptables -w -t nat -A PREROUTING -d $SECONDARY_IP -j DNAT --to-destination $TARGET_IP
ExecStart=/usr/sbin/iptables -w -t nat -A OUTPUT -d $SECONDARY_IP -j DNAT --to-destination $TARGET_IP
ExecStart=/usr/sbin/iptables -w -t nat -A POSTROUTING -d $TARGET_IP -j MASQUERADE
ExecStop=/usr/sbin/iptables -w -t nat -D PREROUTING -d $SECONDARY_IP -j DNAT --to-destination $TARGET_IP
ExecStop=/usr/sbin/iptables -w -t nat -D OUTPUT -d $SECONDARY_IP -j DNAT --to-destination $TARGET_IP
ExecStop=/usr/sbin/iptables -w -t nat -D POSTROUTING -d $TARGET_IP -j MASQUERADE

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable --now "$SERVICE"

# --- 動作確認 ---------------------------------------------------------------
info "動作確認..."
echo "  $SECONDARY_IP on $ETH_IF : $(ip -4 addr show dev "$ETH_IF" | grep -q "inet $SECONDARY_IP/" && echo OK || echo NG)"
echo "  ip_forward               : $(sysctl -n net.ipv4.ip_forward)"
echo "  $SERVICE enabled  : $(systemctl is-enabled "$SERVICE")"
echo "  $SERVICE active   : $(systemctl is-active "$SERVICE")"

# mosaic-go が接続されていれば HTTP 応答を確認（307 リダイレクトが正常応答）
HTTP_CODE="$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 "http://$SECONDARY_IP/" || true)"
if [[ "$HTTP_CODE" != "000" ]]; then
    info "http://$SECONDARY_IP/ から HTTP $HTTP_CODE 応答あり。転送は機能しています。"
else
    warn "http://$SECONDARY_IP/ が応答しません。mosaic-go の USB 接続・電源を確認してください。"
    warn "（mosaic-go 未接続でも本スクリプトの設定自体は完了しています）"
fi

echo
info "セットアップ完了。他の PC から以下でアクセスできます:"
echo "    http://$SECONDARY_IP           # Web UI"
echo "    $SECONDARY_IP:28784            # コマンドポート (全ポート転送済み)"
