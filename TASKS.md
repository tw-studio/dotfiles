# Tasks

### Working


### Tasks

#### Codespace

**Codespace Ubuntu**:
- [ ] (P2) `sudo apt install poppler-utils` (installs pdftocairo, pdftotext, and other common utilities used by packages)

**Codespace Ubuntu+WSL2**:
- [ ] (P1) Set WSL2's git credential.helper to use Windows's Git Credential Manager (must first be installed): `git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe"`
- [ ] (P1) Fix neovim url grep installer file name to `linux-x86_64` from `linux64`

**Codespace Win**:
- [ ] (P1.5) Fix VSCode settings not backing up on initial install
- [ ] (P2) Configure personal PowerShell profile
- [ ] (P2) Install NeoVim for Windows (for PowerShell)
- [ ] (P3) Add "simple" flag to pass in via command line that skips optional installs
- [ ] (P3) Consider switching install orders so all optional installs are at the end

**pdm setup**:
- [ ] (P1) Add global config file to *~/.config/pdm/config.toml*:

    ```
    [python]
    use_pyenv = false
    use_venv = false

    [global_project]
    fallback = true
    user_site = true

    [install]
    cache = true
    cache_method = "symlink"
    ```

- [ ] (P3) Set up pdm completions
    - [ ] Add to script:

        ```
        mkdir -p "ZSH_CUSTOM/plugins/pdm"
        pdm completion zsh > "ZSH_CUSTOM/plugins/pdm/_pdm"
        ```
    
    - [ ] Enable pdm plugin: `plugins=(... pdm ...)


#### Other

**.zshrc**:
- [ ] (P2) Add MARKs for Mark Jump
- [ ] (P3) Fix snapm bug with hidden files

**git-push-private-to-public**:
- [ ] (P3) Switch back to initial branch at end of script

### Done

- [x] (P2) [codespace-win]: Install 'trash-cli' on Windows (2024-11-03 20:20)
- [x] (P2) [vscode]: Adds win keybinding ctrl+shift+alt+m to toggle editor widths (11/03/24 08:03 PM)
- [x] (P1) [nvim]: Add new keybinding shift+U in init.vim: `nnoremap U <C-r>`
- [x] (P1) [zshrc]: Update WSL_INTEROP in tmux for when value changes due to WSL restart (11/03/24 07:22 PM)
- [x] (P1.5) [zshrc]: Fix fzf Ctrl+T use of $OS_NAME (11/03/24 07:14 PM)
- [x] (P1.5) [codespace-win]: Add using AutoHotkey to map shortcut to Em Dash (11/03/24 07:06 PM)
- [x] (P1.5) [zshrc]: Add tesseract for Windows (11/03/24 06:09 PM)
- [x] (P1.5) [codespace-win]: Add optional install of VeraCrypt (11/03/24 05:10 PM)
- [x] Adding pre-commit hooks to sanitize TASKS.md in public branch (11/03/24 04:48 PM)





- [ ] Fix dotfiles PowerShell script to not redownload settings files in second pass (backups aren't found after first pass)

- [ ] Add fix in dotfiles for outdated WSL_INTEROP in .zshrc and .tmux.conf;

