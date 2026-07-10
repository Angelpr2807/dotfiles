#!/bin/bash

check_disk_param() {
    local params=("$@")
    local isvalid=false
    for param in ${params[@]}; do
        if [[ "$param" = "-d" ]]; then
            isvalid=true
            break
        fi
    done
    echo "$isvalid"
}

check_disk_not_null() {
    if [ ! -e $1 ]; then
        echo -e "[!] Error: Ingrese un disco válido."
        exit 1
    fi
}

check_param_is_valid() {
    if [[ $(echo $1 | grep -P "^\-.+") ]]; then
        echo "[!] Error: El parámetro \"-$2\" requiere un valor valido.";
        show_ussage_message
        exit 1
    fi
}

show_ussage_message() {
    echo -e "\nUso: $0 -d <disk> [OPTIONS]\n";
    echo -e "Options:\n";
    echo -e "-d <disk>      : Disco a usar para instalar arch linux";
    echo -e "-s <size>      : Crear y habilitar una partición swap en MiB (Deshabilitada por defecto)";
    echo -e "-l             : Instalar paquetes necesarios para controladores de laptops (Deshabilitada por defecto)";
    echo -e "-L <lang>      : Idioma y configuración regional (en_US.UTF-8) por defecto - Lista disponible en \"/etc/locale.gen\"";
    echo -e "-k <keymap>    : Distribución del teclado (la-latin1 por defecto) - \"lista: localectl list-keymaps\"";
    echo -e "-n <hostname>  : Nombre del dispositivo (arch por defecto)";
    echo -e "-t <timezone>  : Zona horaria (America/Lima por defecto) - \"lista: timedatectl list-timezones\"";
    echo -e "-h             : Muestra este mensaje.";
}

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

if [[ "$#" -lt 2 || $(check_disk_param $@) = "false" ]]; then
    echo -e "[!] Necesitas como mínimo proveer el disco para realizar la instalación.";
    show_ussage_message
    exit 1;
fi

# Variables
DISK=""                  # lsblk -a
LAPTOP=false             # special instalation for laptops
SWAP=false               # Enable swap
SWAPSIZE=8192            # Default swap size in MiB
LANG="en_US.UTF-8"       # /etc/locale.gen
KEYMAP="la-latin1"       # list keymaps with "localectl list-keymaps"
NAME="arch"              # Hostname
TIMEZONE="America/Lima"  # list zones with "timedatectl list-zones"

while getopts ":d:s:lL:k:n:t:h" opts; do
    case $opts in
        d) 
            check_param_is_valid $OPTARG "d"
            check_disk_not_null $OPTARG
            DISK="$OPTARG"
            ;;
        s) 
            check_param_is_valid $OPTARG "s"
            if [[ ! $OPTARG =~ ^[0-9]+$ ]]; then
                echo "[!] Error: El tamaño del swap debe ser numérico en MiB."
                exit 1
            fi
            SWAP=true;
            SWAPSIZE="$OPTARG";
        ;;
        l) LAPTOP=true; ;;
        L)  
            check_param_is_valid $OPTARG "L"
            if [[ $(grep -P "^#?[a-z]+_[A-Z]+(@[a-z]+|\.[A-Z]+\-\d)?" /etc/locale.gen | cut -d "#" -f 2 | cut -d " " -f 1 | grep "$OPTARG" | wc -l ) -ne 1 ]]; then
                echo "[!] Error: El idioma de configuración no es válido."
                echo -e "\nPuedes listarlos con 'grep -P \"^#?[a-z]+_[A-Z]+(@[a-z]+|\.[A-Z]+\-\d)?\" /etc/locale.gen | cut -d \"#\" -f 2 | cut -d \" \" -f 1'"
                exit 1
            fi
            LANG="$OPTARG" ;;
        k) 
            check_param_is_valid $OPTARG "k"
            if [[ $(localectl list-keymaps | grep -P "^${OPTARG}$" | wc -l) -ne 1 ]]; then
                echo "[!] error: La distribución de teclado no es válida, puedes listarlas con \"localectl list-keymaps\"."
                exit 1
            fi
            KEYMAP="$OPTARG"
            ;;
        n) 
            check_param_is_valid $OPTARG "n"
            NAME="$OPTARG"
            ;;
        t) 
            check_param_is_valid $OPTARG "t"
            if [[ $(timedatectl list-timezones | grep -P "^${OPTARG}$" | wc -l) -ne 1 ]]; then
                echo "[!] error: La zona horaria no es válida, puedes listarlas con \"timedatectl list-timezones\"."
                exit 1
            fi
            TIMEZONE="$OPTARG"
            ;;
        h) 
            show_ussage_message 
            exit 1
            ;;
        \?)
            echo -e "[!] Error: Parámetro \"-$OPTARG\" no es valido";
            show_ussage_message
            exit 1
            ;;
        :)
            echo -e "La opción -$OPTARG requiere su valor asociado."
            show_ussage_message
            exit 1
            ;;
    esac
done

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
    parted -s "$DISK" mkpart primary linux-swap 513MiB "${SWAPSIZE}MiB"
    ROOT_START="${SWAPSIZE}MiB"
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
pacstrap /mnt base base-devel os-prober networkmanager grub gvfs linux linux-firmware nano vim cryptsetup ${EFI:+efibootmgr}

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
sed -i 's/^#\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
echo "LANG=$LANG" > /etc/locale.conf
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
sed -i 's/^#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub

timedatectl set-timezone $TIMEZONE
timedatectl set-ntp true

if [[ "$EFI" = "/efi" ]]; then
    grub-install --efi-directory=/boot/efi --bootloader-id=GRUB
else
    grub-install "$DISK"
fi

grub-mkconfig -o /boot/grub/grub.cfg

EOF

# --------------- Salida y reinicio ---------------
umount -R /mnt

echo "Manually reboot when you're ready and remove boot device.";
