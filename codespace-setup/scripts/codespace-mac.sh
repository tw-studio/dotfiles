#!/bin/zsh
# This zsh script sets up a codespace environment on Mac.

set -e

###
##
# MARK: To Do

# !!! All steps must be idempotent

# [ ] Set global variables
# [x] Create codespace directory in $HOME
# [ ] Clone private codespace directory
# [x] Install homebrew
# [x] Install packages from homebrew
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
# [x] Change default shell to zsh installed by Homebrew
# [x] Clone dotfiles from public repo
# [x] Install and configure oh-my-zsh
# [x] Install and configure neovim
# [ ] Associate caps lock key with Esc
# [x] Configure tmux
# [ ] Make vsc-tmux startup script accessible
# [x] Install fzf
# [ ] Generate SSH keys for GitHub and add to SSH agent
# [ ] Configure git global config
# [ ] Install VSCode
      # [ ] Download and install VSCode
      # [ ] Install VSCode extensions
      # [ ] Import personal settings and keybindings files
# [ ] Install personal fonts
# [x] Install and configure iTerm2
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
# MARK: Parse args for verbose and define trace helper

for arg in "$@"; do
  if [[ "$arg" == "-v" || "$arg" == "--verbose" ]]; then
    VERBOSE=true
  fi
done

trace() {
  if [[ "$VERBOSE" == true ]]; then
    set -x
    "$@"
    { set +x; } 2>/dev/null
  else
    "$@"
  fi
}
  

###
##
# MARK: Global configuration and prechecks

if [[ -z "$CODESPACE" ]]; then
  echo "Setting environment variables..."
  export CODESPACE=$HOME/codespace
  export DOTFILES=$CODESPACE/dotfiles
fi

if ! command -v curl &>/dev/null; then
  echo "Error: curl is not installed or not in PATH." >&2
  exit 1
fi


###
##
# MARK: Create codespace directory

if [[ ! -d $CODESPACE ]]; then
  echo "Creating '$CODESPACE' directory..."
  mkdir -p $CODESPACE
else
  echo "Directory '$CODESPACE' already exists."
fi

###
##
# MARK: Set up Homebrew

# > MARK: Install Homebrew
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..." 
  trace /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Homebrew already installed."
fi

# > MARK: Ensure brew is available
if ! command -v brew &>/dev/null; then
  if [[ -d "/opt/homebrew/bin" ]]; then
    trace eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -d "/usr/local/bin" ]]; then
    trace eval "$(/usr/local/bin/brew shellenv)"
  else
    echo "Error: could not find brew executable after installation." >&2
    exit 1
  fi
fi

# > MARK: Install packages
echo "Installing Homebrew packages..."
trace brew install \
  coreutils \
  fd \
  fzf \
  gawk \
  git \
  n \
  neovim \
  pdm \
  perl \
  pnpm \
  rename \
  ripgrep \
  tesseract \
  tmux \
  tree \
  typescript \
  util-linux \
  wget \
  zsh
trace brew install --cask iterm2
if ! command -v git &>/dev/null; then
  echo "Error: git not properly installed." >&2
  exit 1
fi

###
##
# MARK: Clone dotfiles

if [[ ! -d "$DOTFILES" ]]; then
  echo "Cloning dotfiles..."
  trace git clone https://github.com/tw-studio/dotfiles $DOTFILES
else
  echo "Directory '$DOTFILES' already exists."
fi

###
##
# MARK: Install oh-my-zsh

OMZ=$HOME/.oh-my-zsh
if [[ ! -d "$OMZ" ]]; then
  echo "Installing oh-my-zsh..."
  export ZSH=$OMZ
  export SHELL=/bin/zsh
  trace sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  trace cp $DOTFILES/zsh/.zshrc $HOME/
  trace cp $DOTFILES/zsh/codespace*.zsh-theme $ZSH/themes/
else
  echo "Directory '$OMZ' found, oh-my-zsh already installed."
fi

# MARK: Install zshmarks
ZSHMARKS=$ZSH/custom/plugins/zshmarks
if [[ ! -d "$ZSHMARKS" ]]; then
  echo "Installing zshmarks..."
  trace git clone https://github.com/jocelynmallon/zshmarks $ZSHMARKS
