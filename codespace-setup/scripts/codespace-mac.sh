#!/bin/zsh
# This zsh script sets up a codespace environment on Mac.

set -e

###
##
# MARK: To Do

# !!! All steps must be idempotent

# [x] Install personal fonts
# [x] Install iTerm2
# [-] Set iTerm2 font to Meslo
# [ ] Install Mullvad VPN
# [ ] Install Malwarebytes
# [ ] Install VeraCrypt
# [ ] Set dock to right side
# [ ] Set wallpaper
# [ ] Set Screenshots directory
# [ ] Hide Desktop files
# [-] Set system color
##### P2
# [ ] Install Parallels and Windows (P2)
# [ ] Install Hand Mirror (P2)
##### P3
# [ ] Install Quick Shade (P3)
# [ ] Install and configure pdm and python (P3)
##### Clean up

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
# [ ] 4. Set Safari new windows to be New Private Windows

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

echo "Setting environment variables..."
[[ -z "$CODESPACE" ]] && export CODESPACE=$HOME/codespace
[[ -z "$DOTFILES" ]] && export DOTFILES=$CODESPACE/dotfiles

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
  jq \
  mkcert \
  n \
  neovim \
  pdm \
  perl \
  pngquant \
  pnpm \
  rename \
  ripgrep \
  tesseract \
  tmux \
  tree \
  typescript \
  util-linux \
  wget \
  woff2 \
  zsh
trace brew install --cask iterm2
trace brew install --cask visual-studio-code
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

# Install zshmarks
ZSHMARKS=$ZSH/custom/plugins/zshmarks
if [[ ! -d "$ZSHMARKS" ]]; then
  echo "Installing zshmarks..."
  trace git clone https://github.com/jocelynmallon/zshmarks $ZSHMARKS
