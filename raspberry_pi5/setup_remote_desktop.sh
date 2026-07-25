#!/usr/bin/env bash
#
# setup_remote_desktop.sh
#
# ============================================================================
#  ⚠️ 未検証の注意
#  このスクリプトは動作確認(実行テスト)を行っていません。
#  稼働中の 1 台で手作業で確立した設定を「初期 OS からの手順」としてスクリプト化
#  したものであり、クリーンな OS 上での通し実行は未検証です(構文チェック bash -n のみ実施)。
#  利用する場合は内容を確認のうえ自己責任で、できればテスト機や SSH で復旧できる
#  状態で実行してください。
# ============================================================================
#
# Raspberry Pi 5 (Ubuntu 26.04 + GNOME/Wayland, ヘッドレス) を、
# 自動ログインを維持したまま RDP で接続できるようにセットアップするスクリプト。
#
# 採用方式: gnome-remote-desktop の --headless モード
#           (自動ログイン中のセッションをヘッドレス共有 / 認証情報はキーファイル保存)
#
# 使い方:
#   通常ユーザー(root ではない)で実行:  ./setup_remote_desktop.sh
#   RDP パスワードは実行中に対話入力します(スクリプトには記載しません)。
#
set -euo pipefail

# ---------------------------------------------------------------------------
# 0. 前提チェック
# ---------------------------------------------------------------------------
if [[ "${EUID}" -eq 0 ]]; then
  echo "エラー: root ではなく、RDP で使う通常ユーザーで実行してください。" >&2
  echo "        (内部で必要な箇所だけ sudo を使います)" >&2
  exit 1
fi

TARGET_USER="$(id -un)"
UID_NUM="$(id -u)"
RDP_PORT="${RDP_PORT:-3389}"
CERT_DIR="${HOME}/.local/share/gnome-remote-desktop"
CERT_CRT="${CERT_DIR}/tls.crt"
CERT_KEY="${CERT_DIR}/tls.key"
GDM_CONF="/etc/gdm3/custom.conf"

# ユーザー D-Bus / systemd --user を SSH からでも使えるように補完
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/${UID_NUM}}"
if [[ -z "${DBUS_SESSION_BUS_ADDRESS:-}" && -S "/run/user/${UID_NUM}/bus" ]]; then
  export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${UID_NUM}/bus"
fi

echo "=============================================================="
echo " Raspberry Pi リモートデスクトップ(RDP) セットアップ"
echo "   対象ユーザー : ${TARGET_USER}"
echo "   ポート       : ${RDP_PORT}"
echo "=============================================================="

# sudo を先に一度通しておく
echo "-- 管理者権限が必要な操作があります。sudo のパスワードを求められる場合があります。"
sudo -v

# ---------------------------------------------------------------------------
# 1. 必要パッケージの導入
# ---------------------------------------------------------------------------
echo "-- [1/7] 必要パッケージを確認・インストール"
sudo apt-get update -y
sudo apt-get install -y gnome-remote-desktop openssl

if ! command -v grdctl >/dev/null 2>&1; then
  echo "エラー: grdctl が見つかりません。GNOME デスクトップ環境がインストールされているか確認してください。" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# 2. RDP パスワードの対話入力
# ---------------------------------------------------------------------------
echo "-- [2/7] RDP パスワードの設定"
RDP_PASS=""
RDP_PASS2=""
while : ; do
  read -rsp "RDP 接続用パスワードを入力: " RDP_PASS; echo
  read -rsp "確認のためもう一度入力  : " RDP_PASS2; echo
  if [[ -z "${RDP_PASS}" ]]; then
    echo "  空のパスワードは設定できません。再入力してください。"; continue
  fi
  if [[ "${RDP_PASS}" != "${RDP_PASS2}" ]]; then
    echo "  一致しません。再入力してください。"; continue
  fi
  break
done

# ---------------------------------------------------------------------------
# 3. 自己署名 TLS 証明書 (既存があれば再利用)
# ---------------------------------------------------------------------------
echo "-- [3/7] TLS 証明書の準備"
mkdir -p "${CERT_DIR}"
if [[ -f "${CERT_CRT}" && -f "${CERT_KEY}" ]]; then
  echo "  既存の証明書を再利用します: ${CERT_CRT}"
  echo "  (証明書を作り直すと Windows 側で 0x907 '予期しない証明書' が出るため、既存を優先)"
else
  echo "  自己署名証明書を生成します..."
  openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
    -subj "/CN=$(hostname)" \
    -out "${CERT_CRT}" -keyout "${CERT_KEY}"
fi
chmod 600 "${CERT_KEY}"
chmod 644 "${CERT_CRT}"

