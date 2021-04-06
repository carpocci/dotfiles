#!/bin/bash

sudo apt install zsh git figlet toilet

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

ln -nfs ~/.dotfiles/zsh/zshrc ~/.zshrc
