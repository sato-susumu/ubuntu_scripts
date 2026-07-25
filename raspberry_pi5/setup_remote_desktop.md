# Raspberry Pi 5 リモートデスクトップ設定まとめ

> ⚠️ **重要 / 未検証の注意**
> 本リポジトリの **`setup_remote_desktop.sh` は動作確認（実行テスト）を行っていません。**
> 記載内容は、実際に稼働中の 1 台で手作業で確立した設定を「初期 OS からの手順」としてスクリプト化したものであり、
> クリーンな OS 上での通し実行は未検証です。利用する場合は、内容を確認のうえ自己責任で、
> できればテスト機や SSH で復旧できる状態で実行してください（構文チェック `bash -n` のみ実施済み）。
> なお、後述の**最終的な設定内容（本文）は稼働機で動作確認済み**です。

Raspberry Pi 5（ヘッドレス運用）に Windows などからリモートデスクトップ（RDP）で接続するための設定内容と、
初期状態の OS から同じ環境を再現するためのセットアップスクリプトをまとめたものです。

> **パスワードはこのドキュメントには記載しません。** 実際の RDP パスワードはセットアップ時に対話入力します
> （`setup_remote_desktop.sh` 実行時、または `grdctl --headless rdp set-credentials` で設定）。

---

## 1. 対象環境

| 項目 | 内容 |
|---|---|
| 機種 | Raspberry Pi 5（ホスト名 `pi5`） |
| OS | Ubuntu 26.04 LTS（GNOME / Wayland） |
| 運用形態 | ヘッドレス（モニタ非接続）、SSH 有効 |
| RDP サーバー | `gnome-remote-desktop`（GNOME 純正）を **`--headless` モード**で使用 |
| 接続クライアント | Windows 標準「リモートデスクトップ接続」(mstsc) ほか各種 RDP クライアント |

---

## 2. 採用した方式と、その理由

Wayland 環境では xrdp や VNC より **GNOME 純正の `gnome-remote-desktop`** が最も安定します。
本機は **自動ログインを有効にしたまま RDP も使いたい** ため、次の 3 方式のうち **`--headless`** を採用しています。

| 方式 | 概要 | 本機での可否 |
|---|---|---|
| 通常（画面共有 / `grdctl`） | 稼働中セッションを共有 | ✕ 自動ログインだと **login キーリングが無く**認証情報を保存できない |
| `--system`（リモートログイン） | 接続時に**新規セッション**を生成 | ✕ 自動ログイン中の taro と**二重セッション不可**でハンドオーバー失敗 |
| **`--headless`（採用）** | 自動ログイン中のセッションを**ヘッドレス共有** | ◎ 新規セッションを作らず自動ログインと共存。認証情報は**キーファイル保存**でキーリング不要 |

---

## 3. 最終的な構成

- **RDP サーバー**: ユーザー systemd サービス `gnome-remote-desktop-headless.service`
  - `ExecStart=/usr/libexec/gnome-remote-desktop-daemon --headless`
  - `WantedBy=gnome-session.target` … 自動ログインで GNOME セッションが起動すると同時に起動
  - `enabled` + `active`。待受ポート **3389**
- **自動ログイン**: 有効（`/etc/gdm3/custom.conf` の `[daemon]` に `AutomaticLoginEnable = true` / `AutomaticLogin = <ユーザー>`）
- **画面の自動ロック / スクリーンセーバー**: 無効
  （ロック中は mutter が `Session creation inhibited` を返し RDP セッションを開始できないため。ヘッドレス常時アクセス向けの設定）
  - `org.gnome.desktop.screensaver lock-enabled = false`
  - `org.gnome.desktop.screensaver idle-activation-enabled = false`
  - `org.gnome.desktop.session idle-delay = 0`
- **TLS 証明書**: 自己署名（`~/.local/share/gnome-remote-desktop/tls.crt` / `tls.key`、ユーザー所有）
  - RDP は暗号化に証明書が必須。自己署名のためクライアント側で初回に警告が出るが、許可すれば以降は記憶される
- **認証情報**: `--headless` はキーファイル保存（本機は TPM 非搭載のため `GKeyFile` フォールバック。ログの
  `Init TPM credentials failed ... using GKeyFile as fallback` は**正常・無害**）
- **入力操作**: 許可（view-only 無効）
- **競合サービスは無効化**: `--system` 用 `gnome-remote-desktop.service`（システム）と、
  通常ユーザー用 `gnome-remote-desktop.service` はいずれも `disabled`（ポート 3389 衝突回避）
