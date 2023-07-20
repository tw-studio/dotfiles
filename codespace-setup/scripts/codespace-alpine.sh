#!/bin/sh
###############################################################################
# 
#     Run script as root with "dot space syntax" when local:
#     $ . /path/to/codespace-alpine.sh
#
#     Or from github, install better wget, then run with wget:
#     $ apk add --no-cache wget
#     $ sh -c "$(wget https://raw.github.com/...sh -O -)"
#
###############################################################################

# errexit, xtrace
set -ex

# Install packages
echo "Installing packages..." \
&& apk update \
&& apk add --no-cache \
  bash \
  ca-certificates \
  coreutils \
  curl \
  fd \
  git \
  ncurses \
  neovim \
  perl \
  ripgrep \
  sudo \
  tmux \
  tree \
  tzdata \
  util-linux \
  wget \
  zsh
apk add --no-cache perl-file-rename --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing/
apk -v cache clean

# Configure su
chmod u+s $(which su)

# Set timezone
cp /usr/share/zoneinfo/America/Los_Angeles /etc/localtime \
&& echo "America/Los_Angeles" > /etc/timezone \
&& apk del tzdata

# Configure home, user, and working dir
export OS_NAME=alpine
export USER=alpine
adduser -s /bin/zsh -D -g '' $USER
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo EDITOR='tee -a' visudo
export HOME=/home/$USER
export CODESPACE=codespace
export RUSER=root
export RHOME=/root

# Create codespace directory
mkdir -p $HOME/$CODESPACE

# Clone dotfiles from public repo
git clone https://github.com/tw-studio/dotfiles $HOME/.dotfiles

# Install and configure oh-my-zsh
export ZSH=$HOME/.oh-my-zsh
export RZSH=$RHOME/.oh-my-zsh
export SHELL=/bin/zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
cp -r $ZSH $RZSH
\cp -f $HOME/.dotfiles/zsh/.zshrc $HOME/
\cp -f $HOME/.dotfiles/zsh/.zshrc $RHOME/
cp $HOME/.dotfiles/zsh/codespace*.zsh-theme $ZSH/themes/
cp $HOME/.dotfiles/zsh/codespace*.zsh-theme $RZSH/themes/
git clone https://github.com/jocelynmallon/zshmarks $ZSH/custom/plugins/zshmarks
cp -r $ZSH/custom/plugins/zshmarks $RZSH/custom/plugins/zshmarks

# Install fzf from git
git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf
cp -r $HOME/.fzf $RHOME/.fzf
$HOME/.fzf/install --all || true
rm -f $HOME/.bashrc $HOME/.fzf/code.bash
rm -f $RHOME/.bashrc $RHOME/.fzf.bash

# Configure neovim
mkdir -p $HOME/.config/nvim/colors \
 && mkdir -p $HOME/.local/share/nvim/site/autoload \
 && cp $HOME/.dotfiles/neovim/init-ec2.vim $HOME/.config/nvim/init.vim \
 && cp $HOME/.dotfiles/neovim/monokai-fusion.vim $HOME/.config/nvim/colors/ \
 && cp $HOME/.dotfiles/neovim/plug.vim $HOME/.local/share/nvim/site/autoload/ \
 && cp $HOME/.dotfiles/neovim/dracula-airline.vim $HOME/.config/nvim/dracula.vim \
 && cp $HOME/.dotfiles/neovim/dracula.vim $HOME/.config/nvim/colors/
mkdir -p $RHOME/.config/nvim/colors \
 && mkdir -p $RHOME/.local/share/nvim/site/autoload \
 && cp $HOME/.dotfiles/neovim/init.vim $RHOME/.config/nvim/ \
 && cp $HOME/.dotfiles/neovim/monokai-fusion.vim $RHOME/.config/nvim/colors/ \
 && cp $HOME/.dotfiles/neovim/plug.vim $RHOME/.local/share/nvim/site/autoload/ \
 && cp $HOME/.dotfiles/neovim/dracula-airline.vim $RHOME/.config/nvim/dracula.vim \
 && cp $HOME/.dotfiles/neovim/dracula.vim $RHOME/.config/nvim/colors/
nvim --headless +PlugInstall +qall

# Configure tmux
cp $HOME/.dotfiles/tmux/.tmux.conf $HOME/
cp $HOME/.dotfiles/tmux/.tmux.conf $RHOME/
git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
cp -r $HOME/.tmux $RHOME/.tmux
tmux start-server \
 && tmux new-session -d \
 && sleep 1 \
 && $HOME/.tmux/plugins/tpm/scripts/install_plugins.sh \
 && tmux kill-server
mkdir -p $HOME/.tmux/scripts \
 && cp -r $HOME/.dotfiles/tmux/scripts $HOME/.tmux/
mkdir -p $RHOME/.tmux/scripts \
 && cp -r $HOME/.dotfiles/tmux/scripts $RHOME/.tmux/

# Cleanup
rm -rf $HOME/.dotfiles

# Give user their stuff
chown -R $USER $HOME

# Set default shell for root
perl -i -pe 's:/bin/ash:/bin/zsh:' /etc/passwd

# Fix insecure completion-dependent directories permissions
chmod g-w,o-w $HOME/.oh-my-zsh
chmod g-w,o-w $RHOME/.oh-my-zsh

# Start zsh in codespace as user
mkdir -p $HOME/$CODESPACE
cd $HOME/$CODESPACE
su - $USER -c "zsh"
