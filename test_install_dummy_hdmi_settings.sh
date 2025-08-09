#!/bin/bash

PROFILE="$HOME/.xprofile"

# 定義する内容
read -r -d '' XRANDR_CONFIG << 'EOF'

# 1920x1080
xrandr --newmode "1920x1080_60.00" 173.00 1920 2048 2248 2576 1080 1083 1088 1120 -hsync +vsync
xrandr --addmode HDMI-A-1 "1920x1080_60.00"

# 4K
xrandr --newmode "3840x2160_60.00" 712.75 3840 4176 4592 5344 2160 2163 2168 2256 -hsync +vsync
xrandr --addmode HDMI-A-1 "3840x2160_60.00"

# 初期表示解像度（例：1920x1080 をデフォルトにしたい場合）
xrandr --output HDMI-A-1 --mode "1920x1080_60.00"
EOF

# 重複チェックして追記（1920x1080_60.00 が含まれていなければ追記）
if ! grep -q '1920x1080_60.00' "$PROFILE" 2>/dev/null; then
    echo "$XRANDR_CONFIG" >> "$PROFILE"
    echo "xrandr 設定を ~/.xprofile に追記しました。"
else
    echo "既に設定が存在しています。追記は行いませんでした。"
fi
