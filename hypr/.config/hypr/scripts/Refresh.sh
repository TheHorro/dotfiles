#!/bin/bash
# Scripts for refreshing waybar, rofi, swaync

WALLPAPER=$HOME/.config/hypr/wallpapers/stairs.jpg

# Define file_exists function
file_exists() {
    if [ -e "$1" ]; then
        return 0  # File exists
    else
        return 1  # File does not exist
    fi
}

# Kill already running processes
_ps=(waybar rofi swaync)
for _prs in "${_ps[@]}"; do
    if pidof "${_prs}" >/dev/null; then
        pkill "${_prs}"
    fi
done

# added since wallust sometimes not applying
killall -SIGUSR2 waybar 

# quit ags & relaunch ags
#ags -q && ags &

# some process to kill
for pid in $(pidof waybar rofi swaync swaybg); do
    kill -SIGUSR1 "$pid"
done

#Restart waybar
sleep 1
waybar &

# relaunch swaync
sleep 0.5
swaync > /dev/null 2>&1 &
# reload swaync
swaync-client --reload-config
# reload wallpaper
swaybg -i $WALLPAPER -m fill

exit 0
