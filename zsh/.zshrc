################################################################
#
#   ZSH setup
#
################################################################

# Path to your oh-my-zsh installation
export ZSH=$HOME/.oh-my-zsh

# Set zsh variables
# ------------------------------------------------------------
if [[ $USER == 'root' ]]; then
  ZSH_THEME="codespace256-rt"
else
  ZSH_THEME="codespace256"
fi
DISABLE_AUTO_UPDATE="true"
DISABLE_AUTO_TITLE="true"

# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
plugins=(git zshmarks)

# Configure plugins
#zsshagent1# zstyle :omz:plugins:ssh-agent identities SSH_IDENTITY
#zsshagent2# plugins=(ssh-agent)
#keychain# eval $(keychain -q --eval --agents ssh SSH_IDENTITY)

source $ZSH/oh-my-zsh.sh

# Set Vim bindings for zsh line editor (zle)
# ------------------------------------------------------------
# Activate vim mode
bindkey -v

# Remove mode switching delay
export KEYTIMEOUT=1

# Fix backspace not deleting before start of insert
bindkey -M viins '^?' backward-delete-char
bindkey -M viins '^H' backward-delete-char

# Change cursor shape for different vi modes.
function zle-line-init zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
      [[ $1 = 'block' ]]; then
    echo -ne '\033[2 q'

  elif [[ ${KEYMAP} == main ]] ||
        [[ ${KEYMAP} == viins ]] ||
        [[ ${KEYMAP} = '' ]] ||
        [[ $1 = 'beam' ]]; then
    echo -ne '\033[6 q'
  fi
}
zle -N zle-line-init
zle -N zle-keymap-select

# Use beam shape cursor on startup.
echo -e '\033[6 q'


################################################################
#
#   Personal configuration
#
################################################################

#   Set PATH
#   ------------------------------------------------------------
    path+=("/usr/bin")
    path+=("/usr/local/bin")
    path+=("/usr/sbin")
    path+=("/usr/local/sbin")
    if command -v wslpath &> /dev/null; then
      path+=("/mnt/c/Windows/System32")
    fi
    # typeset -aU path    # dedupes PATH ## PLACED AT END OF FILE

#   Configure node
#   ------------------------------------------------------------
    if command -v pnpm &> /dev/null; then
      export PNPM_HOME="$HOME/.local/share/pnpm"
      path+=("$(dirname $(command -v pnpm))")
      path+=("$(pnpm bin)")
      path+=("$PNPM_HOME")
    fi
    if [[ -f $HOME/.nvm/nvm.sh && -s $HOME/.nvm/nvm.sh ]]; then
      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
    fi
    if command -v yarn &> /dev/null; then
      path+=("$(yarn global bin)")
    fi

#   Export environment variables
#   -----------------------------------------------------------
    export CODESPACE=$HOME/codespace
    export LANG=en_US.UTF-8
    export LANGUAGE=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
    if command -v wslpath &> /dev/null; then
      export WINHOME=$(wslpath $(cmd.exe /C "echo %USERPROFILE%" 2>/dev/null | tr -d '\r'))
    fi

#   Navigate to codespace
#   ------------------------------------------------------------
    export START=$CODESPACE
    if [[ $PWD == $HOME ]]; then
      cd $START
    fi

#   Set default editor
#   ------------------------------------------------------------
    export EDITOR=nvim
    export NVIM=nvim
    if command -v wslpath &> /dev/null; then
      export VS="$WINHOME/AppData/Local/Programs/Microsoft VS Code/bin/code"
    else
      export VS="/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code"
    fi

#   Add color to terminal
#   ------------------------------------------------------------
    export CLICOLOR=1                   # Ansi Colors for iTerm2
#   Set LS_COLORS to default LSCOLORS values for coreutils ls
    export LSCOLORS=Gxfxcxdxbxegedabagacad             # default
    export LS_COLORS='di=1;36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'

#   Configure TERM variable
#   ------------------------------------------------------------
    if [[ "$OSTYPE" == "darwin"* || -n "$WT_SESSION" || -n "$TMUX" ]]; then
      export TERM=screen-256color   # Desired for Mac (iTerm2), Windows Terminal, and tmux
    else
      export TERM=xterm-256color    # Better in more basic terminals like Ubuntu app on Windows
    fi

#   Configure neovim
#   ------------------------------------------------------------
    set runtimepath^=~/.config/nvim

#   Autoloads
#   ------------------------------------------------------------
    autoload zmv

