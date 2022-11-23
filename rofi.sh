# https://github.com/davatorium/rofi/blob/next/doc/rofi-script.5.markdown
#
# rofi -show 自定义 -modi "自定义:~/rofi.sh"
#   1: 上述命令可调用rofi.sh作为自定义脚本
#   2: 将打印的内容作为rofi的选项
#   3: 每次选中后 会用选中项作为入参再次调用脚本
#   4: 当没有输出时 整个过程结束

source ~/.profile

##### MAIN_MENU ####
    main_menu_items=('set wallpaper' 'update statusbar' 'toggle server')
    main_menu_cmds=(
        'feh --randomize --bg-fill ~/Pictures/002/*.*; show_main_menu' # 执行完不退出脚本继续执行show_main_menu
        'echo -en "\0new-selection\x1ftrue\n"; show_statusbar_menu'      # 加前面的echo是设置进入二级菜单时将selection置为新
        'echo -en "\0new-selection\x1ftrue\n"; show_toggle_server_menu'  # 加前面的echo是设置进入二级菜单时将selection置为新
    )

##### STATUSBAR_MENU #####
    statusbar_menu_items=('all' 'icons' 'coin' 'cpu' 'mem' 'date' 'vol' 'bat')
    statusbar_menu_cmds=(
        'coproc ($DWM/statusbar/statusbar.sh updateall    > /dev/null 2>&1)' # coproc (...) 未执行子进程语法 可以有效防止rofi脚本卡死
        'coproc ($DWM/statusbar/statusbar.sh update icons > /dev/null 2>&1)'
        'coproc ($DWM/statusbar/statusbar.sh update coin  > /dev/null 2>&1)'
        'coproc ($DWM/statusbar/statusbar.sh update cpu   > /dev/null 2>&1)'
        'coproc ($DWM/statusbar/statusbar.sh update mem   > /dev/null 2>&1)'
        'coproc ($DWM/statusbar/statusbar.sh update date  > /dev/null 2>&1)'
        'coproc ($DWM/statusbar/statusbar.sh update vol   > /dev/null 2>&1)'
        'coproc ($DWM/statusbar/statusbar.sh update bat   > /dev/null 2>&1)'
    )

##### TOGGLE_SERVER_MENU #####
    toggle_server_menu_items[1]='open v2raya'
    toggle_server_menu_items[2]='open picom'
    toggle_server_menu_items[3]='open easyeffects'
    toggle_server_menu_items[4]='open aria2c'
    toggle_server_menu_items[5]='open GO111MODULE'
    #toggle_server_menu_cmds[1]='coproc (sudo docker restart v2raya; $DWM/statusbar/statusbar.sh update icons)'
    toggle_server_menu_cmds[2]='coproc (picom --experimental-backends --config $DWM/config/picom.conf > /dev/null 2>&1)'
    toggle_server_menu_cmds[3]='coproc (easyeffects --gapplication-service > /dev/null 2>&1)'
    toggle_server_menu_cmds[4]='coproc (aria2c > /dev/null 2>&1); $DWM/statusbar/statusbar.sh update icons'
    toggle_server_menu_cmds[5]='sed -i "s/GO111MODULE=.*/GO111MODULE=on/g" ~/.profile'
    # 根据不同的条件判断单项的值和操作
    #[ "$(sudo docker ps | grep v2raya)" ] && toggle_server_menu_items[1]='close v2raya'
    #[ "$(sudo docker ps | grep v2raya)" ] && toggle_server_menu_cmds[1]='coproc (sudo docker stop v2raya; $DWM/statusbar/statusbar.sh update icons)'
    [ "$(ps aux | grep picom | grep -v 'grep\|rofi')" ] && toggle_server_menu_items[2]='close picom' 
    [ "$(ps aux | grep picom | grep -v 'grep\|rofi')" ] && toggle_server_menu_cmds[2]='killall picom'
    [ "$(ps aux | grep easyeffects | grep -v 'grep\|rofi')" ] && toggle_server_menu_items[3]='close easyeffects'
    [ "$(ps aux | grep easyeffects | grep -v 'grep\|rofi')" ] && toggle_server_menu_cmds[3]='killall easyeffects'
    [ "$(ps aux | grep aria2c | grep -v 'grep\|rofi')" ] && toggle_server_menu_items[4]='close aria2c'
    [ "$(ps aux | grep aria2c | grep -v 'grep\|rofi')" ] && toggle_server_menu_cmds[4]='killall aria2c'
    [ "$GO111MODULE" = 'on' ] && toggle_server_menu_items[5]='close GO111MODULE'
    [ "$GO111MODULE" = 'on' ] && toggle_server_menu_cmds[5]='sed -i "s/GO111MODULE=.*/GO111MODULE=off/g" ~/.profile'

###### SHOW MENU ######
    show_main_menu() {
        echo -e "\0prompt\x1fmenu\n"
        echo -en "\0data\x1fMAIN_MENU\n"
        for item in "${main_menu_items[@]}"; do
            echo "$item"
        done
    }
    show_statusbar_menu() {
        echo -e "\0prompt\x1fstatusbar\n"
        echo -en "\0data\x1fSTATUSBAR_MENU\n"
        for item in "${statusbar_menu_items[@]}"; do
            echo "$item"
        done
    }
    show_toggle_server_menu() {
        echo -e "\0prompt\x1ftoggle\n"
        echo -en "\0data\x1fTOGGLE_SERVER_MENU\n"
        for item in "${toggle_server_menu_items[@]}"; do
            echo "$item"
        done
    }

##### JUDGE #####
    judge() {
        [ "$ROFI_DATA" ] && MENU=$ROFI_DATA || MENU="MAIN_MENU" # 如果设置了ROFI_DATA（由 echo -en "\0data\x1fDATA值\n" 来传递）则使用ROFI_DATA对应的MENU，若空即MAIN_MENU
        # 根据不同的menu和item值执行相应的命令
        case $MENU in
            MAIN_MENU)
                for i in "${!main_menu_items[@]}"; do
                    [ "$*" = "${main_menu_items[$i]}" ] && eval "${main_menu_cmds[$i]}"
                done
            ;;
            STATUSBAR_MENU)
                for i in "${!statusbar_menu_items[@]}"; do
                    [ "$*" = "${statusbar_menu_items[$i]}" ] && eval "${statusbar_menu_cmds[$i]}"
                done
                show_statusbar_menu # 执行完成后不退出脚本 继续执行statusbar_menu
            ;;
            TOGGLE_SERVER_MENU)
                for i in "${!toggle_server_menu_items[@]}"; do
                    [ "$*" = "${toggle_server_menu_items[$i]}" ] && eval "${toggle_server_menu_cmds[$i]}"
                done
            ;;
        esac
    }

##### 程序执行入口 #####
    [ ! "$*" ] && show_main_menu || judge $*