else
  echo "Directory '$ZSHMARKS' already exists, zshmarks already installed."
fi
 
###
##
# MARK: Install fzf and remove .bashrc

if ! command -v fzf &>/dev/null; then
  echo "Installing fzf..."
  trace git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf
  trace $HOME/.fzf/install --all || true
  trace rm -f $HOME/.bashrc $HOME/.fzf.bash
else
  echo "fzf already installed."
fi

###
##
# MARK: Configure neovim

if [[ ! -d "$HOME/.config/nvim/colors" ]]; then
  echo "Configuring neovim..."
  trace mkdir -p $HOME/.config/nvim/colors \
   && mkdir -p $HOME/.local/share/nvim/site/autoload \
   && cp $DOTFILES/neovim/init.vim $HOME/.config/nvim/ \
   && cp $DOTFILES/neovim/monokai-fusion.vim $HOME/.config/nvim/colors/ \
   && cp $DOTFILES/neovim/plug.vim $HOME/.local/share/nvim/site/autoload/ \
   && cp $DOTFILES/neovim/dracula-airline.vim $HOME/.config/nvim/dracula.vim \
   && cp $DOTFILES/neovim/dracula.vim $HOME/.config/nvim/colors/
  trace nvim --headless +PlugInstall +qall
else
  echo "neovim already configured."
fi

###
##
# MARK: Configure tmux

TPM=$HOME/.tmux/plugins/tpm
if [[ ! -d "$TPM" ]]; then
  echo "Configuring tmux..."
  cp $DOTFILES/tmux/.tmux.conf $HOME/
  git clone https://github.com/tmux-plugins/tpm $TPM
  tmux start-server \
   && tmux new-session -d \
   && sleep 1 \
   && $HOME/.tmux/plugins/tpm/scripts/install_plugins.sh \
   && tmux kill-server
else
  echo "tmux already configured."
fi
TMUXSCRIPTS=$HOME/.tmux/scripts
if [[ ! -d "$TMUXSCRIPTS" ]]; then
  echo "Configuring tmux scripts..."
  mkdir -p $TMUXSCRIPTS \
   && cp -r $DOTFILES/tmux/scripts $HOME/.tmux/
else
  echo "tmux scripts already configured."
fi

# MARK: Make vsc-tmux startup script accessible
if [[ ! -x "$CODESPACE/scripts/vsc-tmux.sh" ]]; then
  echo "Making vsc-tmux accessible..."
  mkdir -p $CODESPACE/scripts
  cp $DOTFILES/vscode/vsc-tmux.sh $CODESPACE/scripts/
  chmod +x $CODESPACE/scripts/vsc-tmux.sh
else
  echo "vsc-tmux already accessible."
fi

###
##
# MARK: Install node, pnpm, and pm2

if ! command -v pnpm &>/dev/null; then
  echo "Installing node, pnpm, and pm2..."
  trace curl -fsSL https://raw.githubusercontent.com/tw-studio/dotfiles/main/scripts/install-node-pnpm.zsh | zsh
else
  echo "pnpm already installed."
fi

###
##
# MARK: Install personal fonts

FONT_DIR="$HOME/Library/Fonts"
FONT1="MesloLGLDZNerdFontMono-Bold.ttf"
FONT2="RobotoMonoNerdFontMono-Medium.ttf"

if [[ ! -f "$FONT_DIR/$FONT1" ]]; then
  echo "Installing personal fonts..."
  trace curl -fsSL -o "$FONT_DIR/$FONT1" "https://raw.githubusercontent.com/tw-studio/dotfiles/main/assets/fonts/$FONT1"
  echo "Installed $FONT1."
  trace curl -fsSL -o "$FONT_DIR/$FONT2" "https://raw.githubusercontent.com/tw-studio/dotfiles/main/assets/fonts/$FONT2"
  echo "Installed $FONT2."
else
  echo "Personal fonts already installed."
fi

###
##
# MARK: Housekeeping

echo "Giving user ownership of their directory..."
chown -R $USER $HOME

###
##
# MARK: Start zsh in codespace

echo "Starting in codespace..."
cd $CODESPACE
zsh