else
  echo "Directory '$ZSHMARKS' already exists, zshmarks already installed."
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
  # Transfer main tmux config
  cp $DOTFILES/tmux/.tmux.conf $HOME/
  # Clone tmux plugin manager
  git clone https://github.com/tmux-plugins/tpm $TPM
  # Start a temporary tmux server so TPM can install plugins
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
  mkdir -p $TMUXSCRIPTS
  # Transfer scripts directory and make scripts executable
  if [[ -d "$DOTFILES/tmux/scripts" ]]; then
    cp -r $DOTFILES/tmux/scripts $HOME/.tmux/
    chmod +x $TMUXSCRIPTS/*sh
  else
    echo "Not found: $DOTFILES/tmux/scripts. Skipping tmux scripts configuration."
  fi
else
  echo "tmux scripts already configured."
fi

###
##
# MARK: Configure git

REPO="tw-studio"
REPO_KEY="$HOME/.ssh/$REPO"

# > MARK: .gitconfig

if [[ -f $HOME/.gitconfig ]] && grep -q "main" $HOME/.gitconfig; then
  echo "gitconfig already configured."
else
  echo "Configuring git with personal .gitconfig..."
  cp $DOTFILES/git/.gitconfig $HOME/
fi

# > MARK: git authentication

# |1| Configure ~/.ssh/config
if [[ ! ( -d "$HOME/.ssh" && -f "$HOME/.ssh/config" ) ]]; then
  echo "Configuring .ssh config..."
  mkdir -p $HOME/.ssh
  cp $DOTFILES/git/.ssh-config $HOME/.ssh/config
else
  echo ".ssh config already configured."
fi

# |2| Create keyfiles
if [[ ! ( -f "$REPO_KEY" && -f "$REPO_KEY.pub" ) ]]; then
  echo "Creating keys for $REPO (upload public key to GitHub)..."
  ssh-keygen -t ed25519 -f "$REPO_KEY" -C "$REPO"
else
  echo "Keys for $REPO already created."
fi

# |3| Add to keychain
if ! ssh-add -l 2>/dev/null | grep -q "$REPO"; then
  echo "Adding $REPO key to keychain..."
  ssh-add --apple-use-keychain "$REPO_KEY"
else
  echo "Key already loaded in ssh-agent."
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
# MARK: Configure VSCode

# > MARK: Configure $CODE to use in this script

CODE="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
if [[ ! -x "$CODE" ]]; then
  echo "Error: Could not find VSCode CLI at: $CODE"
  echo "If VSCode is installed, run in VSCode:"
  echo "   Command Palette → Shell Command: Install 'code' command in PATH"
  exit 1
fi

# > MARK: Ensure VS Code is fully closed before continuing

wait_for_vs_code_exit() {
  for _ in {1..20}; do
    if ! pgrep -f "Visual Studio Code" \
       && ! pgrep -f "Code Helper" \
       && ! pgrep -f "Electron" \
       && ! pgrep -f "code --list-extensions"; then
      return 0
    fi
    sleep 0.25
  done
  return 1
}
DO_VSCODE_SETUP=true
if pgrep -f "Visual Studio Code" >/dev/null || pgrep -f "Code Helper" >/dev/null; then
  echo "VS Code is running. To apply configurations, VS Code must be closed."
  echo "(If the shell running this script was directly launched by VS Code, then closing VS Code will stop the script.)"
  read -r "RESP?Close VS Code now? (y/N): "
  case "$RESP" in
    [Yy]* )
      echo "Ensuring all VS Code processes are stopped..."
      set +e
      pkill -f "Visual Studio Code"        2>/dev/null
      pkill -f "Code Helper"               2>/dev/null
      pkill -f "Electron Helper"           2>/dev/null
      pkill -f "Electron"                  2>/dev/null
      pkill -f "code --list-extensions"    2>/dev/null
      set -e
      if ! wait_for_vs_code_exit; then
        echo "Warning: Some VS Code processes refused to exit."
        echo "Skipping VS Code configuration."
        DO_VSCODE_SETUP=false
      else
        echo "VS Code is closed."
      fi
      ;;
    * )
      DO_VSCODE_SETUP=false
      ;;
  esac
else
  echo "VS Code is already not running."
fi

if [[ "$DO_VSCODE_SETUP" = false ]]; then
  echo "Skipping VS Code configuration."
else

  # > MARK: Install extensions

  EXTENSIONS=(
    "alefragnani.project-manager"
    "asvetliakov.vscode-neovim"
    "ms-vscode-remote.remote-wsl"
    "tw.monokai-accent"
    "dbaeumer.vscode-eslint"
    "dunstontc.viml"
    "geddski.macros"
    "huntertran.auto-markdown-toc"
    "jebbs.markdown-extended"
    "jsynowiec.vscode-insertdatestring"
    "mhutchie.git-graph"
    "ms-python.black-formatter"
    "naumovs.color-highlight"
    "redhat.vscode-yaml"
    "hoovercj.vscode-settings-cycler"
    "spywhere.mark-jump"
    "tyriar.sort-lines"
    "wayou.vscode-todo-highlight"
  )
  INSTALLED_EXTENSIONS="$("$CODE" --list-extensions)"
  echo "Installing VS Code extensions..."
  sleep 1
  for EXT in "${EXTENSIONS[@]}"; do
    if ! echo "$INSTALLED_EXTENSIONS" | grep -q "^$EXT$"; then
      # Doesn't need explicit status; already reported by code
      sleep 0.5
      "$CODE" --install-extension "$EXT"
    else
      sleep 0.1
      echo "Already installed: $EXT"
    fi
  done

  # > MARK: Install personal box-checker extension

  MY_VSIX_ID="tw.box-checker"
  MY_VSIX_FILE="box-checker-0.0.1.vsix"
  MY_VSIX_LOCAL_PATH="$DOTFILES/vscode/$MY_VSIX_FILE"
  # $INSTALLED_EXTENSIONS already exists

  if ! printf "%s\n" "$INSTALLED_EXTENSIONS" | grep -qx "$MY_VSIX_ID"; then
    if [[ ! -f "$MY_VSIX_LOCAL_PATH" ]]; then
      echo "Error: Installer for $MY_VSIX_ID not found at: $MY_VSIX_LOCAL_PATH"
      exit 1
    fi
    echo "Installing extension: $MY_VSIX_ID..."
    "$CODE" --install-extension "$MY_VSIX_LOCAL_PATH"
  else
    echo "Personal extension $MY_VSIX_ID is already installed."
  fi

  # > MARK: Copy personal keybindings and settings

  VSC_USER_DIR="$HOME/Library/Application Support/Code/User"
  VSC_SETTINGS="$VSC_USER_DIR/settings.json"
  VSC_KEYBINDINGS="$VSC_USER_DIR/keybindings.json"
  DATETIME=$(date +"%Y%m%d-%H%M%S")
  mkdir -p "$VSC_USER_DIR"

  # Check if settings was already copied
  if [[ -f "$VSC_SETTINGS" ]] && grep -q 'Monokai +' "$VSC_SETTINGS"; then
    echo "Personal VS Code settings and keybindings already configured."
  else

    # Back up then copy settings and keybindings
    if [[ -f "$VSC_SETTINGS" ]]; then
      echo "Backing up existing settings.json..."
      mv "$VSC_SETTINGS" "$VSC_USER_DIR/settings-$DATETIME.json"
    fi
    if [[ -f "$VSC_KEYBINDINGS" ]]; then
      echo "Backing up existing keybindings.json..."
      mv "$VSC_KEYBINDINGS" "$VSC_USER_DIR/keybindings-$DATETIME.json"
    fi
    echo "Copying in personal VS Code settings and keybindings..."
    cp "$DOTFILES/vscode/mac/settings.json" "$VSC_SETTINGS"
    cp "$DOTFILES/vscode/mac/keybindings.json" "$VSC_KEYBINDINGS"
  fi

  # > MARK: Disable ApplePressAndHold (which prevents repeat key scrolling)

  STATE_APPLE_PRESS_AND_HOLD="$(defaults read -g ApplePressAndHoldEnabled 2>/dev/null || echo 'unset')"
  if [[ "$STATE_APPLE_PRESS_AND_HOLD" != "0" ]]; then
    echo "Disabling ApplePressAndHold (requires VS Code restart)..."
    defaults write -g ApplePressAndHoldEnabled -bool false
  else
    echo "ApplePressAndHoldEnabled already disabled."
  fi

fi # DO_VSCODE_SETUP

###
##
# MARK: Configure fzf

# Create fzf keybindings for zsh
if [[ ! -f "$HOME/.fzf.zsh" ]]; then
  if [[ -f "$(brew --prefix)/opt/fzf/install" ]]; then
    echo "Running fzf install to generate keybindings for zsh..."
    trace $(brew --prefix)/opt/fzf/install --no-bash --no-fish --key-bindings --completion --no-update-rc
  fi
else
  echo "fzf keybindings already generated for zsh."
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
# MARK: macOS settings

# > MARK: Set wallpaper

PERSONAL_WALLPAPER="$DOTFILES/assets/images/abstract-wallpaper.jpg"
if [[ -f "$PERSONAL_WALLPAPER" ]]; then
  if command -v osascript &>/dev/null; then
    CURRENT_WALLPAPER="$(osascript -e 'tell application "System Events" to get picture of current desktop')"
    CURRENT_WALLPAPER_FILENAME="${CURRENT_WALLPAPER##*/}"
    PERSONAL_WALLPAPER_FILENAME="${PERSONAL_WALLPAPER##*/}"
    if [[ "$CURRENT_WALLPAPER_FILENAME" != "$PERSONAL_WALLPAPER_FILENAME" ]]; then
      echo "Setting personal wallpaper..."
      osascript -e 'tell application "System Events" to set picture of every desktop to "'"$PERSONAL_WALLPAPER"'"'
    else
      echo "Personal wallpaper already set."
    fi
  else
    echo "osascript not found. Skipping setting of personal wallpaper."
  fi
else
  echo "Personal wallpaper not found at: $PERSONAL_WALLPAPER"
fi

###
##
# MARK: Housekeeping

echo "Giving user ownership of their codespace directory..."
chown -R $USER $CODESPACE

###
##
# MARK: Start zsh in codespace

echo "Starting in codespace..."
cd $CODESPACE
zsh
