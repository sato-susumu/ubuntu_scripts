# Ubuntu Scripts

Ubuntu 22.04向けのセットアップ・管理スクリプト集

## クイックスタート

```bash
sudo apt update
sudo apt upgrade -y
sudo apt install -y ssh git curl
mkdir -p ~/work
cd ~/work
git clone https://github.com/sato-susumu/ubuntu_scripts.git
cd ubuntu_scripts/
./just_for_me.sh
./samba_home_share.sh
```

## インストール系

| スクリプト | 説明 |
|-----------|------|
| `install_aws_cli.sh` | AWS CLI のインストール |
| `install_chrome.sh` | Google Chrome のインストール |
| `install_docker.sh` | Docker のインストール |
| `install_drivers.sh` | 各種ドライバのインストール |
| `install_gcloud_cli.sh` | Google Cloud CLI のインストール |
| `install_github_cli.sh` | GitHub CLI のインストール |
| `install_novnc.sh` | noVNC のインストール（起動時自動起動設定込み）※LAN内での使用を想定 |
| `install_nvidia_container_toolkit.sh` | NVIDIA Container Toolkit のインストール |
| `install_nvidia_cuda.sh` | NVIDIA CUDA のインストール |
| `install_nvidia_cudnn.sh` | NVIDIA cuDNN のインストール |
| `install_nvidia_driver.sh` | NVIDIA ドライバのインストール |
| `install_ptpd_unconfirmed.sh` | PTPd のインストール（未検証） |
| `install_pycharm_community.sh` | PyCharm Community Edition のインストール |
| `install_pycharm_professional.sh` | PyCharm Professional のインストール |
| `install_realsense_sdk.sh` | Intel RealSense SDK のインストール |
| `install_ros_humble.sh` | ROS 2 Humble のインストール |
| `install_ros_humble_packages.sh` | ROS 2 Humble 追加パッケージのインストール |
| `install_ssh_server.sh` | SSH サーバのインストール |
| `install_utilities.sh` | 各種ユーティリティのインストール |
| `install_vscode.sh` | Visual Studio Code のインストール |

## アンインストール系

| スクリプト | 説明 |
|-----------|------|
| `uninstall_novnc.sh` | noVNC のアンインストール |
| `uninstall_nvidia_cuda.sh` | NVIDIA CUDA のアンインストール |
| `uninstall_nvidia_cudnn.sh` | NVIDIA cuDNN のアンインストール |
| `uninstall_nvidia_driver.sh` | NVIDIA ドライバのアンインストール |
| `uninstall_pycharm_community.sh` | PyCharm Community Edition のアンインストール |
| `uninstall_pycharm_professional.sh` | PyCharm Professional のアンインストール |
| `uninstall_ros_humble_packages.sh` | ROS 2 Humble 追加パッケージのアンインストール |

## システム設定

| スクリプト | 説明 |
|-----------|------|
| `disable_policy_check.sh` | ポリシーチェックの無効化 |
| `disable_shutdown_for_users.sh` | 一般ユーザーのシャットダウン権限を無効化 |
| `enable_shutdown_for_users.sh` | 一般ユーザーのシャットダウン権限を有効化 |
| `disable_ubuntu_auto_update.sh` | Ubuntu 自動更新の無効化 |
| `disable_ubuntu_crash_report.sh` | Ubuntu クラッシュレポートの無効化 |
| `gnome_screensaver_lock_off.sh` | スクリーンセーバーロックの無効化 |
| `sudo_nopasswd_add_current_user.sh` | 現在のユーザーを sudo パスワードなしに設定 |
| `user_dirs_normalization.sh` | ユーザーディレクトリ名の正規化（英語化） |

## USB 関連

| スクリプト | 説明 |
|-----------|------|
| `check_usb_autosuspend.sh` | USB オートサスペンド状態の確認 |
| `disable_usb_autosuspend.sh` | USB オートサスペンドの無効化 |

## Samba 共有

| スクリプト | 説明 |
|-----------|------|
| `samba_home_share.sh` | ホームディレクトリの Samba 共有を有効化 |
| `samba_home_unshare.sh` | ホームディレクトリの Samba 共有を無効化 |

## Bash 設定

| スクリプト | 説明 |
|-----------|------|
| `update_bashrc_with_bell_off.sh` | ターミナルベル音の無効化 |
| `update_bashrc_with_current_path.sh` | プロンプトにカレントパス表示を追加 |
| `update_bashrc_with_date_delimiter.sh` | プロンプトに日付区切り表示を追加 |

## 情報表示・ユーティリティ

| スクリプト | 説明 |
|-----------|------|
| `show_ip_address.sh` | IP アドレスの表示 |
| `show_nvidia_info.sh` | NVIDIA GPU 情報の表示 |
| `reboot.sh` | 再起動 |
| `shutdown.sh` | シャットダウン |

## テスト用（試験的）

| スクリプト | 説明 |
|-----------|------|
| `test_disable_auto_login.sh` | 自動ログインの無効化（テスト） |
| `test_enable_auto_login.sh` | 自動ログインの有効化（テスト） |
| `test_disable_gnome_keyring_auto_unlock.sh` | GNOME Keyring 自動アンロックの無効化（テスト） |
| `test_enable_gnome_keyring_auto_unlock.sh` | GNOME Keyring 自動アンロックの有効化（テスト） |
| `test_install_dummy_hdmi_settings.sh` | ダミー HDMI 設定のインストール（テスト） |

## その他

| スクリプト | 説明 |
|-----------|------|
| `just_for_me.sh` | 個人用設定スクリプト |

## 使い方

```bash
# スクリプトに実行権限を付与
chmod +x <script_name>.sh

# 実行
./<script_name>.sh
```
