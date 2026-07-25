# Raspberry Pi 5 — GitHub CLI (`gh`) 設定まとめ

Raspberry Pi 5（ヘッドレス運用）で GitHub CLI `gh` を使えるようにするための設定内容と、
初期状態の OS から同じ環境を再現するためのセットアップスクリプトについてのまとめです。

> **トークン／パスワードはこのドキュメントには記載しません。**
> 認証（`gh auth login`）は対話操作で行い、認証情報は `gh` が自身の設定領域に安全に保存します。

---

## 1. 対象環境

| 項目 | 内容 |
|---|---|
| 機種 / OS | Raspberry Pi 5（ホスト名 `pi5`）/ Ubuntu 26.04 LTS (arm64) |
| 運用形態 | ヘッドレス（モニタ非接続）、SSH 経由で操作 |
| 導入したもの | `git` 2.53.0、`gh`（GitHub CLI）2.96.0 |

---

## 2. インストール方法（実施済み）

`gh` は **GitHub 公式 apt リポジトリ**から導入しました（最新版が入り、`apt` で自動更新される）。
Ubuntu universe にも `gh 2.46.0` はありますが、より新しい公式リポジトリ版を採用しています。

導入した内容:

- パッケージ: `git`、`gh`（依存の `wget` 等も）
- 追加した apt リポジトリ関連ファイル:
  - GPG 鍵: `/etc/apt/keyrings/githubcli-archive-keyring.gpg`
  - ソース定義: `/etc/apt/sources.list.d/github-cli.list`
    （`deb [arch=arm64 signed-by=…] https://cli.github.com/packages stable main`）

> 再現手順はスクリプト `setup_gh.sh` を参照。

---

## 3. 認証（`gh auth login`）

**ヘッドレス機ではブラウザのデバイスフロー（ワンタイムコード）認証が簡単です。**
`gh` 自身がパスワード/トークンを対話的に扱うため、スクリプトやドキュメントに秘密情報を書く必要はありません。

### 手順（推奨: Web ブラウザのデバイスフロー）

Pi 上（SSH 上）で以下を実行:

```bash
gh auth login
```

対話プロンプトでの選択例:

1. `What account do you want to log into?` → **GitHub.com**
2. `What is your preferred protocol for Git operations?` → **HTTPS**（または SSH）
3. `Authenticate Git with your GitHub credentials?` → **Yes**（git の認証も gh に任せる）
4. `How would you like to authenticate?` → **Login with a web browser**
5. 画面に **ワンタイムコード**（例 `XXXX-XXXX`）と URL `https://github.com/login/device` が表示される
6. **手元の PC（Windows など）のブラウザ**でその URL を開き、コードを入力して認可
7. Pi 側のプロンプトが自動で完了する

### 代替: Personal Access Token (PAT) を使う場合

ブラウザを使わない場合は、GitHub で発行した PAT を貼り付ける方式も可能です。

```bash
# 対話で「Paste an authentication token」を選ぶ、または:
gh auth login --with-token < <(printf '%s' "$YOUR_TOKEN")
```

> PAT は秘密情報です。**ファイルやドキュメントに残さない**でください。必要スコープの目安は
> `repo`, `read:org`, `gist`, `workflow`（用途に応じて）。

### git 連携（任意）

HTTPS で git を使う場合、認証ヘルパーを gh に設定すると push/pull がスムーズです:

```bash
gh auth setup-git
```

---

## 4. 認証情報の保存先

- `gh` の設定・認証情報: **`~/.config/gh/`**（`hosts.yml` にトークン等。利用可能なら OS のシークレットストア）
- このディレクトリはユーザー専用（`700` 相当）。**バックアップや共有時にトークンを流出させないよう注意**。

---

## 5. 動作確認

```bash
gh auth status          # ログイン状態とスコープ
gh api user -q .login   # 自分のユーザー名が返れば疎通OK
gh repo list --limit 5  # リポジトリ一覧
```

---

## 6. よく使うコマンド

```bash
gh repo clone <owner>/<repo>      # クローン
gh repo create <name> --private   # リポジトリ作成
gh pr create / gh pr list / gh pr checkout <番号>
gh issue list / gh issue create
gh run list / gh run watch        # GitHub Actions
gh auth refresh -s <scope>        # スコープ追加
gh auth logout                    # ログアウト
```

---

## 7. トラブルと対処

| 症状 | 対処 |
|---|---|
| `You are not logged into any GitHub hosts` | `gh auth login` を実行して認証 |
| ヘッドレスでブラウザが開けない | デバイスフロー（手順 5〜6）を使い、**別端末のブラウザ**でコード入力 |
| HTTPS の git push で認証を聞かれる | `gh auth setup-git` を実行（gh を git 認証ヘルパーにする） |
| スコープ不足でコマンドが失敗 | `gh auth refresh -s <必要スコープ>` |
| apt 更新で鍵エラー | `/etc/apt/keyrings/githubcli-archive-keyring.gpg` を再取得（`setup_gh.sh` が再導入） |

---

## 8. 関連ファイル

- セットアップスクリプト: [`setup_gh.sh`](./setup_gh.sh)（初期 OS から本書の状態を再現。認証は対話実行）
- 同フォルダの関連ドキュメント: [`setup_remote_desktop.md`](./setup_remote_desktop.md), [`setup_sshd.md`](./setup_sshd.md)
