# Dotfiles

This is my personal configuration for BSPWM, and I have two variants.

1. Normal - rice: A nice desktop and minimal workflow setup. It's based on gh0stzk's dotfiles with slight modifications to the z0mbi3 and cristina themes to work with my own configurations and settings.
2. Black - minimal: Custom desktop and scripts for hacking and installing blackarch packages for penetration testing.

You can configure these files however you like. I'll post pictures of these variants soon.

There are two executable options: arch-install.sh and post-install.sh. The first one simply allows you to run a script for a clean install of Arch Linux, just by setting a few variables and giving it execution permissions. The post-installation file contains my configurations for bspwm, neovim, ranger, kitty, etc.

## Characteristics

- Display manager: [ly](https://github.com/fairyglade/ly).
- Window manager: [bswm](https://github.com/baskerville/bspwm).
- Program launcher: [rofi](https://github.com/adi1090x/rofi).
- Terminal: [Kitty](https://github.com/kovidgoyal/kitty).

### Terminal Plugins

- [Zsh syntax highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
- [Zsh autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [Powerlevel10k (only for black variant)](https://github.com/romkatv/powerlevel10k)
- [FZF](https://github.com/junegunn/fzf)

### Editor

I use the neovim text editor with [NvChad](https://nvchad.com/) settings. I modified the files a bit to fit my workflow, but you can edit it to not use those settings in the `post-install.sh` file.

> [!Warning]
> For virtual machines, both modes have issues with the Picom settings. I haven't been able to find a solution, so in this case, simply removing the rounded edges and opacity works for me.
>
> Commit "e3540c359" belongs to an older version of rice bspwm, so it doesn't work very well and breaks. Use the current version if you want or make a pull request to improve the customization of dotfiles.
