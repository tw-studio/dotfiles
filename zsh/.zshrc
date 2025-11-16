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
# if [[ $TMUX_IN_VSCODE != "1" ]]; then
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
# fi

################################################################
#
#   Personal configuration
#
################################################################

#   Set general environment variables
#   -----------------------------------------------------------
    export CODESPACE=$HOME/codespace
    export DOTFILES=$CODESPACE/dotfiles
    if command -v brew &>/dev/null; then
      export HOMEBREW_PREFIX="$(HOMEBREW_NO_AUTO_UPDATE=1 brew --prefix)"
    fi
    export LANG=en_US.UTF-8
    export LANGUAGE=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
    if command -v wslpath &>/dev/null; then
      export WINHOME=$(wslpath $(cmd.exe /C "echo %USERPROFILE%" 2>/dev/null | tr -d '\r'))
      export WINSPACE=$WINHOME/winspace
      export POWERSHELL_PROFILE=$WINHOME/Documents/PowerShell/Microsoft.PowerShell_profile.ps1
    fi
    if [[ -z "$OS_NAME" ]] && [[ -f /etc/os-release ]]; then
      export OS_NAME=$(awk -F= '$1=="NAME" {gsub(/"/, "", $s); print $2}' /etc/os-release)
    fi

#   Set PATH
#   ------------------------------------------------------------
    path+=("/usr/bin")
    path+=("/usr/local/bin")
    path+=("/usr/sbin")
    path+=("/usr/local/sbin")
    [[ -d "$HOME/.local/bin" ]] && path+=("$HOME/.local/bin")
    [[ -d "$CODESPACE/scripts/global-scripts" ]] && path+=("$CODESPACE/scripts/global-scripts")
    [[ -d "/Applications/Docker.app/Contents/Resources/bin" ]] && path+=("/Applications/Docker.app/Contents/Resources/bin")
    if [[ -n "$HOMEBREW_PREFIX" ]] && [[ -d "$HOMEBREW_PREFIX/opt/gawk/libexec/gnubin" ]]; then
      path=("$HOMEBREW_PREFIX/opt/gawk/libexec/gnubin" $path[@])
    fi
    if command -v wslpath &> /dev/null; then
      path+=("/mnt/c/Windows/System32")
      path+=("$WINHOME/AppData/Local/Microsoft/WindowsApps")
    fi
    # typeset -aU path                    # dedupes PATH ## PLACED AT END OF FILE
    # path=("/usr/local/bin" $path[@])    # JFYI: this is how to prepend

#   Configure editors
#   ------------------------------------------------------------
    export EDITOR=nvim
    export NVIM=nvim
    set runtimepath^=~/.config/nvim
    if command -v wslpath &> /dev/null; then
      export VS="$WINHOME/AppData/Local/Programs/Microsoft VS Code/bin/code"
    else
      export VS="/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code"
    fi

#   Configure terminal
#   ------------------------------------------------------------
    if [[ "$OSTYPE" == "darwin"* || -n "$WT_SESSION" || -n "$TMUX" ]]; then
      export TERM=screen-256color   # Desired for Mac (iTerm2), Windows Terminal, and tmux
    else
      export TERM=xterm-256color    # Better in more basic terminals like Ubuntu app on Windows
    fi
    export CLICOLOR=1                   # Ansi Colors for iTerm2
    export LSCOLORS=Gxfxcxdxbxegedabagacad             # default
    # Set LS_COLORS to default LSCOLORS values for coreutils ls
    export LS_COLORS='di=1;36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'
    # Set iTerm2 default profile plist to enable mouse scroll
    if command -v defaults &>/dev/null && ! defaults read com.googlecode.iterm2 AlternateMouseScroll &>/dev/null; then
      defaults write com.googlecode.iterm2 AlternateMouseScroll -bool true
    fi

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

#   Configure AWS
#   ------------------------------------------------------------
    # export AWS_PROFILE=codespace
    # export AWS_PROFILE=codespace-23
    # export AWS_PROFILE=just-learning
    export AWS_PROFILE=codespace-24
    export SAM_CLI_TELEMETRY=0      # opt-out of AWS SAM telemetry

#   Enable PEP 582 for pdm
#   ------------------------------------------------------------
    # eval "$(pdm --pep582)"
    # pdm_path='/usr/local/Cellar/pdm/2.8.0/libexec/lib/python3.11/site-packages/pdm/pep582'
    # Add to PYTHONPATH only when not already there
    # [[ ":$PYTHONPATH:" != *":$pdm_path:"* ]] && export PYTHONPATH="${PYTHONPATH:+$PYTHONPATH:}$pdm_path"

#   Miscellaneous configuration values
#   ------------------------------------------------------------
    export HOMEBREW_AUTO_UPDATE_SECS=2592000 # 30 days

