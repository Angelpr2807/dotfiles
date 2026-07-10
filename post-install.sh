#!/bin/bash

show_ussage_message() {
    echo -e "\nUso: $0 [OPTIONS]\n";
    echo -e "Options:\n";
    echo -e "-d <desktop>  : Interfaz de usuario, rice o hack (valor por defecto: rice, no funciona en debian :'), solo hack).";
    echo -e "-b            : Agregar paquetes y repos para pentesting.";
    echo -e "-D <distro>   : Distribución de linux (arch por defecto), arch o debian.";
    echo -e "-g <drivers>  : Instalar drivers de gpu, nvidia o amd, por defecto es none (ningún driver).";
    echo -e "-v            : Instalar paquetes para compatibilidad si realizas una instalación para máquina virtual.";
    echo -e "-h            : Muestra este mensaje.";
}

check_param_is_valid() {
    if [[ $(echo $1 | grep -P "^\-.+") ]]; then
        echo "[!] Error: El parámetro \"-$2\" requiere un valor valido.";
        show_ussage_message
        exit 1
    fi
}

VM=false
BSPWM="rice"     # Select between "rice" and "hack" -> Rice is variant of gh0stzk, hack is similar to s4vitar bspwm.
BLACK=false      # Pentest packages (true or false).
DISTRO="arch"    # Only arch y debian based distros supported.
DRIVERS="none"   # "nvidia, amd or none". (lspci -v | grep -A10 VGA)

while getopts ":d:bvD:g:h" opts; do
    case $opts in
        d)
            check_param_is_valid $OPTARG "d"
            if [[ $OPTARG != "rice" && $OPTARG != "hack" ]]; then
                echo "[!] error: La interfaz de escritorio no es válida, las opciones disponibles son 'rice' o 'hack'."
                exit 1
            fi
            BSPWM="$OPTARG"
            ;;
        b) BLACK=true ;;
        v) VM=true ;;
        D)
            check_param_is_valid $OPTARG "D"
            if [[ $OPTARG != "arch" && $OPTARG != "debian" ]]; then
                echo "[!] error: La distribución de linux no es válida, las opciones disponibles son 'arch' o 'debian', sirve para las distros basadas en estas."
                exit 1
            fi
            DISTRO="$OPTARG"
            ;;
        g)
            check_param_is_valid $OPTARG "g"
            if [[ $OPTARG != "nvidia" && $OPTARG != "amd" && $OPTARG != "none" ]]; then
                echo "[!] error: Los drivers de gpu no son válidos, las opciones disponibles son 'nvidia' o 'amd'"
                exit 1
            fi
            DRIVERS="$OPTARG"
            ;;
        h) show_ussage_message ;;
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

if [[ $DISTRO = "debian" && $BSPWM = "rice" ]]; then
    echo -e "[!] Lo sentimos, la UI desktop de \"rice\" solo está disponible para arch linux, lo sentimos :'c ";
    exit 1
fi

echo "$VM"
echo "$BSPWM"
echo "$BLACK"
echo "$DISTRO"
echo "$DRIVERS"

exit 0

ctrl_c() {
    echo -e "\n\t[!] Ctrl+C detected, stopping the script."
    exit 2
}

trap_error() {
    if [[ "$?" -ne "0" ]]; then	
        echo -e "$1"
	exit 1
    fi
}

trap ctrl_c INT

ping -c 1 google.com &> /dev/null 
trap_error "\n\t[!] You don't have internet access. Check your connection\n"

if [[ "$DISTRO" = "arch" ]]; then
    sudo pacman -Sy --needed archlinux-keyring

    sudo pacman -S --needed git neovim ly xterm kitty firefox rofi feh ttf-dejavu ttf-liberation noto-fonts pulseaudio pavucontrol pamixer udiskie ntfs-3g xorg xorg-xinit thunar ranger glib2 gvfs lxappearance qt5ct geeqie vlc zsh lsd bat papirus-icon-theme flameshot xclip man tree imagemagick dunst locate python-pillow gvfs-mtp mtpfs picom tumbler xorg-xrandr pkgfile whois vim exfatprogs gparted openssh polybar bspwm sxhkd wget unzip 7zip gzip firejail go ruby npm github-cli eza xss-lock 

    trap_error "\n\t[!] Warning: Error in package installing"
