#!/bin/sh
###############################################################################
# 
#     Run script with "dot space syntax" when local:
#     $ . /path/to/codespace-amzn.sh
#
#     Or from github, install better wget, then run with wget:
#     $ yum update && \
#       yum install wget
#     $ sh -c "$(wget https://raw.github.com/...sh -O -)"
#
###############################################################################

# send stdout and stderr to logs file
exec >> /setup_script_logs
exec 2>&1

# echo every command
set -x

# setup on Amazon Linux 2
export OS_NAME=amzn

# Configure home, user, and working dir
export ZUSER=ec2-user
adduser $ZUSER      # fails if exists
export HOME=/home/$ZUSER
export CODESPACE=codespace
export RUSER=root
export RHOME=/root

# stop script when first command fails
set -e

# Install packages
echo "Installing packages..." \
 && yum update -y \
 && amazon-linux-extras install epel -y \
 && yum-config-manager -y --add-repo=https://copr.fedorainfracloud.org/coprs/carlwgeorge/ripgrep/repo/epel-7/carlwgeorge-ripgrep-epel-7.repo \
 && yum install -y \
      autoconf \
      automake \
      byacc \
      gcc \
      git \
      libevent-devel \
      ncurses-devel \
      neovim \
      ripgrep \
      tree \
      zsh \
 && yum clean all -y \
 && rm -rf /var/cache/yum

# Fix locale issues, e.g. with Perl
# sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
#  && dpkg-reconfigure --frontend=noninteractive locales \
#  && update-locale LANG=en_US.UTF-8
# export LANG=en_US.UTF-8 

# Clone dotfiles from public repo
git clone https://github.com/tw-space/dotfiles $HOME/.dotfiles

# Install oh-my-zsh
export ZSH=$HOME/.oh-my-zsh
export RZSH=$RHOME/.oh-my-zsh
export SHELL=/bin/zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
cp -r $ZSH $RZSH
\cp -f $HOME/.dotfiles/zsh/.zshrc $HOME/
\cp -f $HOME/.dotfiles/zsh/.zshrc $RHOME/
cp $HOME/.dotfiles/zsh/codespace.zsh-theme $ZSH/themes/
cp $HOME/.dotfiles/zsh/codespace256.zsh-theme $ZSH/themes/
cp $HOME/.dotfiles/zsh/codespace-rt.zsh-theme $RZSH/themes/
cp $HOME/.dotfiles/zsh/codespace256-rt.zsh-theme $RZSH/themes/
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
 && cp $HOME/.dotfiles/neovim/init.vim $HOME/.config/nvim/ \
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

# Install and configure tmux
git clone https://github.com/tmux/tmux.git $HOME/tmux \
 && cd $HOME/tmux \
 && sh autogen.sh \
 && ./configure \
 && make \
 && make install \
 && cd $HOME \
 && rm -rf $HOME/tmux
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

# Set default shell for user
usermod --shell /bin/zsh $ZUSER
usermod --shell /bin/zsh $RUSER

# Cleanup
rm -rf $HOME/.dotfiles
rm -rf $HOME/tmux

# Make codespace
mkdir $HOME/$CODESPACE
mkdir $RHOME/$CODESPACE

# Write after setup steps
cat << EOF > $HOME/$CODESPACE/README_After_Setup_Steps.md
# After Setup Steps

-   [ ] 1.  Add to \`/etc/sudoers\` via \`sudo visudo\`:

        Defaults    secure_path += /usr/local/bin:/usr/local/sbin

EOF

# Give user their stuff
chown -R $ZUSER $HOME

# Start zsh in codespace
cd $HOME/$CODESPACE
zsh
