sudo apt install ptpd
sudo ptpd -M -i enx00e04c682856  # USBイーサネット経由

sudo tee /etc/ptpd2.conf > /dev/null << EOF
  [global]
  foreground = N
  log_file = /var/log/ptpd2.log
  verbose_foreground = N

  [ptpengine]
  interface = enx00e04c682856
  preset = masteronly
  domain = 0
  EOF

  # systemdサービスファイル作成
  sudo tee /etc/systemd/system/ptpd-livox.service > /dev/null << 'EOF'
  [Unit]
  Description=PTP Daemon for Livox
  After=network.target
  Wants=network.target

  [Service]
  Type=forking
  ExecStart=/usr/sbin/ptpd2 -c /etc/ptpd2.conf
  PIDFile=/var/run/ptpd2.lock
  Restart=always
  RestartSec=5

  [Install]
  WantedBy=multi-user.target
  EOF

  # サービス有効化
  sudo systemctl daemon-reload
  sudo systemctl enable ptpd-livox
  sudo systemctl start ptpd-livox

  echo "PTP自動起動設定完了"
  echo "確認: sudo systemctl status ptpd-livox"


