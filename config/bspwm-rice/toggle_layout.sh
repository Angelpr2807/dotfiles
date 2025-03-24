#!/bin/bash

# Archivo: ~/toggle_keyboard_layout.sh

# Obtiene el layout de teclado actual
current_layout=$(setxkbmap -query | grep layout | awk '{print $2}')

if [ "$current_layout" == "us" ]; then
    setxkbmap latam
else
    setxkbmap us -variant dvorak-intl
fi
