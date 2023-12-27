#!/bin/bash

./update_bashrc_with_date_delimiter.sh

./sudo_nopasswd_add_current_user.sh

./user_dirs_normalization.sh

./gnome_screensaver_lock_off.sh
./install_autoware.sh
./install_docker.sh
./install_nvidia_container_toolkit.sh
./install_ssh_server.sh
./install_vscode.sh
./install_chrome.sh
./install_pycharm_professional.sh

./install_aws_cli.sh
./install_gcloud_cli.sh
./install_github_cli.sh

./update_bashrc_with_current_path.sh
