#!/bin/bash

# Ubuntuでシステム全体のベル音（ビープ音）を無効にするスクリプト
# This script disables system bell sounds in Ubuntu

echo "Disabling system bell sounds..."

# 1. Bashのベル音を無効化 (readline)
lineToAdd="bind 'set bell-style none'"
if ! grep -Fxq "$lineToAdd" ~/.bashrc 2>/dev/null; then
    echo "$lineToAdd" >> ~/.bashrc
    echo "- Bash bell disabled in .bashrc"
else
    echo "- Bash bell already disabled in .bashrc"
fi

# 2. inputrcでベル音を無効化（全てのreadlineアプリケーション向け）
if [ ! -f ~/.inputrc ] || ! grep -q "set bell-style none" ~/.inputrc 2>/dev/null; then
    echo "set bell-style none" >> ~/.inputrc
    echo "- Bell disabled in .inputrc"
else
    echo "- Bell already disabled in .inputrc"
fi

# 3. GNOMEのイベントサウンドを無効化
if command -v gsettings &> /dev/null; then
    gsettings set org.gnome.desktop.sound event-sounds false 2>/dev/null && \
        echo "- GNOME event sounds disabled" || \
        echo "- Failed to disable GNOME event sounds (may not be running GNOME)"
fi

# 4. 現在のセッションで即座にベル音を無効化
if [ -t 0 ]; then
    bind 'set bell-style none' 2>/dev/null
fi

echo ""
echo "Done! System bell sounds have been disabled."
