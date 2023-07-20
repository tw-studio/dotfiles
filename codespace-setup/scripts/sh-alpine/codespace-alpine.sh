#!/bin/sh
###############################################################################
# 
#     Run script with "dot space syntax" when local:
#     $ . /path/to/codespace-alpine.sh
#
#     Or from github, install better wget, then run with wget:
#     $ apk add --no-cache wget
#     $ sh -c "$(wget https://raw.github.com/...sh -O -)"
#
###############################################################################

# setup on alpine
export OS_NAME=alpine

# Configure home, user, and working dir
export HOME=/home
export CODESPACE=codespace

# Install packages
echo "Installing packages..." \
 && set -ex \
 && apk add --no-cache \
      bash \
      ca-certificates \
      coreutils \
      curl \
      fd \
      git \
      ncurses \
      neovim \
      ripgrep \
      tmux \
      tree \
      util-linux \
      zsh

# Clone dotfiles from public repo
git clone https://github.com/tw-space/dotfiles $HOME/.dotfiles

# Install oh-my-zsh
export ZSH=$HOME/.oh-my-zsh
export SHELL=/bin/zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
cp $HOME/.dotfiles/zsh/.zshrc $HOME/
cp $HOME/.dotfiles/zsh/codespace*.zsh-theme $ZSH/themes/
git clone https://github.com/jocelynmallon/zshmarks $ZSH/custom/plugins/zshmarks

# Install fzf from git
git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf
$HOME/.fzf/install --all || true
rm -f $HOME/.bashrc $HOME/.fzf.bash

# Configure neovim
mkdir -p $HOME/.config/nvim/colors \
 && mkdir -p $HOME/.local/share/nvim/site/autoload \
 && cp $HOME/.dotfiles/neovim/init.vim $HOME/.config/nvim/ \
 && cp $HOME/.dotfiles/neovim/monokai-fusion.vim $HOME/.config/nvim/colors/ \
 && cp $HOME/.dotfiles/neovim/plug.vim $HOME/.local/share/nvim/site/autoload/ \
 && cp $HOME/.dotfiles/neovim/dracula-airline.vim $HOME/.config/nvim/dracula.vim \
 && cp $HOME/.dotfiles/neovim/dracula.vim $HOME/.config/nvim/colors/
nvim --headless +PlugInstall +qall

# Configure tmux
cp $HOME/.dotfiles/tmux/.tmux.conf $HOME/
git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
tmux start-server \
 && tmux new-session -d \
 && sleep 1 \
 && $HOME/.tmux/plugins/tpm/scripts/install_plugins.sh \
 && tmux kill-server
mkdir -p $HOME/.tmux/scripts \
 && cp -r $HOME/.dotfiles/tmux/scripts $HOME/.tmux/

# Cleanup
rm -rf $HOME/.dotfiles

# Start zsh in codespace
mkdir $HOME/$CODESPACE
cd $HOME/$CODESPACE
zsh