#   Personal Aliases
#   ------------------------------------------------------------
    alias ....='cd ..; cd ..; cd ..'
    alias ...='cd ..; cd ..'
    alias ..='cd ..'
    alias addnode="curl -fsSL https://raw.githubusercontent.com/tw-studio/dotfiles/main/misc-scripts/install-node-pnpm.sh | zsh"
    alias bm="bookmark"                         # zshmarks plugin
    alias code='cd ~/codespace'
    alias codespace='cd ~/codespace'
    alias cp='cp -iv'                           # Preferred 'cp' implementation - requires confirm
    alias ddss='find . -type f -name ".DS_Store" -delete'
    alias dm="deletemark"                       # zshmarks plugin
    alias dzi="find . -type f -name \"*:Zone.Identifier\" -delete"
    alias fd='fdfind --hidden'
    # Fix git when wsl corrupts and empties object
    alias gitfix="find .git/objects/ -type f -empty | xargs rm; git fetch -p; git fsck --full"
    alias gm="jump"                             # zshmarks plugin
    alias lr="ls -Rlp | awk '{ if (NF==1) print \$0; } { if (NF>2) print \$NF; } { if (NF==0) print \$0; }'"
    alias ls='ls -Ahv --color --group-directories-first'
    alias lsd='ls -Adh *(/) --color'            # list only directories
    alias m="fg"
    alias mkdir='mkdir -pv'                     # Preferred 'mkdir' implementation - doesn't clobber existing
    alias mv='mv -iv'                           # Preferred 'mv' implementation - requires confirm
    alias nv='nvim'
    alias nvz='nvim -o `fzf`'
    alias path='echo -e ${PATH//:/\\n}'         # path:         Echo all executable Paths
    if command -v xclip &> /dev/null; then
      alias pbcopy='xclip -selection clipboard'
      alias pbpaste='xclip -selection clipboard -o'
    fi
    alias power='sudo powermetrics --samplers smc -i1 -n1'
    alias pn="pnpm"
    alias rg="rg --hidden --max-columns 200"
    alias rgni="\rg --hidden --no-ignore -g '!{.git,node_modules}' --max-columns 200"
    alias rm='rm -i'                            # Preferred 'rm' implementation - requires confirm
    alias rmhio='rm -f *.hi && rm -f *.o'       # haskell
    alias sm="showmarks"                        # zshmarks plugin
    alias sshc="nv ~/.ssh/config"
    alias ssho="ssh -o \"IdentitiesOnly=yes\""
    alias temp="cd $CODESPACE/tempspace"
    alias timeout90="timeout --preserve-status --kill-after=90s 90s"
    alias tm="tmux ls"
    alias tm#="tmux attach #"
    alias tma="tmux attach -t"
    alias tmac="tmux new -s codespace || tmux attach -t codespace"
    alias tmat="tmux attach -t"
    alias tmnp="~/.tmux/scripts/new-tmux-panes.zsh"
    alias tmns="~/.tmux/scripts/new-tmux-session-window-panes.zsh"
    alias tmnw="~/.tmux/scripts/new-tmux-window-panes.zsh"
#   alias tmux="TERM=screen-256color-bce tmux"
    alias tmuxname='tmux display-message -p "#S"'
    alias tmvsc="~/.tmux/scripts/vsc-tmux.sh"
    alias tree='tree -a -I node_modules --noreport'
    alias vedit='vs ~/.zshrc'
    alias vnvim='vs ~/.config/nvim/init.vim'
    alias vs='$VS'
    alias vtmux='vs ~/.tmux.conf'
    alias zedit='$EDITOR ~/.zshrc'
    alias znvim='$EDITOR ~/.config/nvim/init.vim'
    alias zreload='source ~/.zshrc'
    alias ztmux='$EDITOR ~/.tmux.conf'

#   Set cursor style (https://invisible-island.net/xterm/ctlseqs/ctlseqs.html#h2-Operating-System-Commands)
#   ------------------------------------------
    alias cursor1='echo -e "\033[1 q"'   # blinking block (default)
    alias cursor2='echo -e "\033[2 q"'   # steady block
    alias cursor3='echo -e "\033[3 q"'   # blinking underline
    alias cursor4='echo -e "\033[4 q"'   # steady underline
    alias cursor5='echo -e "\033[5 q"'   # blinking bar (xterm)
    alias cursor6='echo -e "\033[6 q"'   # steady bar (xterm)

