#!/bin/bash
jump_mid() {
    LEN=${#READLINE_LINE}
    POS=$(($LEN / 2))
    READLINE_POINT=$POS
}
bind -x '"\C-a\C-a" : jump_mid'
