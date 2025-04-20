parts=($(lsblk -a | grep -oP "sda\w+"))
echo "${parts[@]}"