- **ファイアウォール**: ufw は非アクティブ（ポート開放作業は不要）

### 接続情報

| 項目 | 値 |
|---|---|
| 接続先 | ホスト名 `pi5`、または IP アドレス（例: `192.168.2.230`） |
| ユーザー名 | `taro` |
| パスワード | （別途設定。**このドキュメントには記載しない**） |

> IP は DHCP だと変わることがあります。ルーターで **IP 固定（DHCP 予約）** するか、名前 `pi5` での接続を推奨します。

---

## 4. Windows からの接続手順

1. 「リモートデスクトップ接続」(`mstsc`) を起動
2. コンピューターに `pi5`（または IP）を入力
3. ユーザー名 `taro` とパスワードを入力
4. 自己署名証明書の警告が出たら「はい」で続行（以降は記憶される）

---

## 5. よくあるトラブルと対処（今回実際に遭遇したもの）

| 症状 / エラー | 原因 | 対処 |
|---|---|---|
| サーバーログ `Message Integrity Check (MIC) verification failed` / `SEC_E_MESSAGE_ALTERED` | この NLA(NTLM) 認証では **パスワード不一致**がこの形で現れる。多くは Windows が**古い資格情報をキャッシュ**して送っている | Windows の「資格情報マネージャー」→「Windows 資格情報」で `TERMSRV/<IP>` を削除し、正しいパスワードを入力し直す |
| Windows エラー `0x907`「予期しないサーバー認証証明書」 | サーバーの**証明書が以前接続時のものと変わった**（Windows はサーバーごとに証明書を固定する） | 同じ証明書を使い続ける。証明書を変えた場合は Windows 側の固定を解除：レジストリ `HKCU\Software\Microsoft\Terminal Server Client\Servers\<IP>` を削除して再接続 |
| サーバーログ `Failed to start remote desktop session: Session creation inhibited` | GNOME セッションが**画面ロック**状態。ロック中は RDP セッションを開始できない | 上記の**自動ロック無効化**設定を適用。すでにロック済みのセッションはその場で解除できないため `sudo systemctl restart gdm` で未ロックの新セッションを起動 |
| `--system` 方式で `Aborting handover` | 自動ログイン中のユーザーと**二重セッション**になれない | `--system` ではなく **`--headless`** を使う（本構成） |

---

## 6. 運用コマンド早見表

```bash
# 状態確認（このユーザーで実行）
systemctl --user status gnome-remote-desktop-headless.service
grdctl --headless status

# ログ確認
journalctl --user -u gnome-remote-desktop-headless.service -f

# パスワード変更（対話入力にしたい場合は setup スクリプトの再実行が簡単）
grdctl --headless rdp set-credentials <ユーザー名>        # 続けてパスワードを引数で渡すか、
                                                          # 引数省略時は空になるので注意
systemctl --user restart gnome-remote-desktop-headless.service

# サービス再起動
systemctl --user restart gnome-remote-desktop-headless.service
```

---

## 7. ファイル構成

```
raspberry_pi5_setup/
├── setup_remote_desktop.md    # このドキュメント（リモートデスクトップの設定まとめ）
├── setup_remote_desktop.sh    # 初期 OS からの自動セットアップスクリプト（パスワードは実行時に入力）
├── setup_sshd.md              # SSH サーバーの設定まとめ
└── setup_sshd.sh              # SSH サーバーの初期セットアップスクリプト
```

> ドキュメントは対応するスクリプトと同じ基準名にそろえています（`*.md` ↔ `*.sh`）。

関連: SSH サーバー（sshd）の設定は [`setup_sshd.md`](./setup_sshd.md) を参照。

### setup_remote_desktop.sh の使い方

```bash
# 対象の Raspberry Pi 上で、通常ユーザー（root ではない）で実行
cd ~/work/raspberry_pi5_setup
chmod +x setup_remote_desktop.sh
./setup_remote_desktop.sh
```

- 実行中に **RDP パスワードの入力**（確認のため 2 回）を求められます。ハードコードはしていません。
- 自己署名証明書は既存があれば再利用し、無ければ生成します（既存を無闇に更新して Windows 側の証明書固定を壊さないため）。
- 最後に GDM の再起動（＝設定反映）を行うか確認されます。再起動すると現在の GUI セッションは一旦終了します（SSH は影響なし）。
