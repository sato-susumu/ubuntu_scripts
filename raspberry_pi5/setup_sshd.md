# Raspberry Pi 5 — SSHD 設定まとめ

作成日: 2026-07-25

## 環境

| 項目 | 値 |
|------|-----|
| 機種 | Raspberry Pi 5（headless 運用） |
| OS | Ubuntu 26.04 LTS (aarch64) |
| ホスト名 | `pi5` |
| IP アドレス | 192.168.2.230 / 192.168.3.214（有線/無線の2系統。DHCP のため変わる可能性あり） |
| SSH サーバー | OpenSSH 10.2p1 (`openssh-server` 1:10.2p1-2ubuntu3.5) |

## 経緯

初期状態では `openssh-server` が**未インストール**だった（`sshd` バイナリなし、
`ssh.service` / `ssh.socket` とも not-found）。`sssd-ssh.*` という紛らわしい
ユニットが存在するが、これは SSSD（認証デーモン）の一部であり SSH サーバーとは別物。

`apt install openssh-server` でインストールし、自動起動を設定した。

## 最終的な設定内容

### 起動方式: socket activation（この構成のポイント）

Ubuntu 26.04 の OpenSSH は **socket activation 方式**がデフォルト。

- `ssh.socket` : **enabled / active** ← これが自動起動の実体
- `ssh.service` : **disabled** ← これで正常（socket 経由で必要時に起動される）

`sshd` は常駐せず、`ssh.socket` が 22 番ポートを監視し、接続が来た時点で
`sshd` が起動される。**`ssh.service` が disabled でも異常ではない**点に注意。

```
$ systemctl is-enabled ssh.socket   → enabled
$ systemctl is-active  ssh.socket   → active
$ ss -ltn | grep :22                → 0.0.0.0:22 / [::]:22 で待ち受け
```

### sshd の有効設定（`sshd -T` の主要項目）

| 設定 | 値 | 備考 |
|------|-----|------|
| Port | 22 | デフォルト |
| PermitRootLogin | prohibit-password | root はパスワードでは不可（鍵のみ） |
| PubkeyAuthentication | yes | |
| PasswordAuthentication | **yes** | パスワードログイン可（下記「今後の推奨」参照） |
| KbdInteractiveAuthentication | no | |
| X11Forwarding | yes | |

`/etc/ssh/sshd_config` はパッケージデフォルトのまま。`/etc/ssh/sshd_config.d/`
への追加設定なし。

### ファイアウォール

- `ufw` : **非アクティブ**（ブロックなし）
- 今後 ufw を有効化する場合は、締め出し防止のため**先に**
  `sudo ufw allow 22/tcp` を実行すること。

## 接続方法

```bash
ssh taro@192.168.2.230
# または mDNS が使えるネットワークなら
ssh taro@pi5.local
```

認証はユーザーのパスワード、または公開鍵（`~/.ssh/authorized_keys` に登録）。
※ パスワードそのものは本書には記載しない。

## 今後の推奨（未実施）

- **公開鍵認証への移行**: クライアントで `ssh-keygen` →
  `ssh-copy-id taro@pi5.local` で鍵を登録後、
  `/etc/ssh/sshd_config.d/` に `PasswordAuthentication no` を置くと安全性が上がる。
- **IP の固定**: DHCP 予約か静的 IP にすると接続先が安定する。

## 関連情報（同日の作業）

- GNOME 設定画面が英語表示だった問題: 原因は `~/.pam_environment` の
  `LANGUAGE=en` / `LANG=en_US.UTF-8`。`ja_JP` に修正済み（要・再ログイン）。
  バックアップ: `~/.pam_environment.bak`
- リモートデスクトップ: gnome-remote-desktop の **`--headless` モード**で
  RDP 接続可能（自動ログインを有効にしたまま、そのセッションを共有）。
  詳細は [`setup_remote_desktop.md`](./setup_remote_desktop.md) を参照。

## 関連ファイル

- セットアップスクリプト: [`setup_sshd.sh`](./setup_sshd.sh)
  （初期状態の OS から本書の状態を再現する）
