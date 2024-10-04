#!/bin/zsh
# This zsh script sets up a codespace environment on Mac.

set -e

###
##
# MARK: To Do

# !!! All steps must be idempotent

# [ ] Set global variables
# [ ] Create codespace directory in $HOME
# [ ] Clone private codespace directory
# [ ] Install homebrew
# [ ] Install packages from homebrew
      # P1
          # coreutils
          # fd
          # fzf
          # gawk
          # git
          # n
          # neovim
          # pdm
          # perl
          # pnpm
          # python@3.11 (as of 9/2024)
          # rename
          # ripgrep
          # tesseract
          # tmux
          # tree
          # typescript
          # wget
          # zsh
      # P2 
          # jq
          # mkcert
          # pandoc
          # pngquant
          # postgresql
          # woff2
          # youtube-dl
# [ ] Change default shell to zsh installed by Homebrew
# [ ] Clone dotfiles from public repo
# [ ] Install and configure oh-my-zsh
# [ ] Install and configure neovim
# [ ] Associate caps lock key with Esc
# [ ] Configure tmux
# [ ] Make vsc-tmux startup script accessible
# [ ] Install fzf
# [ ] Generate SSH keys for GitHub and add to SSH agent
# [ ] Configure git global config
# [ ] Install VSCode
      # [ ] Download and install VSCode
      # [ ] Install VSCode extensions
      # [ ] Import personal settings and keybindings files
# [ ] Install personal fonts
# [ ] Install and configure iTerm2
# [ ] Install Mullvad VPN
# [ ] Install Malwarebytes
# [ ] Install VeraCrypt
# [ ] Set dock to right side
# [ ] Set wallpaper
# [ ] Set system color
##### P2
# [ ] Install node, pnpm, and pm2 (does it need n installed earlier?) (P2)
# [ ] Install Parallels and Windows (P2)
# [ ] Install Hand Mirror (P2)
##### P3
# [ ] Install Quick Shade (P3)
# [ ] Install and configure pdm and python (P3)
##### Clean up
# [ ] Clean up dotfiles
# [ ] Give user their stuff
# [ ] Start zsh in codespace

# Scratch from before:

# [ ] 1. Add steps for installing Meslo LG font
# [ ] 2. Customize .zshrc for Mac:
    # [ ] 1. Change ls to gls
    # [ ] 2. Add ZSH_DISABLE_COMPFIX="true" *if* configuring multiple user on same Mac
# [ ] 3. Add steps for installing powerline icons font for neovim
# [ ] 4. Add steps for installing and configuring VSCode (OPTIONAL: set up Settings sync)

# |0| Preparation steps to take on mac first:

# [ ] 1. First, know that you should *not* use Homebrew across multiple users on same Mac
# [ ] 2. Rebind Esc to Caps Lock key in System Preferences > Keyboard > Keyboard > Modifier Keys...
# [ ] 3. In Safari, click View > Show Status Bar

###
##
# MARK: Global variables

echo "Configuring variables..."
export CODESPACE=$HOME/codespace

###
##
# MARK: Create codespace directory

if [[ -d $CODESPACE ]]; then
  echo "Directory '$CODESPACE' already exists."
else
  echo "Creating '$CODESPACE' directory..."
  mkdir -p $CODESPACE
fi


# |2| Install Homebrew and packages only if sole user on Mac (otherwise expect most packages already installed)

# TODO: add prompt for user input

# # |a| Install Homebrew
#
# echo "Installing Homebrew..." 
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# 
# # |b| Install packages
# 
# echo "Installing packages..." \
#  && set -x \
#  && brew install \
#      ca-certificates \
#      coreutils \
#      fd-find \
#      locales \
#      ncurses-base \
#      neovim \
#      ripgrep \
#      tmux \
#      tree \
#      util-linux \
#      zsh \
#  && set +x

# |3| Clone dotfiles from public repo

echo "Cloning dotfiles..."
git clone https://github.com/tw-space/dotfiles $HOME/.dotfiles

# |4| Install oh-my-zsh

echo "Installing oh-my-zsh..."
export ZSH=$HOME/.oh-my-zsh
export SHELL=/bin/zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
cp $HOME/.dotfiles/zsh/.zshrc $HOME/
cp $HOME/.dotfiles/zsh/codespace*.zsh-theme $ZSH/themes/
git clone https://github.com/jocelynmallon/zshmarks $ZSH/custom/plugins/zshmarks
 
# |5| Install fzf

echo "Installing fzf..."
git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf
$HOME/.fzf/install --all || true
rm -f $HOME/.bashrc $HOME/.fzf.bash

# |6| Configure neovim

echo "Configuring neovim..."
mkdir -p $HOME/.config/nvim/colors \
 && mkdir -p $HOME/.local/share/nvim/site/autoload \
 && cp $HOME/.dotfiles/neovim/init.vim $HOME/.config/nvim/ \
 && cp $HOME/.dotfiles/neovim/monokai-fusion.vim $HOME/.config/nvim/colors/ \
 && cp $HOME/.dotfiles/neovim/plug.vim $HOME/.local/share/nvim/site/autoload/ \
 && cp $HOME/.dotfiles/neovim/dracula-airline.vim $HOME/.config/nvim/dracula.vim \
 && cp $HOME/.dotfiles/neovim/dracula.vim $HOME/.config/nvim/colors/
nvim --headless +PlugInstall +qall

# |7| Configure tmux

echo "Configuring tmux..."
cp $HOME/.dotfiles/tmux/.tmux.conf $HOME/
git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
tmux start-server \
 && tmux new-session -d \
 && sleep 1 \
 && $HOME/.tmux/plugins/tpm/scripts/install_plugins.sh \
 && tmux kill-server
mkdir -p $HOME/.tmux/scripts \
 && cp -r $HOME/.dotfiles/tmux/scripts $HOME/.tmux/

# |8| Cleanup

echo "Cleaning up..."
rm -rf $HOME/.dotfiles

# |9| Start zsh in codespace

mkdir -p $HOME/$CODESPACE
cd $HOME/$CODESPACE
zsh