elif [[ "$DISTRO" = "debian" ]]; then
    sudo apt install git neovim xterm kitty rofi feh pulseaudio pavucontrol pamixer udiskie ntfs-3g xorg thunar ranger gvfs lxappearance qt5ct geeqie vlc zsh lsd bat papirus-icon-theme flameshot xclip man tree imagemagick dunst locate gvfs mtp-tools picom tumbler arandr whois vim exfatprogs gparted polybar bspwm sxhkd wget unzip 7zip gzip firejail golang ruby nodejs gh eza xss-lock npm docker docker-compose docker-buildx
fi

if [[ "$DISTRO" = "arch" ]]; then
    if [[ "$DRIVERS" = "nvidia" ]]; then
        # Nvidia
        sudo pacman -S nvidia-open nvidia-settings nvidia-utils
        trap_error "\n\t[!] Warning: Error in gpu driver installing"
    elif [[ "$DRIVERS" = "amd" ]]; then
        # AMD
        sudo pacman -S xf86-video-amdgpu vulkan-radeon opencl-mesa libva-mesa-driver lib32-libva-mesa-driver mesa-vdpau lib32-mesa-vdpau
        trap_error "\n\t[!] Warning: Error in package installing"
    fi
fi

if [[ "$VM" = true && "$DISTRO" = "arch" ]]; then
    # Packages needed for VM
    sudo pacman -S wmname virtualbox-guest-utils arandr
    trap_error "\n\t[!] Warning: Error in vm packages installing"
elif [[ "$VM" = true && "$DISTRO" = "debian" ]]; then
    sudo apt install suckless-tools virtualbox-guest-utils arandr
    trap_error "\n\t[!] Warning: Error in vm packages installing"
fi

# Microcontrollers
# sudo pacman -S esptool

# Change default shell
sudo chsh -s $(which zsh) $(whoami)
sudo chsh -s $(which zsh) root

if [[ "$DISTRO" = "arch" ]]; then
    # Display manager
    sudo systemctl enable ly@tty2.service
    sudo systemctl disable getty@tty2.service
fi

# Themes for GUI
echo -e "QT_QPA_PLATFORMTHEME=qt5ct\nGTK_THEME=Adwaita:dark" | sudo tee /etc/environment

mkdir -p ~/.config
mkdir -p ~/Desktop
mkdir -p ~/Downloads

# NvChad installation
rm -rf ~/.config/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.local/share/nvim
git clone https://github.com/NvChad/starter ~/.config/nvim && nvim

# term plugins
cd
PLUGINS="/usr/share/zsh/plugins"
sudo mkdir -p "${PLUGINS}"
sudo git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${PLUGINS}/zsh-syntax-highlighting" 
sudo git clone https://github.com/zsh-users/zsh-autosuggestions "${PLUGINS}/zsh-autosuggestions"
sudo git clone https://github.com/zsh-users/zsh-history-substring-search.git "${PLUGINS}/zsh-history-substring-search"
sudo git clone https://github.com/zsh-users/zsh-history-substring-search.git "${PLUGINS}/zsh-history-substring-search"
sudo git clone https://github.com/Aloxaf/fzf-tab.git "${PLUGINS}/fzf-tab-git"
sudo git clone --depth 1 https://github.com/junegunn/fzf.git "${PLUGINS}/.fzf"

# Download fonts and icons
cd ~/Downloads/dotfiles/config/specials/fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/Hack.zip
wget https://rubjo.github.io/victor-mono/VictorMonoAll.zip
wget https://font.download/dl/font/roboto.zip

sudo mv *.zip /usr/share/fonts/
cd /usr/share/fonts
ls *.zip | while read zip; do
    sudo unzip "$zip"
done
sudo rm *.zip

cd ~/Downloads/

if [[ "$VM" = false && "$DISTRO" = "arch" ]]; then
    # grub watch dogs
    git clone --depth 1 https://github.com/VandalByte/dedsec-grub2-theme.git && cd dedsec-grub2-theme
    sudo python3 dedsec-theme.py --install
fi

cd
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

