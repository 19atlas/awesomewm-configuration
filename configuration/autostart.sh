#!/bin/sh

start() {
  if ! pgrep -f "$1" ;
  then
    "$@"&
  fi
}

start nitrogen --restore
start picom --config=$HOME/.config/awesome/theme/picom.conf
start diodon
start /usr/bin/fusuma
start ulauncher --hide-window