#   runscript: safe remote script runner
#   ------------------------------------------------------------
#   Usage:
#     runscript [-f] [-u] [-n] [-c <sha256>] [-g <expected_keyid>] [-s <sig_url>] URL [-- args...]
#   Options:
#     -f    Force (skip confirm if domain allowlisted)
#     -u    Update cache (re-download even if cached)
#     -n    Dry run (download/verify/show but don't execute)
#     -c    Expected SHA-256 checksum (hex)
#     -g    GPG expected key ID (long or fingerprint) to trust signature
#     -s    Signature URL (defaults to URL+".asc" if -g is set)
#
#   Domain allowlist file: ~/.config/runscript/allowlist.txt (one domain per line)
#   Cache dir: ~/.cache/runscript/

    runscript() {
      emulate -L zsh
      setopt nounset pipefail
      local OPTIND opt force=0 update=0 dry=0 sha256="" gpg_id="" sig_url=""

      while getopts ":f unc:g:s:" opt; do
        case "$opt" in
          f) force=1 ;;
          u) update=1 ;;
          n) dry=1 ;;
          c) sha256="$OPTARG" ;;
          g) gpg_id="$OPTARG" ;;
          s) sig_url="$OPTARG" ;;
          \?) print -u2 -- "runscript: invalid option -$OPTARG"; return 2 ;;
          :)  print -u2 -- "runscript: option -$OPTARG requires an argument"; return 2 ;;
        esac
      done
      shift $((OPTIND-1))

      if (( $# < 1 )); then
        print -u2 -- "Usage: runscript [-f] [-u] [-n] [-c sha256] [-g keyid] [-s sig_url] URL [-- args...]"
        return 2
      fi

      local url="$1"; shift

      # Basic URL validation
      if [[ "$url" != https://* ]]; then
        print -u2 -- "runscript: only https:// URLs are allowed"; return 2
      fi

      # Extract domain
      local domain="${${url#https://}%%/*}"
      # Allowlist setup
      local cfg_dir="${XDG_CONFIG_HOME:-$HOME/.config}/runscript"
      local allowlist="$cfg_dir/allowlist.txt"
      mkdir -p "$cfg_dir"
      touch "$allowlist"

      local allowed=0
      if grep -Eiq "^${domain//./\\.}\$" "$allowlist"; then
        allowed=1
      fi

      # HTTP client
      local have_curl= have_wget=
      command -v curl >/dev/null 2>&1 && have_curl=1 || have_curl=0
      command -v wget >/dev/null 2>&1 && have_wget=1 || have_wget=0
      if (( ! have_curl && ! have_wget )); then
        print -u2 -- "runscript: need curl or wget installed"; return 2
      fi

      # Cache paths
      local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/runscript"
      mkdir -p "$cache_dir"
      local url_hash
      url_hash=$(printf "%s" "$url" | openssl dgst -sha256 -r | awk '{print $1}') || { print -u2 -- "runscript: cannot hash URL"; return 2; }
      local cache_file="$cache_dir/$url_hash.script"
      local etag_file="$cache_dir/$url_hash.etag"
      local lm_file="$cache_dir/$url_hash.lastmod"

      # Download function (respects update flag; saves ETag/Last-Modified when possible)
      local download_script
      download_script() {
        local tmpfile
        tmpfile=$(mktemp -t runscript.XXXXXX) || return 1
        if (( have_curl )); then
          local hdrs=()
          (( update == 0 && -f "$etag_file" )) && hdrs+=(-H "If-None-Match: $(<"$etag_file")")
          (( update == 0 && -f "$lm_file" )) && hdrs+=(-H "If-Modified-Since: $(<"$lm_file")")
          # Download
          if ! curl --fail --location --proto '=https' --tlsv1.2 \
            --connect-timeout 10 --max-time 60 --retry 2 --retry-delay 1 \
            -A "runscript/1.0" "${hdrs[@]}" \
            -D "$tmpfile.headers" -o "$tmpfile.body" "$url" ; then
            rm -f "$tmpfile" "$tmpfile.headers" "$tmpfile.body"
            return 2
          fi
          # Handle 304
          if grep -qE "^HTTP/.* 304 " "$tmpfile.headers" 2>/dev/null; then
            rm -f "$tmpfile" "$tmpfile.headers" "$tmpfile.body"
            return 304
          fi
          # Save headers
          awk -F': ' 'BEGIN{IGNORECASE=1} /^ETag:/{print $2} /^etag:/{print $2}' "$tmpfile.headers" | tr -d '\r' >| "$etag_file" || true
          awk -F': ' 'BEGIN{IGNORECASE=1} /^Last-Modified:/{print $2} /^last-modified:/{print $2}' "$tmpfile.headers" | tr -d '\r' >| "$lm_file" || true
          mv -f "$tmpfile.body" "$cache_file"
          rm -f "$tmpfile" "$tmpfile.headers"
        else
          # wget path
          local hdrtmp
          hdrtmp=$(mktemp -t runscript.hdr.XXXXXX) || return 1
          local ims_args=()
          (( update == 0 && -f "$lm_file" )) && ims_args+=(--header="If-Modified-Since: $(<"$lm_file")")
          if ! wget --https-only --timeout=60 --tries=3 --user-agent="runscript/1.0" \
            "${ims_args[@]}" --server-response -O "$cache_file.tmp" "$url" 2>"$hdrtmp"; then
            rm -f "$cache_file.tmp" "$hdrtmp"; return 2
          fi
          if grep -q " 304 Not Modified" "$hdrtmp"; then
            rm -f "$cache_file.tmp" "$hdrtmp"; return 304
          fi
          # Extract headers
          awk -F': ' 'BEGIN{IGNORECASE=1} /^  ETag:/{print $2}' "$hdrtmp" | tr -d '\r' >| "$etag_file" || true
          awk -F': ' 'BEGIN{IGNORECASE=1} /^  Last-Modified:/{print $2}' "$hdrtmp" | tr -d '\r' >| "$lm_file" || true
          mv -f "$cache_file.tmp" "$cache_file"
          rm -f "$hdrtmp"
        fi
        chmod 600 "$cache_file" || true
        return 0
      }

      # Fetch or use cache
      if (( update == 1 || ! -f "$cache_file" )); then
        local rc=0; download_script || rc=$?
        if (( rc == 2 )); then
          print -u2 -- "runscript: failed to download $url"; return 2
        fi
      else
        # try conditional revalidation; ignore 304 code handling here since already cached
        download_script >/dev/null 2>&1 || true
      fi

      # Optional checksum verification
      if [[ -n "$sha256" ]]; then
        local got
        got=$(openssl dgst -sha256 -r "$cache_file" | awk '{print $1}') || { print -u2 -- "runscript: checksum failed to compute"; return 2; }
        if [[ "${got:l}" != "${sha256:l}" ]]; then
          print -u2 -- "runscript: SHA-256 mismatch!"
          print -u2 -- " expected: $sha256"
          print -u2 -- "      got: $got"
          return 2
        fi
      fi

      # Optional GPG verification
      if [[ -n "$gpg_id" ]]; then
        command -v gpg >/dev/null 2>&1 || { print -u2 -- "runscript: gpg not found but -g provided"; return 2; }
        local sig="${sig_url:-$url.asc}"
        local sig_tmp
        sig_tmp=$(mktemp -t runscript.sig.XXXXXX) || return 2
        # Fetch signature
        if (( have_curl )); then
          if ! curl --fail --location --proto '=https' --tlsv1.2 \
              --connect-timeout 10 --max-time 30 -A "runscript/1.0" -o "$sig_tmp" "$sig"; then
            rm -f "$sig_tmp"; print -u2 -- "runscript: failed to fetch signature $sig"; return 2
          fi
        else
          if ! wget --https-only --timeout=30 --tries=2 --user-agent="runscript/1.0" -O "$sig_tmp" "$sig"; then
            rm -f "$sig_tmp"; print -u2 -- "runscript: failed to fetch signature $sig"; return 2
          fi
        fi
        # Verify signature
        local verify_out
        verify_out=$(gpg --status-fd=1 --keyid-format=long --verify "$sig_tmp" "$cache_file" 2>&1) || {
          print -u2 -- "runscript: GPG signature verification FAILED"
          print -u2 -- "$verify_out"
          rm -f "$sig_tmp"
          return 2
        }
        rm -f "$sig_tmp"
        # Ensure signer matches expected key id
        local signer_id
        signer_id=$(print -- "$verify_out" | awk '/^\[GNUPG:\] VALIDSIG /{print $3; exit}')
        if [[ -z "$signer_id" || "${signer_id:l}" != "${gpg_id:l}" ]]; then
          print -u2 -- "runscript: GPG signer key mismatch"
          print -u2 -- " expected key: $gpg_id"
          print -u2 -- "    found key: ${signer_id:-unknown}"
          return 2
        fi
      fi

      # Show head and confirm if not forced or not allowlisted
      local preview_lines=20
      if (( force == 0 )); then
        print -- "——— Preview ($preview_lines lines) ———"
        head -n $preview_lines "$cache_file" | sed -e 's/^/| /'
        print -- "——————————————"
        if (( allowed == 0 )); then
          print -u2 -- "Domain '$domain' is NOT in your allowlist: $allowlist"
        fi
        printf "Proceed to run this script from '%s'? [y/N/a=always allow domain] " "$domain" >&2
        local reply
        read -r reply
        case "${reply:l}" in
          y|yes) ;;
          a|allow)
            print -- "$domain" >> "$allowlist"
            print -- "Added '$domain' to allowlist."
            ;;
          *) print -- "Aborted."; return 1 ;;
        esac
      fi

      if (( dry == 1 )); then
        print -- "Dry run: verified and cached at $cache_file"
        return 0
      fi

      # Determine interpreter from shebang; fallback to bash -euo pipefail
      local first_line
      IFS= read -r first_line < "$cache_file" || true
      local exec_cmd=()
      if [[ "$first_line" == '#!'* ]]; then
        # Strip "#!" and split
        local sheb="${first_line#\#!}"
        # shellcheck disable=SC2206
        exec_cmd=(${=sheb})
      else
        if command -v bash >/dev/null 2>&1; then
          exec_cmd=(/usr/bin/env bash -euo pipefail)
        else
          exec_cmd=(/usr/bin/env sh -e)
        fi
      fi

      # Execute in a temp copy with strict perms
      local runfile
      runfile=$(mktemp -t runscript.exec.XXXXXX) || return 2
      cp "$cache_file" "$runfile"
      chmod 700 "$runfile" || true

      # Separate args after optional --
      local args=()
      if (( $# > 0 )); then
        if [[ "$1" == "--" ]]; then shift; fi
        args=("$@")
      fi

      # Run
      local rc=0
      "${exec_cmd[@]}" "$runfile" "${args[@]}" || rc=$?
      rm -f "$runfile"
      return $rc
    }

    # runscript cache cleanup (keep last 60 days)
    runscript_cache_cleanup() {
      local dir="${XDG_CACHE_HOME:-$HOME/.cache}/runscript"
      [[ -d $dir ]] || return 0
      find "$dir" -type f -mtime +60 -delete
    }
    # run once per shell startup
    runscript_cache_cleanup

#   Navigate to codespace
#   ------------------------------------------------------------
    export START=$CODESPACE
    if [[ $PWD == $HOME ]]; then
      cd $START
    fi

#   Only apply to interactive shells
#   ------------------------------------------------------------
    [ -z "$PS1" ] && return

#   Autoloads
#   ------------------------------------------------------------
    autoload zmv

#   Personal Aliases
#   ------------------------------------------------------------
    alias ....='cd ..; cd ..; cd ..'
    alias ...='cd ..; cd ..'
    alias ..='cd ..'
    alias bm='bookmark'                         # zshmarks plugin
    alias bx='bundle exec'
    alias cdkd='\time cdk deploy --require-approval never --no-rollback'
    alias cdks='\time cdk synth --path-metadata false --report-versioning false --quiet'
    alias Code='cd $CODESPACE'
    alias codes='cd $CODESPACE'
    alias codespace='cd $CODESPACE'
    alias cp='cp -iv'                           # Preferred 'cp' implementation - requires confirm
    alias create-pdm='bash <(curl -fsSo- https://raw.githubusercontent.com/tw-studio/pdm-env-starter/main/scripts/create_pdm_app.sh)'
    alias ddss='find . -type f -name ".DS_Store" -delete'
    alias dm='deletemark'                       # zshmarks plugin
    alias dockal='docker attach $(docker ps -aq | head -1)'
    alias dockrl='docker rm -f $(docker ps -aq | head -1)'
    alias dus='du -sh .[^.]* *'
    alias dzi="find . -type f -name \"*:Zone.Identifier\" -delete"
    [[ "${(L)OS_NAME}" == "ubuntu" ]] && FD_CMD='fdfind' || FD_CMD='fd'
    alias fd='$FD_CMD --hidden --no-ignore --exclude .git --exclude node_modules --exclude .cache'
    alias fde='fd --hidden --no-ignore --exclude .git --exclude node_modules --exclude .cache'
    # Fix git when wsl corrupts and empties object
    alias gitfix='find .git/objects/ -type f -empty | xargs rm; git fetch -p; git fsck --full'
    alias gm='jump'                             # zshmarks plugin
    alias gpp2p='runscript https://raw.githubusercontent.com/tw-studio/dotfiles/refs/heads/main/scripts/git-push-private-to-public.sh'
    alias install-node='curl -fsSL https://raw.githubusercontent.com/tw-studio/dotfiles/main/misc-scripts/install-node-pnpm.sh | zsh'
    alias lad='du -sh {.,}*'                    # list size of directories and files
    alias lr="ls -Rlp | awk '{ if (NF==1) print \$0; } { if (NF>2) print \$NF; } { if (NF==0) print \$0; }'"
    LS_CMD=$(command -v gls 2>/dev/null || echo ls)
    LS_FLAGS=$([[ "$LS_CMD" == *gls ]] && echo "--color --group-directories-first" || echo "-G")
    alias ls="$LS_CMD -Ahv $LS_FLAGS"
    alias lsd="$LS_CMD -Adh $LS_FLAGS */"
    alias lss="$LS_CMD -Ahs $LS_FLAGS"
    alias m='fg'
    if command -v sw_vers &> /dev/null; then
      alias macosver="sw_vers | sed -n '2p' | cut -f 2"
    fi
    alias mkdir='mkdir -pv'                     # Preferred 'mkdir' implementation - doesn't clobber existing
    alias mv='mv -iv'                           # Preferred 'mv' implementation - requires confirm
    alias nextkey='zsh <(curl -fsSo- https://raw.githubusercontent.com/tw-studio/nextkey-aws-starter/main/scripts/create-nextkey-app.zsh)'
    alias nv='nvim'
    alias nvz='nvim -o `fzf`'
    alias overdrive='$CODESPACE/scripts/misc-scripts/overdrive.sh'
    alias path='echo -e ${PATH//:/\\n}'         # path:         Echo all executable Paths
    if command -v xclip &> /dev/null; then
      alias pbcopy='xclip -selection clipboard'
      alias pbpaste='xclip -selection clipboard -o'
    fi
    alias pdr='pdm run'
    alias pdrp='pdm run python'
    if command -v pip3 &> /dev/null; then
      alias pip='pip3'
    fi
    alias pn='pnpm'
    alias power='sudo powermetrics --samplers smc -i1 -n1'
    alias rg='rg --hidden --max-columns 200'
    alias rgni='\rg --hidden --no-ignore -g '!{.git,node_modules}' --max-columns 200'
    # https://github.com/ali-rantakari/trash (Mac)
    # https://github.com/andreafrancia/trash-cli (Ubuntu)
    if command -v trash &>/dev/null; then
      alias rm='trash'
    else
      alias rm='rm -i'
    fi
    alias rmhio='rm -f *.hi && rm -f *.o'       # haskell
    alias sm='showmarks'                        # zshmarks plugin
    alias sshc='$EDITOR ~/.ssh/config'
    alias ssho="ssh -o \"IdentitiesOnly=yes\""
    alias temp='cd $CODESPACE/tempspace'
    alias texlocal='cd /usr/local/texlive/texmf-local/tex/latex/local'
    alias timeout90='timeout --preserve-status --kill-after=90s 90s'
    alias tm='tmux ls'
    alias tm#='tmux attach #'
    alias tma='tmux attach -t'
    alias tmac='tmux new -s codespace || tmux attach -t codespace'
    alias tmat='tmux attach -t'
#   alias tmux="TERM=screen-256color-bce tmux"
    alias tmuxname='tmux display-message -p "#S"'
    alias tmvsc='~/.tmux/scripts/vsc-tmux.sh'
    alias tree='tree -a -I node_modules --noreport'
    alias vedit='$VS ~/.zshrc'
    alias vnvim='$VS ~/.config/nvim/init.vim'
    alias vnvtheme='$VS ~/.config/nvim/colors/monokai-fusion-tw.vim'
    alias vs='$VS'
    alias vtmux='$VS ~/.tmux.conf'
    if command -v wslpath &>/dev/null; then
      alias winspace='cd $WINSPACE'
    fi
    # alias youtube-m4a='youtube-dl -x --no-mtime --audio-format m4a --audio-quality 64K -o "~/Downloads/YouTube/%(title)s.%(ext)s" --exec "rename -z {}"'
    # alias youtube-mp3='youtube-dl -x --no-mtime --audio-format mp3 -o "~/Downloads/YouTube/%(title)s.%(ext)s" --exec "rename -z {}"'
    alias zedit='$EDITOR ~/.zshrc'
    alias znvim='$EDITOR ~/.config/nvim/init.vim'
    alias znvtheme='$EDITOR ~/.config/nvim/colors/monokai-fusion-tw.vim'
    alias zreload='source ~/.zshrc'
    alias ztheme='$EDITOR $ZSH/themes/tw.zsh-theme'
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
    # better cd - list directory contents after cd
    altercd(){ cd(){ unset -f cd ; cd $*; ls ; altercd; } } ; altercd
    revertcd(){ cd(){ unset -f cd; cd $*; } }
    qcd(){ unset -f cd; cd $*; altercd; }
    cl() { cd "$@" && ls; }
    cs() { cd "$@" && ls; }

    # snap* - archives files and dirs
    snapc() {
      if [[ $# -ne 1 ]]; then
        echo "Usage: snapc <file-or-dir>"
        return 1
      fi

      local file="$1"
      local base="${file%.*}"
      local extension="${file##*.}"
      local timestamp="$(date +'%Y-%m-%d-%H%M')"
      local new_name=""

      # Add timestamp into new file name, taking care of extension
      if [[ "$file" == *.* ]]; then
        new_name="${base}_${timestamp}.${extension}"
      else
        new_name="${file}_${timestamp}"
      fi

      # Make a copy with the new hash-based name
      cp -r "$file" "$new_name" >/dev/null;
      if [[ $? -ne 0 ]]; then
        echo "Error copying '$file' to '$new_name'"
        return 2
      fi

      echo "'$file' copied to '$new_name'"
    }
    # only use 'snap' when /usr/bin/snap not installed (such as on ec2)
    if [[ ! -f /usr/bin/snap ]]; then
      alias snap="snapc"
    fi
    function snapm {
      if [[ $# -ne 1 ]]; then
        echo "Usage: snapm <file>"
        return 1
      fi

      local file="$1"
      local base="${file%.*}"
      local extension="${file##*.}"
      local timestamp="$(date +'%Y-%m-%d-%H%M')"
      local new_name=""

      # Add timestamp into new file name, taking care of extension
      if [[ "$file" == *.* ]]; then
        new_name="${base}_${timestamp}.${extension}"
      else
        new_name="${file}_${timestamp}"
      fi

      # Make a copy with the new hash-based name
      mv "$file" "$new_name" >/dev/null;
      if [[ $? -ne 0 ]]; then
        echo "Error renaming '$file' to '$new_name'"
        return 2
      fi

      echo "'$file' renamed to '$new_name'"
    }

    # gcp - git cherry-pick helper
    alias gcp &>/dev/null && unalias gcp # set by git plugin
    function gcp {
      if [[ $# -ne 1 ]]; then
        echo "Usage: gcp <start-commit..end-commit>"
        return 1
      fi
      git cherry-pick "$1" --strategy-option=theirs --allow-empty --keep-redundant-commits
    }

    # dall - delete all silly things
    dall() {
      find . -type f -name ".DS_Store" -delete            # ddss
      find . -type f -name \"*:Zone.Identifier\" -delete  # dzi
    }

    # key - add identity to funtoo/keychain
    key() {
      eval $(keychain -q --eval --agents ssh "$1")
    }

    # minipng - compress all pngs in current directory (pngquant)
    if command -v pngquant &> /dev/null && command -v rename &> /dev/null; then
      minipng() {
        find . -maxdepth 1 -type f \( -name '*.png' -o -name '*.PNG' \) -exec pngquant {} \;
        find . -maxdepth 1 -type f \( \( -name '*.png' -o -name '*.PNG' \) ! -name '*-fs8.png' \) -delete;
        rename 's/-fs8//g' *;
      }
    fi

    # b62-9 - generate a base62 string (9 characters)
    function b62-9 {
      local DIGITS=9
      local BASE62_9=$(cat /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9' | fold -w $DIGITS | head -n 1)
      echo "$BASE62_9"
    }

    # ffmpeg - compress m4a
    if command -v ffmpeg &>/dev/null; then
      ffmpeg-64k() {
        ffmpeg -i "$1" -map 0:a:0 -b:a 64k "${1%.*}"_64k."${1##*.}"
      }
      ffmpeg-56k() {
        ffmpeg -i "$1" -map 0:a:0 -b:a 56k "${1%.*}"_56k."${1##*.}"
      }
      ffmpeg-mp3() {
        ffmpeg -i "$1" -map 0:a:0 -b:a 192k "${1%.*}"_192k.mp3
      }
      ffmpeg-mp3-64k() {
        ffmpeg -i "$1" -map 0:a:0 -b:a 64k "${1%.*}"_64k.mp3
      }
      ffmpeg-mp3-256k() {
        ffmpeg -i "$1" -map 0:a:0 -b:a 256k "${1%.*}"_256k.mp3
      }
    fi

    # pandoctw -
    if command -v pandocm &>/dev/null; then
      pandoctw() {
        pandocm "$1" -t markdown-smart-simple_tables --wrap=none -o "$1".md
      }
      pandoctwo() {
        pandocm "$1" -t markdown-smart-simple_tables --wrap=none -o "$2"
      }
    fi

    if command -v rename &>/dev/null; then
      function renumdir {
        echo -ne "Renumber all files in current directory? (y/N) "
        read -r YES_RENUMBER
        YES_RENUMBER=${YES_RENUMBER:-n}
        [[ ! $YES_RUN_SCRIPT =~ ^[yY]$ ]] && exit 1
        ls -tr | rename -v -N ...01 -X -e \'$_ = "$N"\'
      }
    fi

#   Personal Functions - for Mac
#   ------------------------------------------
    if [[ "$(uname)" == "Darwin" ]]; then

      # copy latest screenshot
      cpshot() {
        cp -p "`ls -1t ~/Desktop/Screenshots/* | head -1`" .;
        rename 's/ /-/g' *;
      }

      # copy latest download
      cpdl() {
        cp -p "`ls -1t ~/Downloads/* | head -1`" .;
        rename 's/ /-/g' *;
      }

      # tesseract - ocr (Mac)
      if command -v tesseract &> /dev/null; then
        tesso() {
          tesseract "$1" stdout
        }
        tessoshot() {
          cp -p "`ls -1t ~/Desktop/Screenshots/* | head -1`" . \
          && ls -tp . | grep '^Screen' | head -n 1 | xargs -I{} tesseract "{}" stdout;
        }
      fi

      list_xcode_provisioning_profiles() {
        while IFS= read -rd '' f; do
          2> /dev/null /usr/libexec/PlistBuddy -c 'Print :Entitlements:application-identifier' /dev/stdin \
            <<< $(security cms -D -i "$f")

        done < <(find "$HOME/Library/MobileDevice/Provisioning Profiles" -name '*.mobileprovision' -print0)
      }
    fi

#   Personal Functions - for Windows
#   ------------------------------------------
    if command -v wslpath &> /dev/null; then

      # open - mimics Mac open in Ubuntu WSL
      function open {

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

      # winvar - echo value of Windows environment variable
      winvar() {
        echo $(wslpath $(cmd.exe /C "echo %$1%" 2>/dev/null | tr -d '\r'))
      }

      # tesseract - ocr (Win)
      if command -v tesseract &> /dev/null; then
        tesso() {
          tesseract "$1" stdout
        }
        tessoshot() {

          # Check for Screenshots directory
          SCREENSHOTS_DIR="$WINHOME/Desktop/Screenshots"
          if [[ ! -d "$SCREENSHOTS_DIR" ]]; then
            echo "Screenshots directory not found at '$SCREENSHOTS_DIR'."
            return 1
          fi

          # Copy the latest screenshot file to the current directory
          LATEST_SCREENSHOT=$(find "$SCREENSHOTS_DIR" -type f -printf '%T@ %p\n' | sort -nr | head -1 | cut -d' ' -f2-)
          if [[ -z "$LATEST_SCREENSHOT" ]]; then
            echo "No screenshot files found in '$SCREENSHOTS_DIR'."
            return 1
          fi
          /bin/cp -p "$LATEST_SCREENSHOT" . || { echo "Failed to copy '$LATEST_SCREENSHOT'."; return 1; }

          # Run tesseract OCR on the copied screenshot
          SCREENSHOT_FILENAME=$(basename "$LATEST_SCREENSHOT")
          tesseract "$SCREENSHOT_FILENAME" stdout || { echo "Tesseract OCR failed on '$SCREENSHOT_FILENAME'."; return 1; }

          # Clean up
          rm -f "$SCREENSHOT_FILENAME"
        }
      fi
    fi

    # vsr - starts given file or directory in vscode --remote wsl+Ubuntu mode
    # NOTE: not needed when invoking vs with bin/code instead of Code.exe
    function vsr {
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

#   AWS Helpers
#   ------------------------------------------
    # generate a s3 friendly hash string (25 characters)
    function s3hash {
      local SUFFICIENTLY_RANDOM_LENGTH=25
      local HASH=$(cat /dev/urandom | LC_ALL=C tr -dc 'a-z0-9-' | fold -w $SUFFICIENTLY_RANDOM_LENGTH | head -n 1)
      echo "$HASH"
    }

    # rename a copy of the given file with a s3 friendly hash name
    function s3hashcp {
      # Require only one argument
      if [[ $# -ne 1 ]]; then
        echo "Usage: s3hashcp <filename>"
        return 1
      fi

      local filename="$1"
      local new_hash=$(s3hash)
      local base="${filename%.*}"
      local extension="${filename##*.}"
      local new_name=""

      # Add hash into new file name, taking care of extension
      if [[ "$filename" == *.* ]]; then
        new_name="${base}_${new_hash}.${extension}"
      else
        new_name="${filename}_${new_hash}"
      fi

      # Make a copy with the new hash-based name
      cp -r "$filename" "$new_name" >/dev/null;
      if [[ $? -ne 0 ]]; then
        echo "Error copying file."
        return 2
      fi

      echo "File copied to $new_name"
    }

    # rename the given file with a s3 friendly hash name
    function s3hashrename {
      # Require only one argument
      if [[ $# -ne 1 ]]; then
        echo "Usage: hashrename <filename>"
        return 1
      fi

      local filename="$1"
      local new_hash=$(s3hash)
      local base="${filename%.*}"
      local extension="${filename##*.}"
      local new_name=""

      # Add hash into new file name, taking care of extension
      if [[ "$filename" == *.* ]]; then
        new_name="${base}_${new_hash}.${extension}"
      else
        new_name="${filename}_${new_hash}"
      fi

      # Rename with the new hash-based name
      mv "$filename" "$new_name" >/dev/null;
      if [[ $? -ne 0 ]]; then
        echo "Error renaming file."
        return 2
      fi

      echo "File renamed to $new_name"
    }

    # rename all jpgs in current directory with hash name,
    # and preserve the originals in a directory
    function s3hashalljpg {
      mkdir -p originals >/dev/null;
      find . -maxdepth 1 -type f \( -name '*.jpg' -o -name '*.jpeg' -o -name '*.JPG' -o -name '*.JPEG' \) -exec cp {} originals/ \;
      find . -maxdepth 1 -type f \( -name '*.jpg' -o -name '*.jpeg' -o -name '*.JPG' -o -name '*.JPEG' \) | while read file; do echo "$file"; hashrename "$file"; done;
    }

    # connect to postgresql RDS instance via ec2 target at fixed port
    rdsconnect() {
      if [[ -z "$1" ]]; then
        echo "Error: expected argument ec2 instance ID";
        return 1;
      fi
      aws ssm start-session \
        --target "$1" \
        --document-name AWS-StartPortForwardingSession \
        --parameters '{"portNumber":["9432"],"localPortNumber":["9432"]}' \
        &;
    }

#   fzf configuration
#   ------------------------------------------
    if [[ "${(L)OS_NAME}" == "ubuntu" ]]; then
      export FZF_DEFAULT_COMMAND="fdfind --hidden --type f --exclude node_modules --exclude .git"
      export FZF_ALT_C_COMMAND="fdfind --hidden --type d . $HOME"
    else
      export FZF_DEFAULT_COMMAND="fd --hidden --type f --exclude node_modules --exclude .git"
      export FZF_ALT_C_COMMAND="fd --hidden --type d . $HOME"
    fi
    export FZF_DEFAULT_OPTS='--height 60% --layout=reverse --border'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

    # Source key bindings etc
    [[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

    # fh - search in your command history and execute selected command
    fh() {
      eval $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
    }

#   Update WSL_INTEROP in tmux for when value changes due to WSL restart
#   ------------------------------------------
    if command -v wslpath >/dev/null; then

      # update_tmux_wsl_interop - Updates WSL_INTEROP in tmux sessions on Windows
      function update_tmux_wsl_interop {
        if tmux info &>/dev/null; then
          current_wsl_interop="$WSL_INTEROP"
          # Update WSL_INTEROP in tmux server environment
          tmux set-environment -g WSL_INTEROP "$current_wsl_interop"
          # Update WSL_INTEROP in all existing tmux sessions
          tmux list-sessions -F "#{session_name}" | while read session; do
            tmux set-environment -t "$session" WSL_INTEROP "$current_wsl_interop"
          done
        fi
      }

      # check_wsl_interop_change - Detect changes in WSL_INTEROP
      function check_wsl_interop_change {
        if [[ "$WSL_INTEROP" != "$PREV_WSL_INTEROP" ]]; then
          update_tmux_wsl_interop
          export PREV_WSL_INTEROP="$WSL_INTEROP"
        fi
      }

      # Initialize PREV_WSL_INTEROP
      export PREV_WSL_INTEROP="$WSL_INTEROP"

      # Call the check function whenever a new shell starts
      check_wsl_interop_change
    fi

#   SSH
#   ------------------------------------------
    # Add ssh keys with passphrase to ssh-agent for each terminal session (Mac)
#   if command -v ssh-agent &>/dev/null \
#     && command -v sw_vers &>/dev/null \
#     && command -v ssh-add &>/dev/null;
#   then
#     eval "$(ssh-agent -s)" >/dev/null
#     MACOSVER="$(sw_vers | sed -n '2p' | cut -f 2)"
#     if [[ "$MACOSVER" < 12.0 ]]; then
#       { ssh-add -A; } &>/dev/null
#     else
#       { ssh-add --apple-load-keychain; } &>/dev/null
#     fi
#   fi

#   Additional Sources
#   ------------------------------------------
    # Source ec2 environment if exists
    if [[ -f $HOME/.ec2env ]]; then
      source $HOME/.ec2env
    fi

    # Haskell
    [ -f "${GHCUP_INSTALL_BASE_PREFIX:=$HOME}/.ghcup/env" ] && source "${GHCUP_INSTALL_BASE_PREFIX:=$HOME}/.ghcup/env"

#   Final steps
#   ------------------------------------------
    typeset -aU path    # dedupes path
