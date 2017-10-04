#!/bin/bash
jump_mid() {
    if [ "$READLINE_POINT" -eq "0" ]; then
        LEN=${#READLINE_LINE}
        POS=$(($LEN / 2))
        READLINE_POINT=$POS
    else
        READLINE_POINT=0
    fi
}
bind -x '"\C-a" : jump_mid'
