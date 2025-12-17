#!/bin/bash

VM=false
BSPWM="rice"         # Select between "rice" and "hack" -> Rice is variant of gh0stzk, hack is similar to s4vitar bspwm.
BLACK=true           # Pentest packages (true or false).
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

sudo pacman -Sy --needed archlinux-keyring

sudo pacman -S --needed git neovim ly xterm kitty firefox rofi feh ttf-dejavu ttf-liberation noto-fonts pulseaudio pavucontrol pamixer udiskie ntfs-3g xorg xorg-xinit thunar ranger glib2 gvfs lxappearance qt5ct geeqie vlc zsh lsd bat papirus-icon-theme flameshot xclip man tree imagemagick dunst locate python-pillow gvfs-mtp mtpfs picom tumbler xorg-xrandr pkgfile whois vim exfatprogs gparted openssh polybar bspwm sxhkd wget unzip 7zip gzip firejail go ruby npm github-cli obsidian
trap_error "\n\t[!] Warning: Error in package installing"

if [[ "$DRIVERS" = "nvidia" ]]; then
    # Nvidia
    sudo pacman -S nvidia nvidia-settings nvidia-utils
    trap_error "\n\t[!] Warning: Error in gpu driver installing"
elif [[ "$DRIVERS" = "amd" ]]; then
    # AMD
    sudo pacman -S xf86-video-amdgpu vulkan-radeon opencl-mesa libva-mesa-driver lib32-libva-mesa-driver mesa-vdpau lib32-mesa-vdpau
    trap_error "\n\t[!] Warning: Error in package installing"
fi

if [[ "$VM" = true ]]; then
    # Packages needed for VM
    sudo pacman -S wmname virtualbox-guest-utils arandr wmname
    trap_error "\n\t[!] Warning: Error in vm packages installing"
fi

# Microcontrollers
# sudo pacman -S esptool

# Change default shell
sudo chsh -s $(which zsh) $(whoami)
sudo chsh -s $(which zsh) root

# Display manager
sudo systemctl enable ly@tty2.service
sudo systemctl disable getty@tty2.service

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
sudo git clone --depth 1 https://github.com/junegunn/fzf.git "${PLUGINS}/.fzf"
${PLUGINS}/.fzf/install
sudo ${PLUGINS}/.fzf/install

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

if [[ "$VM" = false ]]; then
    # grub watch dogs
    git clone --depth 1 https://github.com/VandalByte/dedsec-grub2-theme.git && cd dedsec-grub2-theme
    sudo python3 dedsec-theme.py --install
fi

cd
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

cd ~/Desktop/
mkdir -p repos/blackarch
cd ~/Desktop/repos/blackarch
curl -O https://blackarch.org/strap.sh
echo $(curl -X GET https://blackarch.org/downloads.html 2>/dev/null | grep -A1 "Verify the SHA1 sum" | grep -oP "\w{40}") strap.sh | sha1sum -c &&
chmod +x strap.sh
sudo ./strap.sh 
trap_error "\n\t[!] Warning: Error in blackarch repo installing"
sudo pacman -Sy

if [[ "$BLACK" = true ]]; then	
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
    cp -r bspwm-hack/* ~/.config/
    cp -r nvim/lua/* ~/.config/nvim/lua/
    sudo mkdir ${PLUGINS}/zsh-sudo
    cd ${PLUGINS}/zsh-sudo
    sudo wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/refs/heads/master/plugins/sudo/sudo.plugin.zsh
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
    sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/powerlevel10k

    sudo pacman -S --needed base-devel
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si
    sudo paru -S caido unifetch
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
sudo cp ./ly/config.ini /etc/ly
sudo mv ./icons/* /usr/share/icons
cd /usr/share/icons
sudo tar -xvf Zafiro-Icons-Dark.tar.xz

# NvChad installation
sudo rm -rf /root/.config/nvim
sudo rm -rf /root/.local/state/nvim
sudo rm -rf /root/.local/share/nvim
sudo git clone https://github.com/NvChad/starter /root/.config/nvim && sudo nvim

sudo rm /root/.zshrc

if [[ -e /root/.p10k.zsh ]]; then
	echo "backup of \".p10k.zsh\" created in \"/root/.p10k.zsh.bak\"";
	cp /root/.p10k.zsh /root/.p10k.zsh.bak
	sudo rm /root/.p10k.zsh
fi

if [[ -e /root/.zshrc ]]; then
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
