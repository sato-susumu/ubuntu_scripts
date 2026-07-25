#!/usr/bin/env bash
#
# setup_sshd.sh — Raspberry Pi 5 (Ubuntu 26.04) SSH サーバー初期セットアップ
#
# 初期状態の OS に openssh-server を導入し、自動起動（socket activation）を
# 有効化して 22 番ポートで待ち受ける状態にする。
# 再実行しても安全（冪等）。
#
# 使い方:
#   bash setup_sshd.sh
#   ※ sudo 権限が必要。パスワードはスクリプトに書かず、sudo が対話的に求める。
#
set -euo pipefail

info()  { echo -e "\e[32m[INFO]\e[0m $*"; }
warn()  { echo -e "\e[33m[WARN]\e[0m $*"; }
error() { echo -e "\e[31m[ERROR]\e[0m $*" >&2; }

# --- 前提チェック -----------------------------------------------------------
if [[ $EUID -eq 0 ]]; then
    error "root で直接実行せず、一般ユーザーから sudo 経由で実行してください。"
    exit 1
fi

if ! command -v apt-get >/dev/null; then
    error "apt-get が見つかりません。Ubuntu/Debian 系専用です。"
    exit 1
fi

info "sudo 権限を確認します（パスワードを求められたら入力してください）..."
sudo -v

# --- openssh-server のインストール ------------------------------------------
if dpkg -s openssh-server >/dev/null 2>&1; then
    info "openssh-server はインストール済みです。スキップします。"
else
    info "openssh-server をインストールします..."
    sudo apt-get update
    sudo apt-get install -y openssh-server
fi

# --- 自動起動の有効化（socket activation 方式） -----------------------------
# Ubuntu 26.04 の OpenSSH は ssh.socket が 22 番を監視し、接続時に sshd を
# 起動する。ssh.service 自体は disabled のままで正常。
info "ssh.socket を有効化・起動します..."
sudo systemctl enable --now ssh.socket

# --- ufw が有効な場合は 22 番を許可（締め出し防止） --------------------------
if command -v ufw >/dev/null && sudo ufw status | grep -qiE '^(Status: active|状態: アクティブ)'; then
    warn "ufw が有効です。SSH (22/tcp) を許可します..."
    sudo ufw allow 22/tcp
else
    info "ufw は無効です（ファイアウォールによるブロックなし）。"
fi

# --- 動作確認 ---------------------------------------------------------------
info "動作確認..."
echo "  ssh.socket enabled : $(systemctl is-enabled ssh.socket)"
echo "  ssh.socket active  : $(systemctl is-active ssh.socket)"

if ss -ltn | grep -qE ':22\s'; then
    info "22 番ポートで待ち受け中です。"
else
    error "22 番ポートが LISTEN していません。'journalctl -u ssh.socket' を確認してください。"
    exit 1
fi

# --- 接続案内 ---------------------------------------------------------------
echo
info "セットアップ完了。他の端末から以下で接続できます:"
for ip in $(hostname -I); do
    # IPv4 のみ案内（IPv6 は一時アドレスで変わりやすいため）
    [[ "$ip" == *:* ]] && continue
    echo "    ssh $(whoami)@$ip"
done
echo "    ssh $(whoami)@$(hostname).local   # mDNS が使える場合"
echo
info "推奨: 公開鍵認証への移行"
echo "    クライアント側で: ssh-copy-id $(whoami)@$(hostname).local"
echo "    鍵登録後にパスワード認証を無効化するなら:"
echo "    echo 'PasswordAuthentication no' | sudo tee /etc/ssh/sshd_config.d/90-local.conf"
echo "    sudo systemctl restart ssh"
