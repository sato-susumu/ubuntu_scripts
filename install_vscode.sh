#!/bin/bash

# This script is based on the method described in:
# https://qiita.com/yoshiyasu1111/items/e21a77ed68b52cb5f7c8

curl -L https://go.microsoft.com/fwlink/?LinkID=760868 -o vscode.deb
sudo apt install vscode.deb
rm vscode.deb
code --version
