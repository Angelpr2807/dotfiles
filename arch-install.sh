#!/bin/bash

if [[ "$#" -ne 1 ]]; then
    echo -e "\n[!] Necesitas proveer el disco para realizar la instalación.";
    echo -e "\tUso: $0 <disco>\n";
    exit 1;
fi

# Variables
DISK="$1"          # lsblk -a
LAPTOP=false             # special instalation for laptops
SWAP=false               # Enable swap
LANG="en_US.UTF-8"       # /etc/locale.gen
KEYMAP="dvorak"	         # list keymaps with "localectl list-keymaps"
NAME="arch"              # Hostname
TIMEZONE="America/Lima"  # list zones with "timedatectl list-zones"
CIFRATE_DISK=false        # cifrate grub and disk.

# Function for confirm a password for a user
ask_password() {
    while true; do
        read -p "Set password for $1: " pass
		read -p "Confirm password: " confirm

        if [[ "$pass" = "$confirm" ]]; then
            break
        fi
    done

    echo "$pass"
}

# Comprobar si el sistema usa UEFI
EFI=""
TYPE="msdos"

if [[ -d /sys/firmware/efi ]]; then
    EFI="/efi"
    TYPE="gpt"
fi

# cifrate disk and grub
GRUB_PASS=""

if [[ "$CIFRATE_DISK" = true ]]; then
    echo -e "\n################################################\n"
    echo -e "[!] Encrypting grub, please provide a password...\n"
    GRUB_PASS=$(ask_password "GRUB") 
fi

# --------------- Particiones ---------------
# Eliminar todas las particiones previas
parted -s "$DISK" mklabel "$TYPE"
#
# Crear particiones
if [[ "$EFI" = "" ]]; then
	echo "creando  BIOS"
    parted -s "$DISK" mkpart primary fat32 1MiB 513MiB
else
	echo "creando UEFI"
    parted -s "$DISK" mkpart esp fat32 1MiB 513MiB
    parted -s "$DISK" set 1 esp on
fi

if [[ "$SWAP" = false ]];then
    ROOT_START="513MiB"
    ROOT_END="100%"
else
    parted -s "$DISK" mkpart primary linux-swap 513MiB 8075MiB
    ROOT_START="8075MiB"
    ROOT_END="100%"
fi

parted -s "$DISK" mkpart primary ext4 "$ROOT_START" "$ROOT_END"

DISK_SUBPART=$(echo "$DISK" | awk -F "/" '{ print $NF }')            # /dev/DISK_SUBPART
PARTITIONS=($(lsblk "$DISK" | grep -oP "${DISK_SUBPART}[\w\d]+" | sort ))      # sdx1 sdx2 por ejemplo

if [[ "$CIFRATE_DISK" = true ]]; then
    echo -e "\n################################################\n"
    echo -e "[!] Encrypting disk, please provide a password...\n"
    cryptsetup luksFormat "${ROOT_PART}"
    cryptsetup open "${ROOT_PART}" cryptroot
fi

BOOT_PART="/dev/${PARTITIONS[0]}"

if [[ "$SWAP" = false ]];then
    ROOT_PART="/dev/${PARTITIONS[1]}"
else
    ROOT_PART="/dev/${PARTITIONS[2]}"
    SWAP_PART="/dev/${PARTITIONS[1]}"
fi

# --------------- Formateo ---------------
mkfs.vfat -F32 "${BOOT_PART}"  # Formatear EFI

if [[ "$CIFRATE_DISK" = true ]]; then
    echo -e "\n################################################\n" 
    cryptsetup luksFormat "${ROOT_PART}" 
    cryptsetup open "${ROOT_PART}" cryptroot
    mkfs.ext4 /dev/mapper/cryptroot
fi

if [[ "$SWAP" = true ]]; then
    mkswap "${SWAP_PART}"     
else
    if [[ "$CIFRATE_DISK" = false ]]; then
        mkfs.ext4 "${ROOT_PART}"
    fi
fi

# --------------- Montaje ---------------
if [[ "$SWAP" = true ]]; then 
    swapon "${SWAP_PART}"
fi

if [[ "$CIFRATE_DISK" = true ]]; then
    mount /dev/mapper/cryptroot /mnt
else
	echo "No se esta encriptando"
    mount "${ROOT_PART}" /mnt
fi

mkdir -p "/mnt/boot${EFI}"
mount "${BOOT_PART}" "/mnt/boot${EFI}"

# --------------- Instalación del sistema ---------------
pacstrap /mnt base base-devel networkmanager grub gvfs linux linux-firmware nano vim cryptsetup ${EFI:+efibootmgr}

# Para laptops
if [[ "$LAPTOP" = true ]]; then
    # Controladores de wifi, el track pad, etc.
    pacstrap /mnt netctl wpa_supplicant dialog xf86-input-synaptics
fi

echo -e "Before starting the installation, create a password for the root user and your own user.\n"

# Configurar contraseña para root
ROOTPASS=$(ask_password "root")
echo
# Crear usuario personal con privilegios de sudo
read -p "Enter your username: " USERNAME

# Configurar contraseña para el usuario
USERPASS=$(ask_password "$USERNAME")

# --------------- Generar fstab ---------------
genfstab -U /mnt > /mnt/etc/fstab

# --------------- Chroot y configuración ---------------
arch-chroot /mnt << EOF

if [[ "$CIFRATE_DISK" = true ]]; then
    uuid=$(blkid -s UUID -o value "${DISK}${ROOT_PART}")
    grub_default="/etc/default/grub"
    mkinit_file="/etc/mkinitcpio.conf"

    if [[ grep -q 'GRUB_CMDLINE_LINUX=' "$grub_default" ]]; then
        sed -i "s|^GRUB_CMDLINE_LINUX=.*|GRUB_CMDLINE_LINUX=\"cryptdevice=UUID=$uuid:cryptroot root=/dev/mapper/cryptroot\"|" "$grub_default"
    else
        echo "GRUB_CMDLINE_LINUX=\"cryptdevice=UUID=$uuid:cryptroot root=/dev/mapper/cryptroot\"" >> "$grub_default"
    fi
    sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect keyboard keymap modconf block encrypt filesystems)/' "$mkinit_file"
fi

sed -i 's/^#\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
#echo "LANG=$LANG" > /etc/locale.conf
locale-gen

cat <<HOSTS > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${NAME}.local ${NAME}
HOSTS

systemctl enable NetworkManager

echo "KEYMAP=$KEYMAP" > /etc/vconsole.conf

echo "root:$ROOTPASS" | chpasswd

useradd -m -G wheel -s /bin/bash "$USERNAME"

echo "$USERNAME:$USERPASS" | chpasswd

sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

if [[ "$CIFRATE_DISK" = true ]]; then
    mkinitcpio -P
fi

if [[ "$EFI" = "/efi" ]]; then
    grub-install --efi-directory=/boot/efi --bootloader-id=GRUB --removable
else
    grub-install "$DISK"
fi

if [[ "$CIFRATE_DISK" = true ]]; then
    PASS_HASH=$(echo -e "$GRUB_PASS\n$GRUB_PASS" | grub-mkpasswd-pbkdf2 | grep 'grub.pbkdf2' | awk '{print $NF}')
    echo "set superusers=\"root\"" | sudo tee -a /etc/grub.d/40_custom
    echo "password_pbkdf2 root $PASS_HASH" | sudo tee -a /etc/grub.d/40_custom
fi

grub-mkconfig -o /boot/grub/grub.cfg

EOF

# --------------- Salida y reinicio ---------------
umount -R /mnt

echo "Manually reboot when you're ready and remove boot device.";
