#!/bin/bash
if [[ $# -ge 2 ]]; then
    script=${0##/*/}
	echo -e "[!] Error: Demasiados parámetros.";
    echo -e "\n[+] Uso: ${script%%.sh} [IPv4]";
    echo -e "- Sin IP:\tSe limpia el objetivo y se muestra \"No Target\".";
    echo -e "- Con IP:\tSe asigna el objetivo y al hacer click derecho en la polybar se copia en la clipboard.";
    exit 1;
fi

if [[ $1 = "" ]]; then
  target="No target";
  echo -e "\n\t[+] Limpiando objetivo.";
else
  if [[ $(echo $1 | grep -oP "(\d{1,3}\.){3}\d{1,3}") ]]; then
    target=$1;
    echo -e "\n\t Cambiando objetivo a: $1"
  else
    echo -e "\n\t[X] Debes ingresar una ip válida!!!"
    echo -e "\tFormato: [1-256].[1-256].[1-256].[1-256]"
    exit 1
  fi
fi

echo $target > $HOME/.config/polybar/target.txt;
