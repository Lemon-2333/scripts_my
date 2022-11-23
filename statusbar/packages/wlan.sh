#! /bin/bash
#需要额外安装bc
source ~/.profile


this=_wlan
s2d_reset="^d^"
color="^c#FFFFFF^^b#4E5173^"
"#4E5173"
signal=$(echo "^s$this^" | sed 's/_//')


update(){
    function get_velocity {
        value=$1
        old_value=$2
        now=$3
        timediff=$(($now - $old_time))
        velKB=$(echo "1000000000*($value-$old_value)/1024/$timediff" | bc)
        if test "$velKB" -gt 1024
        then
            echo $(echo "scale=2; $velKB/1024" |bc)MB/s
        else
            echo ${velKB}KB/s
        fi
    }

    function get_bytes {
        interface=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $5}')
        line=$(grep $interface /proc/net/dev | cut -d ':' -f2 | awk '{print "received_bytes="$1, "transmitted_bytes="$9}')
        eval $line
        now=$(date +%s%N)
    }
    get_bytes
    old_received_bytes=$received_bytes
    old_transmitted_bytes=$transmitted_bytes
    old_time=$now

    get_bytes

    vel_recv=$(get_velocity $received_bytes $old_received_bytes $now)
    vel_trans=$(get_velocity $transmitted_bytes $old_transmitted_bytes $now)

    text=" $vel_recv 祝$vel_trans "
    
    sed -i '/^export '$this'=.*$/d' $DWM/statusbar/temp
    printf "export %s='%s%s%s%s'\n" $this "$color" "$signal" "$text" "$s2d_reset" >> $DWM/statusbar/temp
}

click() { :; }

case "$1" in
    click) click $2 ;;
    *) update ;;
esac
