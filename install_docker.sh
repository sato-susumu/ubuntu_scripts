#!/bin/bash

# This script is based on the method described in:
# https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script
# https://kinsta.com/jp/blog/install-docker-ubuntu/

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo groupadd docker
sudo usermod -aG docker $USER
rm get-docker.sh

echo "User added to Docker group."
echo -e "\e[31mIMPORTANT: Please log out and then log back in.\e[0m"
echo "Afterwards, run the following command: docker run hello-world"
