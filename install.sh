#!/bin/bash

managers=("apt" "yum") # supported managers
dependencies=("curl" "zsh" "figlet" "toilet" "tmux" "git")
dotfiles_dir="$HOME/.dotfiles"
conf_dir="$dotfiles_dir/conf_files"

find-manager() {
    for manager in "${managers[@]}"; do
        if command -v "$manager" >/dev/null 2>&1; then
            echo "$manager"
            return 0
        fi
    done
    return 1
}

is-installed() {
    case $manager in
    apt) dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "install ok installed" ;;
    yum) rpm -q "$1" >/dev/null 2>&1 ;;
    esac
}

manager=$(find-manager) || {
    echo "This system isn't supported yet. Sorry!"
    echo "Supported package managers: ${managers[*]}"
    echo "Exiting..."
    exit 1
}

# --- dependencies -------------------------------------------------------------
missing=()
for pkg in "${dependencies[@]}"; do
    is-installed "$pkg" || missing+=("$pkg")
done

if [ ${#missing[@]} -eq 0 ]; then
    echo "All dependencies already installed."
else
    echo "Installing missing dependencies: ${missing[*]}"
    case $manager in
    apt)
        sudo apt update
        sudo apt install -y "${missing[@]}"
        ;;
    yum)
        sudo yum install -y "${missing[@]}"
        ;;
    esac
fi

# --- oh-my-zsh ----------------------------------------------------------------
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "oh-my-zsh already installed, skipping."
else
    echo "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# --- symlinks for config files ------------------------------------------------
shopt -s dotglob nullglob
for src in "$conf_dir"/*; do
    name=$(basename "$src")
    dest="$HOME/$name"

    # already correctly linked -> nothing to do
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        echo "ok: $dest already linked"
        continue
    fi

    # real file/dir (or symlink pointing elsewhere) -> back it up
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        mv -v "$dest" "$dest.$(date +%Y-%m-%d-%H:%M:%S)"
    fi

    ln -sv "$src" "$dest"
done
shopt -u dotglob nullglob

# --- login shell --------------------------------------------------------------
zsh_path=$(command -v zsh)
current_shell=$(getent passwd "$USER" | cut -d: -f7)
if [ "$current_shell" = "$zsh_path" ]; then
    echo "Login shell is already zsh."
else
    echo "Changing login shell to zsh..."
    chsh -s "$zsh_path"
fi

# --- global gitignore ---------------------------------------------------------
git config --global core.excludesfile ~/.global_gitignore

# --- tmux plugin manager ------------------------------------------------------
if [ -d "$HOME/.tmux/plugins/tpm/.git" ]; then
    echo "tpm already installed, updating..."
    git -C "$HOME/.tmux/plugins/tpm" pull --quiet
else
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi
