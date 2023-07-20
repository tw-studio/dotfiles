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
    export PATH=$PATH:/usr/bin
    export PATH=$PATH:/usr/local/bin
    export PATH=$PATH:/usr/sbin
    export PATH=$PATH:/usr/local/sbin
    #export PATH=$PATH:$(yarn global bin)
    # typeset -aU path    # dedupes PATH ## PLACED AT END OF FILE

#   Export environment variables
#   -----------------------------------------------------------
    export CODESPACE=$HOME/codespace
    export LC_ALL=en_US.UTF-8
    export LANG=en_US.UTF-8
    export LANGUAGE=en_US.UTF-8

#   Navigate to codespace
#   ------------------------------------------------------------
    export START=$CODESPACE
    if [[ $PWD == $HOME ]]; then
        cd $START
    fi

#   Set default editor
#   ------------------------------------------------------------
    export EDITOR=/usr/bin/nvim
    export NVIM=/usr/bin/nvim

#   Add color to terminal
#   ------------------------------------------------------------
    export CLICOLOR=1                   # Ansi Colors for iTerm2   
    export LSCOLORS=Gxfxcxdxbxegedabagacad             # default
#   Set LS_COLORS to default LSCOLORS values for coreutils ls 
    export LS_COLORS='di=1;36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'

#   Configure iTerm2
#   ------------------------------------------------------------
    export TERM=screen-256color   # Match iTerm2 Terminal colors

#   Configure neovim
#   ------------------------------------------------------------
    set runtimepath^=~/.config/nvim

#   Personal Aliases 
#   ------------------------------------------------------------
    alias ....='cd ..; cd ..; cd ..'
    alias ...='cd ..; cd ..'
    alias ..='cd ..'
    alias bm="bookmark"                         # zshmarks plugin
    alias code='cd ~/codespace'
    alias codespace='cd ~/codespace'
    alias cp='cp -iv'                           # Preferred 'cp' implementation - requires confirm
    alias dm="deletemark"                       # zshmarks plugin
    alias fd='fdfind --hidden'
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
    alias rm='rm -i'                            # Preferred 'rm' implementation - requires confirm
    alias rmhio='rm -f *.hi && rm -f *.o'       # haskell
    alias sm="showmarks"                        # zshmarks plugin
    alias tm="tmux ls"
    alias tmac="tmux new -s codespace || tmux attach -t codespace"
    alias tmat="tmux attach -t"
    alias tmnp="~/.tmux/scripts/new-tmux-panes.zsh"
    alias tmns="~/.tmux/scripts/new-tmux-session-window-panes.zsh"
    alias tmnw="~/.tmux/scripts/new-tmux-window-panes.zsh"
    alias tmuxname='tmux display-message -p "#S"'
    alias tree='tree -a -I node_modules --noreport'
    alias zedit='$EDITOR ~/.zshrc'
    alias znvim='$EDITOR ~/.config/nvim/init.vim'
    alias zreload='source ~/.zshrc'
    alias ztmux='$EDITOR ~/.tmux.conf'
   #alias tmux="TERM=screen-256color-bce tmux"

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
    altercd(){ cd(){ unset -f cd ; cd $*; ls ; altercd; } } ; altercd 
    revertcd(){ cd(){ unset -f cd; cd $*; } }
    cl() { cd "$@" && ls; }
    cs() { cd "$@" && ls; }
    snapfile() { cp -r "$1" "$1"-`date +%Y-%m-%d-%H%M` }
    snapdir() { cp -r "$1" "$1"-`date +%Y-%m-%d-%H%M` }

    # fh - search in your command history and execute selected command
    fh() {
        eval $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
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

#   source ec2 environment if exists
#   ------------------------------------------
    if [[ -f $HOME/.ec2env ]]; then
      source $HOME/.ec2env
    fi
    
typeset -aU path    # dedupes path
