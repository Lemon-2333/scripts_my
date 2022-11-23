#! /bin/bash
# DWM自启动脚本

source ~/.profile

settings() {
    [ $1 ] && sleep $1
    xset s 600
    xset -b
    syndaemon -i 1 -t -K -R -d
    xss-lock -- $DWM/blurlock.sh &
    $DWM/set-screen.sh two &
    $DWM/statusbar/statusbar.sh cron &
}

daemons() {
    [ $1 ] && sleep $1
    fcitx5 &
    nm-applet &
    qv2ray &
    flameshot & # 截图要跑一个程序在后台 不然无法将截图保存到剪贴板
    xfce4-power-manager &
    dunst -conf $DWM/config/dunst.conf &
    lemonade server &
    picom --experimental-backends --config $DWM/config/picom.conf >> /dev/null 2>&1 &
    ulauncher &
    xfce4-clipman &
    wmname LG3D &
}

every10s() {
    [ $1 ] && sleep $1
    while true
    do
        $DWM/set-screen.sh check &
        sleep 10
    done
}

every1000s() {
    [ $1 ] && sleep $1
    while true
    do
        feh --randomize --bg-fill ~/Pictures/002/*.*
        xset -b
        sleep 300
    done
}
feh --randomize --bg-fill ~/Pictures/002/*.*
settings 1 &
daemons 3 &
every10s 5 &
every1000s 30 &
every300s 30 &
