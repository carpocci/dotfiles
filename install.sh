#!/bin/bash

echo "Updating and installing dependencies..."
sudo apt update
sudo apt install -y zsh figlet toilet

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

mv ~/.zshrc ~/.zshrc.original
ln -nfs ~/.dotfiles/zsh/zshrc ~/.zshrc

echo "Changing login shell to zsh..."
chsh -s $(which zsh)