#   Personal Functions
#   ------------------------------------------
    # better cd
    altercd(){ cd(){ unset -f cd ; cd $*; ls ; altercd; } } ; altercd
    revertcd(){ cd(){ unset -f cd; cd $*; } }
    qcd(){ unset -f cd; cd $*; altercd; }
    cl() { cd "$@" && ls; }
    cs() { cd "$@" && ls; }

    # dall - delete all silly things
    dall() {
      ddss    # .DS_Store
      dzi     # Zone.Identifier
    }

    # key - add identity to funtoo/keychain
    key() {
      eval $(keychain -q --eval --agents ssh "$1")
    }

    # open - mimics Mac open in Ubuntu WSL
    if command -v wslpath &> /dev/null; then
      open() {
        # Require only one argument
        if [[ $# -ne 1 ]]; then
            echo "Usage: open <path>"
            return 1
        fi

        # Check if the path is valid
        if [[ ! -e "$1" ]]; then
            echo "Invalid path: $1"
            return 1
        fi

        # Convert the path to a Windows path
        local win_path=$(wslpath -w "$1")

        # Determine if the path is a file or a directory
        if [[ -d "$1" ]]; then
            # It's a directory, open in File Explorer
            cmd.exe /C start "" "$win_path" > /dev/null 2>&1
        elif [[ -f "$1" ]]; then
            # It's a file, open with the default application
            cmd.exe /C start "" "$win_path" > /dev/null 2>&1
        else
            # Unsupported file type or URL/URI
            echo "Unsupported file type or not a local file/directory path."
            return 1
        fi
      }
    fi

    # snap - archives files and dirs
    # only use 'snap' when /usr/bin/snap not installed (such as on ec2)
    if [[ ! -f /usr/bin/snap ]] && command -v rename &> /dev/null; then
      snap() {
        cp -r "$1" "$1"_WORKING_COPY; 
        # TODO: fix rename regex to also work with hidden files (ex: .env.js)
        rename 's/(.*)(\..*)_WORKING_COPY/$1_'$(date +"%Y-%m-%d-%H%M")'$2/' *_WORKING_COPY;
      }
    fi
    if command -v rename &> /dev/null; then
      snapm() { 
        mv "$1" "$1"_WORKING_COPY >/dev/null; 
        # TODO: fix rename regex to also work with hidden files (ex: .env.js)
        rename -v 's/(.*)(\..*)_WORKING_COPY/$1_'$(date +"%Y-%m-%d-%H%M")'$2/' *_WORKING_COPY;
      }
    fi
    snapdir() { cp -r "$1" "$1"-`date +%Y-%m-%d-%H%M` }

    # vsr - starts given file or directory in vscode --remote wsl+Ubuntu mode
    # NOTE: not needed when invoking vs with bin/code instead of Code.exe
    vsr() {
      # Check if an argument was provided
      if [ -z "$1" ]; then
        echo "Usage: vsr <path-to-file-or-directory>"
        return 1
      fi

      local path_arg="$1"

      # Expand the tilde to the user's home directory
      if [[ "$path_arg" == ~* ]]; then
        path_arg="${path_arg/#\~/$HOME}"
      fi

      # Resolve potential relative paths or symbolic links
      path_arg=$(realpath "$path_arg")

      # Ensure the path exists
      if [ ! -e "$path_arg" ]; then
        echo "The path '$path_arg' does not exist."
        return 1
      fi

      # Execute the VS Code Remote command
      vs --remote wsl+Ubuntu "$path_arg"
    }

    # winvar - echo value of Windows environment variable
    winvar() {
      echo $(wslpath $(cmd.exe /C "echo %$1%" 2>/dev/null | tr -d '\r'))
    }

#   fzf configuration
#   ------------------------------------------
    if [[ $OS_NAME == "ubuntu" ]]; then
      export FZF_DEFAULT_COMMAND="fdfind --hidden --type f --exclude node_modules --exclude .git"
      export FZF_ALT_C_COMMAND="fdfind --hidden --type d . $HOME"
    else
      export FZF_DEFAULT_COMMAND="fd --hidden --type f --exclude node_modules --exclude .git"
      export FZF_ALT_C_COMMAND="fd --hidden --type d . $HOME"
    fi
    export FZF_DEFAULT_OPTS='--height 60% --layout=reverse --border'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

    # Source key bindings etc
    [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

    # fh - search in your command history and execute selected command
    fh() {
      eval $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
    }

#   Source ec2 environment if exists
#   ------------------------------------------
    if [[ -f $HOME/.ec2env ]]; then
      source $HOME/.ec2env
    fi

#   Final steps
#   ------------------------------------------
    typeset -aU path    # dedupes path

