#!/bin/bash

./update_bashrc_with_date_delimiter.sh
./update_bashrc_with_current_path.sh
./update_bashrc_with_bell_off.sh
./sudo_nopasswd_add_current_user.sh
./user_dirs_normalization.sh
./gnome_screensaver_lock_off.sh
./disable_ubuntu_auto_update.sh
./disable_ubuntu_crash_report.sh

./install_ros_humble.sh
./install_ros_humble_packages.sh

./install_docker.sh
./install_ssh_server.sh
./install_vscode.sh
./install_chrome.sh
./install_realsense_sdk.sh  

./install_aws_cli.sh
./install_gcloud_cli.sh
./install_github_cli.sh
./install_utilities.sh


echo -e "\e[31mIMPORTANT: Please log out and then log back in.\e[0m"

