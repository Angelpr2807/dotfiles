#!/bin/bash

VM=false
BLACK=false

ping -c 1 google.com &> /dev/null || (echo -e "[!] You don't have internet access. Check your connection" && exit 1)

sudo pacman -Syu archlinux-keyring &&
    sudo pacman -S git neovim ly xterm kitty firefox rofi nitrogen ttf-dejavu ttf-liberation noto-fonts pulseaudio pavucontrol pamixer udiskie ntfs-3g xorg xorg-xinit thunar ranger glib2 gvfs lxappearance qt5ct geeqie vlc zsh lsd bat papirus-icon-theme flameshot xclip man tree imagemagick dunst locate python-pillow gvfs-mtp mtpfs picom tumbler xorg-xrandr pkgfile whois vim exfatprogs gparted openssh polybar bspwm sxhkd wget unzip 7zip gzip firejail go ruby npm

if [[ "$VM" = true ]]; then
	# Packages needed for VM
    sudo pacman -S wmname virtuabox-guest-utils arandr 
fi

# Change default shell
sudo chsh -s $(which zsh) $(whoami)
sudo chsh -s $(which zsh) root

# Display manager
sudo systemctl enable ly.service

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

cd ~/Downloads
git clone http://github.com/Angelpr2807/dotfiles.git

if [[ "$BLACK" = true ]]; then   
    cd ~/Downloads/dotfiles
    mv .* ~/
    mv ~/.zshrc-hack ~/.zshrc
    cp bspwm-hack/* ~/.config/
    cp -r nvim/lua/* ~/.config/nvim/lua/
    rm -rf ./nvim
    sudo mkdir /usr/share/zsh-sudo/
    cd /usr/share/zsh-sudo
    sudo wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/refs/heads/master/plugins/sudo/sudo.plugin.zsh
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
    sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/powerlevel10k
else
    cd
    curl -LO https://raw.githubusercontent.com/gh0stzk/dotfiles/master/RiceInstaller
    chmod +x RiceInstaller
    ./RiceInstaller &&
    cd ~/Downloads/dotfiles
    mv .* ~/
    mv ~/.zshrc-rice ~/.zshrc
    mv -r nvim/lua/* ~/.config/nvim/lua/
    rm -rf ./nvim
    mkdir -p ~/.config/bspwm
    cp -r bspwm-rice/* ~/.config/bspwm
fi

cp -r flameshot kitty neofetch ranger rofi ~/.config
rm -rf ~/Downloads/dotfiles

# term plugins
cd
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# fonst and icons
cd ~/Downloads
mkdir fonts
cd fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/Hack.zip
wget https://rubjo.github.io/victor-mono/VictorMonoAll.zip
wget https://font.download/dl/font/roboto.zip
#wget https://hackedfont.com/HACKED.zip   # I recomend install manually

sudo mv *.zip /usr/share/fonts/
cd /usr/share/fonts
sudo unzip Hack.zip
sudo unzip VictorMonoAll.zip
sudo unzip roboto.zip
#sudo unzip HACKED.zip
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
echo bbf0a0b838aed0ec05fff2d375dd17591cbdf8aa strap.sh | sha1sum -c &&
chmod +x strap.sh
sudo ./strap.sh
sudo pacman -Sy

if [[ "$BLACK" = true ]]; then
	# Pentesting packages
    sudo pacman -S metasploit ruby-erb gobuster wireshark-cli burpsuite whatweb nmap exploitdb hydra bind recon-ng hash-identifier hashcat macchanger jq impacket netexec ffuf responder mitm6 pth-toolkit ldapdomaindump smbclient evil-winrm mimikatz bloodhound neo4j-community socat upx gdb proxychains-ng mariadb
    cd /usr/share
    sudo git clone https://github.com/danielmiessler/SecLists.git
    sudo mkdir /usr/wordlists
    cd /usr/wordlists/
    sudo wget https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt
    cd ~/Downloads
    git clone https://github.com/openwall/john.git
    cd john/src && ./configure && make
fi

# Terminal plugins for root
sudo cd /root
sudo git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
sudo git clone https://github.com/zsh-users/zsh-autosuggestions /root/.zsh/zsh-autosuggestions
sudo git clone --depth 1 https://github.com/junegunn/fzf.git /root/.fzf
sudo /root/.fzf/install

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

sudo ln -s "${HOME}/.zshrc" /root/.zshrc
sudo ln -s "${HOME}/.p10k.zsh" /root/.p10k.zsh
sudo rm -rf /root/.config/nvim/lua
sudo ln -s "${HOME}/.config/nvim/lua" /root/.config/nvim/lua

exit
