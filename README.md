<p align="center">
    <img src="https://raw.githubusercontent.com/tw-studio/dotfiles/main/.readme/tw-dark.jpg" width="150" />
    <h1 align="center">dotfiles</h2>
</p>

<p align="center">Dotfiles and scripts to set up zsh, tmux, and neovim on Ubuntu and Alpine Linux.</p>

<br />

I mainly use these to set up a comfortable environment (for me) on new Linux instances.

## Features

* Includes **setup scripts** and **Dockerfiles**, which...
* Installs and configures **oh-my-zsh** with **fzf**, **zshmarks**, and a custom theme (with nice **git** support).
* Configures **neovim** with several choice plugins and a nice theme.
* Configures **tmux** with sensible defaults and a clean status bar.

## Usage

* Run the setup scripts on Ubuntu and Alpine Linux instances (like ec2):

    ```
    # Ubuntu (run as root)
    apt-get update && apt-get install -y --no-install-recommends wget ca-certificates && sh -c "$(wget https://raw.githubusercontent.com/tw-studio/dotfiles/main/codespace-setup/scripts/codespace-ubuntu.sh -O -)"

    # Alpine Linux (run as root)
    apk update && apk add --no-cache wget && sh -c "$(wget https://raw.githubusercontent.com/tw-studio/dotfiles/main/codespace-setup/scripts/codespace-alpine.sh -O -)"
    ```
    
* Run the Dockerfiles to set up a quick, temporary environment anywhere:

    ```
    docker run -it twdocker1/codespace:0.1.0-ubuntu (or latest)
    docker run -it twdocker1/codespace:0.1.0-alpine
    ```
