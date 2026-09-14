# Dotfiles

This is my personal configuration for BSPWM, and I have two variants.

Caelestia: A nice desktop and minimal workflow setup. It's based on caelestia shell with slight modifications to the keybinds and visual content.

There are two executable options: arch-install.sh and post-install.sh. The first one simply allows you to run a script for a clean install of Arch Linux, just by setting a few variables and giving it execution permissions. The post-installation file contains my configurations for bspwm, neovim, ranger, kitty, etc.

## Characteristics

- Display manager: [ly](https://github.com/fairyglade/ly).
- Window manager: [hyprland](https://hypr.land/).
- Terminal: [Kitty](https://github.com/kovidgoyal/kitty).

### Terminal Plugins

- [Zsh syntax highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
- [Zsh autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [Powerlevel10k (only for black variant)](https://github.com/romkatv/powerlevel10k)
- [FZF](https://github.com/junegunn/fzf)

### Editor

I use the neovim text editor with [NvChad](https://nvchad.com/) settings. I modified the files a bit to fit my workflow, but you can edit it to not use those settings in the `post-install.sh` file.