# ---------------------------------------------------------------------------
# 4. 競合サービスの無効化 (ポート 3389 の衝突回避)
# ---------------------------------------------------------------------------
echo "-- [4/7] 競合する RDP サービスを無効化"
# --system (リモートログイン) モード
sudo grdctl --system rdp disable 2>/dev/null || true
sudo systemctl disable --now gnome-remote-desktop.service 2>/dev/null || true
# 通常ユーザー (画面共有) モード
systemctl --user disable --now gnome-remote-desktop.service 2>/dev/null || true

# ---------------------------------------------------------------------------
# 5. gnome-remote-desktop を --headless モードで構成
# ---------------------------------------------------------------------------
echo "-- [5/7] gnome-remote-desktop (--headless) を構成"
# ※ "Init TPM credentials failed ... using GKeyFile as fallback" は正常(TPM 非搭載機)
grdctl --headless rdp set-tls-cert "${CERT_CRT}"
grdctl --headless rdp set-tls-key  "${CERT_KEY}"
grdctl --headless rdp set-credentials "${TARGET_USER}" "${RDP_PASS}"
grdctl --headless rdp disable-view-only   # 遠隔からの操作(入力)を許可
[[ "${RDP_PORT}" != "3389" ]] && grdctl --headless rdp set-port "${RDP_PORT}" || true
grdctl --headless rdp enable

# 自動ログインの GNOME セッションと一緒に起動するように有効化
systemctl --user enable gnome-remote-desktop-headless.service
# ユーザーがログインしていなくても user manager を保持(保険)
sudo loginctl enable-linger "${TARGET_USER}" 2>/dev/null || true

# 入力に使ったパスワード変数はクリア
unset RDP_PASS RDP_PASS2

# ---------------------------------------------------------------------------
# 6. GDM 自動ログインの有効化
# ---------------------------------------------------------------------------
echo "-- [6/7] GDM 自動ログインを有効化 (${TARGET_USER})"
if [[ -f "${GDM_CONF}" ]]; then
  sudo cp -n "${GDM_CONF}" "${GDM_CONF}.orig" 2>/dev/null || true
  sudo cp "${GDM_CONF}" "${GDM_CONF}.bak.$(date +%Y%m%d%H%M%S)"
else
  echo -e "[daemon]" | sudo tee "${GDM_CONF}" >/dev/null
fi
# [daemon] セクションが無ければ追加
if ! grep -qE '^\[daemon\]' "${GDM_CONF}"; then
  echo -e "\n[daemon]" | sudo tee -a "${GDM_CONF}" >/dev/null
fi
# 既存の(有効な)自動ログイン行を除去してから、[daemon] 直後に挿入
sudo sed -i -E '/^[[:space:]]*AutomaticLoginEnable[[:space:]]*=/d; /^[[:space:]]*AutomaticLogin[[:space:]]*=/d' "${GDM_CONF}"
sudo sed -i "/^\[daemon\]/a AutomaticLoginEnable = true\nAutomaticLogin = ${TARGET_USER}" "${GDM_CONF}"
echo "  現在の設定:"
grep -E '^[[:space:]]*AutomaticLogin' "${GDM_CONF}" | sed 's/^/    /'

# ---------------------------------------------------------------------------
# 7. 画面の自動ロック / スクリーンセーバーを無効化
#    (ロック中は mutter が "Session creation inhibited" を返し RDP が開始できない)
# ---------------------------------------------------------------------------
echo "-- [7/7] 画面の自動ロック / アイドルを無効化"
gsettings set org.gnome.desktop.screensaver lock-enabled false            || true
gsettings set org.gnome.desktop.screensaver idle-activation-enabled false || true
gsettings set org.gnome.desktop.session idle-delay 0                      || true

# ---------------------------------------------------------------------------
# 完了・サマリ
# ---------------------------------------------------------------------------
IP_LIST="$(hostname -I 2>/dev/null | tr ' ' '\n' | grep -E '^(10|172|192)\.' | paste -sd' ' -)"
cat <<EOF

==============================================================
 セットアップ完了
--------------------------------------------------------------
  接続先        : $(hostname)  (IP: ${IP_LIST:-確認してください})
  ユーザー名    : ${TARGET_USER}
  パスワード    : (先ほど入力した値)
  ポート        : ${RDP_PORT}
  証明書        : ${CERT_CRT}
--------------------------------------------------------------
 Windows からは「リモートデスクトップ接続」で上記に接続。
 初回の自己署名証明書の警告は「はい」で続行してください。
==============================================================

設定を反映するには GNOME セッションの再起動(自動ログインの再発火)が必要です。
EOF

read -rp "今すぐ GDM を再起動して反映しますか? 現在の GUI セッションは一旦終了します (SSH は影響なし) [y/N]: " ANS
if [[ "${ANS}" =~ ^[Yy]$ ]]; then
  echo "GDM を再起動します..."
  sudo systemctl restart gdm.service
  echo "完了。数十秒後に自動ログイン → RDP 接続が可能になります。"
else
  echo "後で反映する場合は次を実行してください: sudo systemctl restart gdm.service"
  echo "(または本体を再起動)"
fi
