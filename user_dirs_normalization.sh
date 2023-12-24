#!/bin/bash

# This script is based on the method described in:
# https://qiita.com/peachft/items/fde3bebd356c17c1cef6

LANG=C xdg-user-dirs-update --force
cd; mv デスクトップ/* Desktop; mv ダウンロード/* Downloads; mv テンプレート/* Templates; rm -rf テンプレート; mv 公開/* Public; mv ドキュメント/* Documents; mv ミュージック/* Music; mv ピクチャ/* Pictures; mv ビデオ/* Videos
rm -rf デスクトップ ダウンロード テンプレート 公開 ドキュメント ミュージック ピクチャ ビデオ
cat .config/user-dirs.dirs
