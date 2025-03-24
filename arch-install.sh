#!/bin/bash

# Variables
DISK="/dev/sda"          # lsblk -a
LAPTOP=false             # special instalation for laptops
LANG="en_US.UTF-8"       # /etc/locale.gen
KEYMAP="dvorak"	         # list keymaps with "localectl list-keymaps"
NAME="arch"              # Hostname
TIMEZONE="America/Lima"  # list zones with "timedatectl list-zones"

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
    TYPE="gtp"
fi

# --------------- Particiones ---------------
# Eliminar todas las particiones previas
parted -s "$DISK" mklabel "$TYPE"

# Crear particiones
if [[ "$EFI" = "" ]]; then
	echo "creando  BIOS"
    parted -s "$DISK" mkpart primary fat32 1MiB 513MiB
else
	echo "creando UEFI"
    parted -s "$DISK" mkpart "EFI system partition" fat32 1MiB 513MiB
    parted -s "$DISK" set 1 esp on
fi

ROOT_START="513MiB"
ROOT_END="100%"


parted -s "$DISK" mkpart primary ext4 "$ROOT_START" "$ROOT_END"

if [[ "$EFI" = "/efi" ]]; then
    type 2 4F68BCE3-E8CD-4DB1-96E7-FBCAF98B709
fi

# --------------- Formateo ---------------
if [[ "$EFI" = "" ]]; then
    mkfs.vfat -F32 "${DISK}1"  # Formatear EFI
fi

mkfs.ext4 "${DISK}2"  # Formatear raíz

# --------------- Montaje ---------------
mount "${DISK}2" /mnt
mkdir -p "/mnt/boot${EFI}"
mount "${DISK}1" "/mnt/boot${EFI}"

# --------------- Instalación del sistema ---------------
pacstrap /mnt base base-devel networkmanager grub gvfs linux linux-firmware nano vim ${EFI:+efibootmgr}

# Para laptops
if [[ "$LAPTOP" = true ]]; then
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

timedatectl set-timezone "$TIMEZONE"
timedatectl set-ntp true

echo "$NAME" > /etc/hostname

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

if [[ "$EFI" = "/efi" ]]; then
    grub-install --efi-directory=/boot/efi --bootloader-id=GRUB --removable
else
    grub-install "$DISK"
fi

grub-mkconfig -o /boot/grub/grub.cfg

EOF

# --------------- Salida y reinicio ---------------
umount -R /mnt

echo "Manually reboot when you're ready and remove boot device.";
