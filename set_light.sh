#! /bin/bash


source ~/.profile
source ~/.zshrc

case $1 in
    up)  xbacklight -inc 5 ;;
    down) xbacklight -dec 5 ;;
esac

$DWM/statusbar/statusbar.sh update light