if [[ "$BLACK" = true && "$DISTRO" = "arch" ]]; then	
    cd ~/Desktop/
    mkdir -p repos/blackarch
    cd ~/Desktop/repos/blackarch
    curl -O https://blackarch.org/strap.sh
    echo $(curl -X GET https://blackarch.org/downloads.html 2>/dev/null | grep -A1 "Verify the SHA1 sum" | grep -oP "\w{40}") strap.sh | sha1sum -c &&
        chmod +x strap.sh
    sudo ./strap.sh 
    trap_error "\n\t[!] Warning: Error in blackarch repo installing"
    sudo pacman -Sy
fi

if [[ "$BLACK" = true && "$DISTRO" = "arch" ]]; then	
    # Pentesting packages
    sudo pacman -S --needed zsh-completions ltrace metasploit ruby-erb gobuster wireshark-cli caido whatweb nmap exploitdb hydra bind recon-ng hash-identifier hashcat macchanger jq impacket netexec ffuf responder mitm6 pth-toolkit python-ldapdomaindump smbclient evil-winrm mimikatz bloodhound neo4j-community socat upx gdb proxychains-ng mariadb rustscan
    trap_error "\n\t[!] Warning: Error in pentesting packages installing"
    cd /usr/share
    sudo git clone https://github.com/danielmiessler/SecLists.git
    sudo mkdir /usr/wordlists
    cd /usr/wordlists/
    sudo wget https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt
    cd ~/Downloads
    git clone https://github.com/openwall/john.git
    cd john/src && ./configure && make
fi

if [[ "$BSPWM" = "hack" ]]; then   
    cd ~/Downloads/dotfiles/config
    cp .* ~/
    mv ~/.zshrc-hack ~/.zshrc
    rm ~/.zshrc-rice
    mkdir -p ~/Pictures/walls
    mv bspwm-hack/walls/* ~/Pictures/walls
    cp -r bspwm-hack/* ~/.config/
    rm -f ~/.config/polybar/config
    cp -r nvim/lua/* ~/.config/nvim/lua/
    sudo mkdir /usr/share/zsh/plugins/zsh-sudo
    sudo curl -X GET https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/refs/heads/master/plugins/sudo/sudo.plugin.zsh -o /usr/share/zsh/plugins/zsh-sudo/sudo.plugin.zsh
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
    sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/powerlevel10k

    if [[ "$DISTRO" = "arch" ]]; then
        sudo pacman -S --needed base-devel
        git clone https://aur.archlinux.org/paru.git
        cd paru
        makepkg -si
        sudo paru -S caido unifetch
    fi
else
    cd
    curl -LO https://raw.githubusercontent.com/gh0stzk/dotfiles/master/RiceInstaller
    chmod +x RiceInstaller
    ./RiceInstaller &&
    cd ~/Downloads/dotfiles/config
    cp .* ~/
    mv ~/.zshrc-rice ~/.zshrc
    rm ~/.zshrc-hack
    cp -r nvim/lua/* ~/.config/nvim/lua/
    mkdir -p ~/.config/bspwm
    cp -r bspwm-rice/* ~/.config/bspwm
fi

cd ~/.config
rm -rf kitty unifetch ranger rofi && cd ~/Downloads/dotfiles/config
cp -r kitty unifetch ranger rofi ~/.config

cd ./specials 
# Special files
if [[ "$DISTRO" = "arch" ]]; then
    sudo cp ./ly/config.ini /etc/ly
fi
sudo mv ./icons/* /usr/share/icons
cd /usr/share/icons
sudo tar -xvf Zafiro-Icons-Dark.tar.xz

# NvChad installation
sudo rm -rf /root/.config/nvim
sudo rm -rf /root/.local/state/nvim
sudo rm -rf /root/.local/share/nvim
sudo git clone https://github.com/NvChad/starter /root/.config/nvim && sudo nvim

sudo rm /root/.zshrc

if [[ $(sudo find /root -name .p10k.zsh) ]]; then
	echo "backup of \".p10k.zsh\" created in \"/root/.p10k.zsh.bak\"";
	cp /root/.p10k.zsh /root/.p10k.zsh.bak
	sudo rm /root/.p10k.zsh
fi

if [[ $(sudo find /root -name .zshrc) ]]; then
	echo "backup of \".zshrc\" created in \"/root/.zshrc.bak\"";
	cp /root/.zshrc /root/.zshrc.bak
	sudo rm /root/.zshrc
fi

sudo ln -s "${HOME}/.zshrc" /root/.zshrc
sudo ln -s "${HOME}/.p10k.zsh" /root/.p10k.zsh
sudo rm -rf /root/.config/nvim/lua
sudo ln -s "${HOME}/.config/nvim/lua" /root/.config/nvim/lua

sudo cd /root
sudo curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

exit 0
