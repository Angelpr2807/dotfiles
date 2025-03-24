#!/bin/bash

IP=$(ip a  show dev tun0 2>/dev/null | grep -oP "\d+\.\d+\.\d+\.\d+")

if [[ $IP = "" ]]; then
  echo "Disconnected";
else
  echo "$IP";
fi
  
