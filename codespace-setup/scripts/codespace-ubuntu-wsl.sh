#!/bin/bash
###############################################################################
# 
#     Run script as root with "dot space syntax" when local:
#     $ . /path/to/codespace-ubuntu.sh
#
#     Or from github, install better wget and ca-certificates,
#     then run with wget:
#     $ apt-get update && apt-get install -y --no-install-recommends wget ca-certificates && sh -c "$(wget https://raw.githubusercontent.com/tw-studio/dotfiles/main/codespace-setup/scripts/codespace-ubuntu.sh -O -)"
#
###############################################################################

# errexit, xtrace
set -e

# Default USER to first dir in /home, if exists
USER="ubuntu"
FIRST_HOME_DIR=$(find /home -maxdepth 1 -mindepth 1 -type d | head -n 1)
if [[ -n "$FIRST_HOME_DIR" ]]; then
  FIRST_HOME_DIR=$(basename "$FIRST_HOME_DIR")
  USER="$FIRST_HOME_DIR"
fi

# Request username from user
if [[ -z "$1" ]]; then
  echo "Enter the user name for Ubuntu login: ($USER) "
  read user_name
  if [[ ! -z "$user_name" ]]; then
    USER="$user_name"
  fi
else
  USER="$1"
fi
echo "Setting USER to $USER..."

# Set timezone
export TZ=America/Los_Angeles
echo "Setting timezone to $TZ..."
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install packages
echo "Installing packages..." \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    coreutils \
    curl \
    fd-find \
    git \
    keychain \
    locales \
    ncurses-base \
    neovim \
    rename \
    ripgrep \
    sudo \
    tmux \
    tree \
    util-linux \
    zsh \
 && apt-get clean
rm -rf /var/lib/apt/lists/*
 
# Fix locale issues, e.g. with Perl
echo "Fix locale issues, e.g. with Perl..."
sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
 && dpkg-reconfigure --frontend=noninteractive locales \
 && update-locale LANG=en_US.UTF-8
export LANG=en_US.UTF-8 
 
# Configure home, user, and working dir
export OS_NAME=ubuntu
echo "Setting default shell for $USER to zsh..."
ZSH_PATH="/bin/zsh"
if id "$USER" &>/dev/null; then
  # Change default shell to zsh for existing user
  if getent passwd "$USER" | cut -d: -f7 | grep -q "$ZSH_PATH"; then
    usermod -s "$ZSH_PATH" "$USER"
  fi
else
  # Add user with default zsh shell when doesn't exist
  useradd -m -s "$ZSH_PATH" "$USER"
fi
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo EDITOR='tee -a' visudo
export HOME=/home/$USER
export CODESPACE=codespace
export RUSER=root
export RHOME=/root

# Create codespace directory
echo "Creating $HOME/$CODESPACE directory..."
mkdir -p $HOME/$CODESPACE

# Clone dotfiles from public repo
echo "Cloning personal dotfiles from tw-studio..."
git clone https://github.com/tw-studio/dotfiles $HOME/.dotfiles

# Install and configure oh-my-zsh
echo "Installing and configuring oh-my-zsh..."
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
echo "Installing fzf..."
git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf
cp -r $HOME/.fzf $RHOME/.fzf
$HOME/.fzf/install --all || true
rm -f $HOME/.bashrc $HOME/.fzf/code.bash
rm -f $RHOME/.bashrc $RHOME/.fzf.bash

# Configure neovim
echo "Configuring neovim..."
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
echo "Configuring tmux..."
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
echo "Cleaning up..."
rm -rf $HOME/.dotfiles

# Give user their stuff
echo "Giving user ownership of their directory..."
chown -R $USER $HOME

# Set default shell for root
echo "Setting default shell for root..."
perl -i -pe 's:/bin/bash:/bin/zsh:' /etc/passwd

# Fix insecure completion-dependent directories permissions
echo "Fixing insecure completion-dependent directories permissions..."
chmod g-w,o-w $HOME/.oh-my-zsh
chmod g-w,o-w $RHOME/.oh-my-zsh

# Start zsh in codespace
# mkdir -p $HOME/$CODESPACE
# cd $HOME/$CODESPACE
# su - $USER -c "zsh"
