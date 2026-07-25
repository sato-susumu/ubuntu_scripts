#!/usr/bin/env bash
#
# setup_gh.sh
#
# ============================================================================
#  ⚠️ 未検証の注意
#  このスクリプトは通し実行での動作確認を行っていません(構文チェック bash -n のみ)。
#  ただしインストール部分は、実機で手作業実行した手順と同じものです。
#  認証部分(gh auth login)は対話操作のため自動テストしていません。
#  利用する場合は内容を確認のうえ、自己責任で実行してください。
# ============================================================================
#
# Raspberry Pi 5 (Ubuntu 26.04, arm64, ヘッドレス) に GitHub CLI (gh) を導入し、
# 使える状態にするスクリプト。
#
#  - git と gh を GitHub 公式 apt リポジトリから導入
#  - 認証(gh auth login)は対話実行(トークン/パスワードはスクリプトに書かない)
#
# 使い方: 通常ユーザー(root ではない)で実行:  ./setup_gh.sh
#
set -euo pipefail

if [[ "${EUID}" -eq 0 ]]; then
  echo "エラー: root ではなく通常ユーザーで実行してください(内部で必要な箇所のみ sudo)。" >&2
  exit 1
fi

KEYRING="/etc/apt/keyrings/githubcli-archive-keyring.gpg"
SRC_LIST="/etc/apt/sources.list.d/github-cli.list"
KEY_URL="https://cli.github.com/packages/githubcli-archive-keyring.gpg"

echo "=============================================================="
echo " GitHub CLI (gh) セットアップ"
echo "=============================================================="
sudo -v

# ---------------------------------------------------------------------------
# 1. 前提パッケージ (git, wget, ca-certificates)
# ---------------------------------------------------------------------------
echo "-- [1/4] 前提パッケージを導入 (git, wget, ca-certificates)"
sudo apt-get update -y
sudo apt-get install -y git wget ca-certificates

# ---------------------------------------------------------------------------
# 2. GitHub 公式 apt リポジトリ (冪等: 既にあれば作り直さない)
# ---------------------------------------------------------------------------
echo "-- [2/4] GitHub CLI 公式 apt リポジトリを設定"
ARCH="$(dpkg --print-architecture)"
if [[ ! -s "${KEYRING}" ]]; then
  sudo mkdir -p -m 755 /etc/apt/keyrings
  tmpkey="$(mktemp)"
  wget -nv -O "${tmpkey}" "${KEY_URL}"
  sudo install -o root -g root -m 644 "${tmpkey}" "${KEYRING}"
  sudo chmod go+r "${KEYRING}"
  rm -f "${tmpkey}"
  echo "   GPG 鍵を導入: ${KEYRING}"
else
  echo "   GPG 鍵は既に存在: ${KEYRING}"
fi

REPO_LINE="deb [arch=${ARCH} signed-by=${KEYRING}] https://cli.github.com/packages stable main"
if [[ ! -f "${SRC_LIST}" ]] || ! grep -qF "cli.github.com/packages" "${SRC_LIST}" 2>/dev/null; then
  echo "${REPO_LINE}" | sudo tee "${SRC_LIST}" >/dev/null
  echo "   ソース定義を作成: ${SRC_LIST}"
else
  echo "   ソース定義は既に存在: ${SRC_LIST}"
fi

# ---------------------------------------------------------------------------
# 3. gh のインストール
# ---------------------------------------------------------------------------
echo "-- [3/4] gh をインストール"
sudo apt-get update -y
sudo apt-get install -y gh
echo "   $(gh --version | head -1)"
echo "   $(git --version)"

# ---------------------------------------------------------------------------
# 4. 認証 (対話) — トークン/パスワードはスクリプトに保持しない
# ---------------------------------------------------------------------------
echo "-- [4/4] GitHub 認証"
if gh auth status >/dev/null 2>&1; then
  echo "   既に認証済みです:"
  gh auth status 2>&1 | sed 's/^/     /'
else
  echo "   まだ認証されていません。"
  echo "   ヘッドレス機では『Login with a web browser』(デバイスコード)が簡単です。"
  read -rp "   今すぐ 'gh auth login' を対話実行しますか? [Y/n]: " ANS
  if [[ ! "${ANS}" =~ ^[Nn]$ ]]; then
    # gh 自身が対話でトークンを扱う。git 連携も併せて設定。
    gh auth login
    echo "   -- git 認証ヘルパーを gh に設定 (gh auth setup-git)"
    gh auth setup-git || true
  else
    echo "   後で認証する場合: gh auth login"
  fi
fi

# ---------------------------------------------------------------------------
# 任意: git のコミット者情報 (パスワードではない / 空でスキップ可)
# ---------------------------------------------------------------------------
if [[ -z "$(git config --global user.name || true)" || -z "$(git config --global user.email || true)" ]]; then
  echo "-- (任意) git のコミット者情報を設定します。空欄で Enter するとスキップします。"
  read -rp "   git user.name  : " GIT_NAME || true
  read -rp "   git user.email : " GIT_EMAIL || true
  [[ -n "${GIT_NAME:-}" ]]  && git config --global user.name  "${GIT_NAME}"
  [[ -n "${GIT_EMAIL:-}" ]] && git config --global user.email "${GIT_EMAIL}"
fi

cat <<'EOF'

==============================================================
 セットアップ完了
--------------------------------------------------------------
 動作確認:
   gh auth status
   gh api user -q .login
   gh repo list --limit 5
==============================================================
EOF
