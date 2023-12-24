#!/bin/bash

# This script is based on the method described in:
# https://qiita.com/yoshiyasu1111/items/e21a77ed68b52cb5f7c8

curl -L "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" -o vscode.deb
sudo dpkg -i vscode.deb
rm vscode.deb
code --version
