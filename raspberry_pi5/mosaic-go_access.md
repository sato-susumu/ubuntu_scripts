# Septentrio mosaic-go アクセス方法

最終更新: 2026-07-25

## 概要

Septentrio mosaic-go(GNSS受信機)をRaspberry Pi 5にUSB接続して使用している。
mosaic-goはUSB接続時にネットワークアダプタ(CDC-ECM/RNDIS)として認識され、
Ethernet over USBでWeb UIにアクセスできる。

## Web UIのアドレス

```
http://192.168.3.1
```

- mosaic-go本体のIPは常に `192.168.3.1` 固定
- ラズパイ側にはmosaic-goのDHCPから `192.168.3.x` のアドレスが自動割り当てされる
  (確認時は `192.168.3.214`)
- ネットワークインターフェース名は `enx1a3202991545` のような `enx` + MACアドレス形式

### 認識確認コマンド

```bash
ip -br addr show          # enxXXXX に 192.168.3.x が付いていればOK
lsusb | grep -i septentrio  # "Septentrio USB Device" が表示されればOK
```

## ログイン

ファームウェア v4.15.1(2025年10月)以降は初回ログインが必須。
認証情報はここには記載しない(パスワードマネージャ等で管理)。

## Dockのショートカット

デスクトップ(Ubuntu GNOME)のDockに「mosaic-go Web UI」ショートカットを登録済み。
クリックするとChromiumのアプリモードでWeb UIが開く。

- 定義ファイル: `~/.local/share/applications/mosaic-go.desktop`
- 起動コマンド: `/snap/bin/chromium --app=http://192.168.3.1`
- 通常のブラウザタブで開きたい場合は `Exec` 行を
  `/snap/bin/chromium http://192.168.3.1` に変更する
- Dockへの登録はGNOMEの `favorite-apps` 設定で行っている:
  ```bash
  gsettings get org.gnome.shell favorite-apps
  ```

## コマンドラインツール `mosaic`

受信機のコマンドポート(TCP 28784)を操作する自作CLIをインストール済み(2026-07-25)。

- 本体: `~/.local/bin/mosaic`(Python、`~/.local/venvs/gnss` のvenvを使用)
- 認証情報: `~/.config/mosaic-cli/credentials`(1行目ユーザー名、2行目パスワード、chmod 600)
- SBFパーサとして `pysbf2` を同venvにインストール済み

```bash
mosaic status              # 受信機・アンテナ・AGCゲインのサマリ
mosaic sats                # 可視衛星とC/N0
mosaic monitor [秒]        # アンテナ検出・AGCのライブ監視
mosaic cmd "lif, Identification"   # 任意の受信機コマンド送信
mosaic shell               # 対話シェル
```

AGCゲインの目安: アンテナ未接続 ≈ 50dB前後、正常なアクティブアンテナ接続時はそれより大きく下がる。

## RTKLIB(RxToolsの代替)

RxToolsはx86_64専用でラズパイでは動かないため、RTKLIB 2.4.3.b34をaptでインストール済み(2026-07-25)。

```bash
convbin log.sbf -r sbf -o out.obs   # SBF → RINEX変換(sbf2rin相当)
str2str                             # ストリーム転送・NTRIP(Data Link相当)
rnx2rtkp                            # 後処理測位
rtkrcv                              # リアルタイム測位
```

注意: mosaic系SBFの変換でエポック重複の既知報告あり
(https://github.com/rtklibexplorer/RTKLIB/issues/186)。精密用途では変換結果を要確認。

## 別のPCからアクセスする場合

192.168.3.x はラズパイとmosaic-go間のUSBネットワークなので、外部からは直接届かない。
SSHポートフォワードを使う:

```bash
# 別PC側で実行(ラズパイのWi-Fi IPは 192.168.2.230)
ssh -L 8080:192.168.3.1:80 taro@192.168.2.230
```

その後、別PCのブラウザで `http://localhost:8080` を開く。

## 既知の環境ノイズ: 近くのPCのUSB3転送

2026-07-25測定: 近くのPCでUSB3ファイル転送を行うと、GNSS全帯域でノイズフロアが
ANT1で約11〜13dB、ANT2で約5〜8dB上昇する(転送停止で即復帰、再現性確認済み)。
受信機の干渉検出器はこの広帯域ノイズを検出しない(Spectrum clean表示のまま)。

- 測定方法: `mosaic noise 20` を静穏時と転送中に実行してAGCゲインのmeanを比較
  (ゲイン低下=ノイズフロア上昇)
- 対策: アンテナをPC・USB3ケーブル・外付けSSDから1〜2m離す

## トラブルシューティング

- Web UIが開かない場合: `ip -br addr show` で `enx` インターフェースに
  192.168.3.x が付いているか確認。付いていなければUSBケーブルの抜き差し、
  またはmosaic-goの電源を確認する
- faviconの取得すらタイムアウトする場合はmosaic-goが応答していない
  (スリープ・電源断の可能性)
