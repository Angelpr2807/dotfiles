#!/bin/bash

VM=false
BSPWM="rice"         # Select between "rice" and "hack" -> Rice is variant of gh0stzk, hack is similar to s4vitar bspwm.
BLACK=true           # Pentest packages (true or false).
DISTRO="arch"        # Only arch y debian based distros supported.
DRIVERS="nvidia"     # "nvidia, amd or none". (lspci -v | grep -A10 VGA)

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
    sudo apt install git neovim xterm kitty rofi feh pulseaudio pavucontrol pamixer udiskie ntfs-3g xorg thunar ranger gvfs lxappearance qt5ct geeqie vlc zsh lsd bat papirus-icon-theme flameshot xclip man tree imagemagick dunst locate gvfs mtp-tools picom tumbler arandr whois vim exfatprogs gparted polybar bspwm sxhkd wget unzip 7zip gzip firejail golang ruby nodejs gh eza xss-lock npm
fi

if [[ "$DISTRO" = "arch" ]]; then
    if [[ "$DRIVERS" = "nvidia" ]]; then
        # Nvidia
        sudo pacman -S nvidia nvidia-settings nvidia-utils
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

if [[ "$DISTRO" = "arch" ]]; then
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
