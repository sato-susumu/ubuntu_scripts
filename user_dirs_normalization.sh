#!/bin/bash

# This script is based on the method described in:
# https://qiita.com/peachft/items/fde3bebd356c17c1cef6

LANG=C xdg-user-dirs-update --force

move_if_exists() {
    local src_dir="$HOME/$1"
    local dest_dir="$HOME/$2"

    if [ -d "$src_dir" ]; then
        mv "$src_dir"/* "$dest_dir"
        rm -rf "$src_dir"
    fi
}

move_if_exists "デスクトップ" "Desktop"
move_if_exists "ダウンロード" "Downloads"
move_if_exists "テンプレート" "Templates"
move_if_exists "公開" "Public"
move_if_exists "ドキュメント" "Documents"
move_if_exists "ミュージック" "Music"
move_if_exists "ピクチャ" "Pictures"
move_if_exists "ビデオ" "Videos"

cat "$HOME/.config/user-dirs.dirs"
