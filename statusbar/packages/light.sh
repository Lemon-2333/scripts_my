#! /bin/bash


source ~/.profile
source ~/.zshrc

this=_light
s2d_reset="^d^"
color="^c#553388^^b#334466^"
color="^c#FFFFFF^^b#334466^"

signal=$(echo "^s$this^" | sed 's/_//')

update() {
    light_icon="ﯧ"

    light_text=$(xbacklight -get)%
    echo $light_text

    text=" $light_icon $light_text "
    sed -i '/^export '$this'=.*$/d' $DWM/statusbar/temp
    printf "export %s='%s%s%s%s'\n" $this "$color" "$signal" "$text" "$s2d_reset" >> $DWM/statusbar/temp
}

click() {
    case "$1" in
        L) xbacklight -inc 5  ;; # 亮度加
        R) xbacklight -dec 5  ;; # 亮度减
    esac
}

case "$1" in
    click) click $2 ;;
    *) update ;;
esac
