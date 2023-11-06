#!/bin/sh
# SPECTRWM Autostart
export SCRIPTPATH="$HOME/.config/spectrwm"

pgrep -x "picom" && pkill picom
nohup picom --config "$SCRIPTPATH"/picom/picom.conf > /dev/null 2>&1 &

pgrep -x "nitrogen" && pkill nitrogen
nohup nitrogen --restore &

nohup dunst -config "$SCRIPTPATH/dunstrc" &

# Start custom power management notifications
pgrep -x "battery-notify" && pkill battery-notify
nohup "$SCRIPTPATH"/battery-notify >/dev/null 2>&1 &

# ==== [ SCREEN CONFIGURATIONS ] ====
xset s 120 5
xss-lock -l -- i3lock-fancy -p

