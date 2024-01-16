#!/bin/bash

managers=("apt" "yum") # supported managers
dependencies=("zsh" "figlet" "toilet")

find-manager() {
    for manager in "${managers[@]}"; do
        which $manager >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo $manager
            return 0
        fi
    done
    return 1
}

echo "Updating and installing dependencies..."
case $(find-manager) in
"apt")
    sudo apt update
    sudo apt install -y ${dependencies[@]}
    ;;
"yum")
    sudo yum update -y
    sudo yum install -y ${dependencies[@]}
    ;;
*)
    echo "This system isn't supported yet. Sorry!"
    echo "Supported package managers: ${managers[@]}"
    echo "Exiting..."
    exit 1
    ;;
esac

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

[ -f ~/.zshrc ] && mv ~/.zshrc ~/.zshrc.$(date +%Y-%m-%d-%H:%M:%S)

ln -nfs ~/.dotfiles/zsh/zshrc ~/.zshrc

echo "Changing login shell to zsh..."
chsh -s $(which zsh)

# set up a global gitignore file
git config --global core.excludesfile ~/.dotfiles/.global_gitignore
