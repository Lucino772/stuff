#!/bin/bash

# This script does the following
# 1. Update & Upgrade the system
# 2. Install wget & curl
# 3. Install Git
# 4. Configure Git & GitHub SSH Keys
# 5. Install Zsh & Oh-My-Posh
# 6. Install Pyenv, Pipx, Poetry & Pipenv
# 7. Install Nvm

install_git () {
    git --version > /dev/null
    if [ $? -eq 0 ]; then
        echo "Git already installed !"
        echo "$(git --version)"
    else
        echo "Installing git..."
        sudo apt install -y git
    
        git --version > /dev/null
        if [ $? -eq 0]; then
            echo "Git successfully installed !"
        else
            echo "Failed to install git !"
        fi
    fi
}

setup_git () {
    echo "Configure Git & GitHub"
    read -p "Enter your GitHub username: " git_username
    read -p "Enter your GitHub email: " git_email
    read -p "Do you want to configure an SSH key for GitHub (Y/n) ? " -n 1 -r git_do_gen_ssh_key

    if [[ $git_do_gen_ssh_key =~ ^[Yy]$ ]]; then
        git_do_gen_ssh_key="true"

        git_ssh_gen_default_filename=$HOME/.ssh/id_ed25519
        read -p "Enter file in which to save the key ($git_ssh_gen_default_filename): " git_ssh_gen_filename
        git_ssh_gen_filename=${git_ssh_gen_filename:-$git_ssh_gen_default_filename}
        
        read -p "Enter passphrase: " git_ssh_gen_passphrase
    fi
    
    echo "Setting up user $git_email ($git_username)"
    git config --global user.name "$git_username"
    git config --global user.email "$git_email"

    echo "Added git ignore alias"
    git config --global alias.ignore '!gi() { curl -sL https://www.toptal.com/developers/gitignore/api/$@ ;}; gi'
    
    if [[ $git_do_gen_ssh_key -eq "true" ]]; then
        echo "Generating SSH key for GitHub"
        ssh-keygen -t ed25519 -C "$git_email" -q -N "$git_ssh_gen_passphrase" -f "$git_ssh_gen_filename"
        echo "Don't forget to add the SSH key to your GitHub account:"
        echo "> cat ${git_ssh_gen_filename}.pub"
        
        if [[ $git_ssh_gen_passphrase -ne "" ]]; then
            echo "You setup a passphrase with you SSH key"
            echo "Make sure to start the ssh-agent & to add your key:"
            echo "> eval \"$(ssh-agent -s)\""
            echo "> ssh-add $git_ssh_gen_filename"
        fi
        
        echo "Once your key has been added to your GitHub account, you can test your connectivity:"
        echo "> ssh -T git@github.com"
    fi
    
    echo "Done configuring Git & GitHub"
}


install_zsh () {
    zsh --version > /dev/null
    if [ $? -eq 0 ]; then
        echo "ZSH is installed !"
    else
        echo "Installing Zsh..."
        sudo apt install -y zsh
        
        zsh --version > /dev/null
        if [ $? -eq 0 ]; then
            echo "Szh successfully installed !"
        else
            echo "Failed to install Zsh !"
        fi
    fi
    
    echo "Setting Zsh as default shell"
    chsh -s $(which zsh)
    
    echo "Installing & Configuring ohmyposh"
    sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
    sudo chmod +x /usr/local/bin/oh-my-posh

    echo "Installing Nerd Fonts: JetBrainsMono"
    sudo oh-my-posh font install JetBrainsMono

    rcfile="${HOME}/.bashrc"
    if [[ $do_install_zsh -eq "Y" || $do_install_zsh -eq "y" || $do_install_zsh -eq "" ]]; then
        rcfile="${HOME}/.zshrc"
    fi

    echo "Writing configuration in $rcfile"
    echo "# OhMyPosh" >> "$rcfile"
    echo 'eval "$(oh-my-posh init zsh --config https://raw.githubusercontent.com/Lucino772/stuff/main/dotfiles/ohmyposh/lucino772.omp.json)"' >> "$rcfile"
}


install_pyenv () {
    echo "Installing pyenv"
    curl https://pyenv.run | bash
        
    rcfile="${HOME}/.bashrc"
    if [[ $do_install_zsh -eq "Y" || $do_install_zsh -eq "y" || $do_install_zsh -eq "" ]]; then
        rcfile="${HOME}/.zshrc"
    fi
        
    echo "Writing configuration in $rcfile"
    echo '# Pyenv' >> "$rcfile"
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> "$rcfile"
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> "$rcfile"
    echo 'eval "$(pyenv init -)"' >> "$rcfile"
    
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    
    read -p "Do you want to install python now ? (Y/n) " -n 1 -r do_install_python
    if [[ $do_install_python =~ ^[Yy]$ ]]; then
        read -p "Which version of python ? (3.8.10)" python_version
        python_version=${python_version:-"3.8.10"}
        
        echo "Installing python build essentials"
        sudo apt install make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
        
        echo "Installing Python $python_version"
        pyenv install "$python_version"
        pyenv global "$python_version"
        
        read -p "Do you want to install pipx ? (Y/n) " -n 1 -r do_install_pipx
        if [[ $do_install_pipx =~ ^[Yy]$ ]]; then
            pip3 install --user pipx
            python3 -m pipx ensurepath
        fi
        
        read -p "Do you want to install poetry ? (Y/n) " -n 1 -r do_install_poetry
        if [[ $do_install_poetry =~ ^[Yy]$ ]]; then
            python3 -m pipx install poetry
        fi
        
        read -p "Do you want to install pipenv ? (Y/n) " -n 1 -r do_install_pipenv
        if [[ $do_install_pipenv =~ ^[Yy]$ ]]; then
            python3 -m pipx install pipenv
        fi
    fi
}


install_nvm () {
    echo "Installing Nvm"
    wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | zsh
    
    # Load NVM
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")" 
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    echo "Installing Node.js LTS"
    nvm install --lts
    
    echo "Enabling corepack (yarn)"
    corepack enable
}



echo "Updating & Upgrading system"
sudo apt update
sudo apt upgrade -y

echo "Installing wget & curl utilities"
sudo apt install -y wget curl

# Git & GitHub
read -p "Do you want to install & configure Git ? (Y/n) " -n 1 -r do_install_git
if [[ $do_install_git =~ ^[Yy]$ ]]; then
    install_git
    setup_git
fi

# Zsh & oh-my-zsh
read -p "Do you want to install zsh & oh-my-zsh ? (Y/n) " -n 1 -r do_install_zsh
if [[ $do_install_zsh =~ ^[Yy]$ ]]; then
    install_zsh
    
    export SHELL=$(which zsh)
fi

# Python & Pyenv
read -p "Do you want to install pyenv ? (Y/n) " -n 1 -r do_install_pyenv
if [[ $do_install_pyenv =~ ^[Yy]$ ]]; then
    install_pyenv
fi

# Node.js & Nvm
read -p "Do you want to install nvm ? (Y/n) " -n 1 -r do_install_nvm
if [[ $do_install_nvm =~ ^[Yy]$ ]]; then
    install_nvm
fi

## Other Apps
# VSCode + Config ?
# Neovim + Config ?
# Java SDK ?
# CMake ?
# Golang ?
# Rust ?
# Docker ?