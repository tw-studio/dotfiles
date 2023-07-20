FROM ubuntu:latest

# errexit
RUN set -e

# Set timezone
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install packages
ARG DEBIAN_FRONTEND=noninteractive
RUN echo "Installing packages..." \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      fd-find \
      git \
      locales \
      neovim \
      rename \
      ripgrep \
      tmux \
      tree \
      zsh \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Fix locale issues, e.g. with Perl
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
 && dpkg-reconfigure --frontend=noninteractive locales \
 && update-locale LANG=en_US.UTF-8
RUN export LANG=en_US.UTF-8 

# Configure home, user, and working dir
ARG USER=ubuntu
RUN useradd -m -s /bin/zsh $USER
RUN usermod -aG sudo $USER
ENV HOME=/home/$USER
ENV CODESPACE=codespace
ENV RUSER=root
ENV RHOME=/root
WORKDIR $HOME

# Set shell to zsh
SHELL ["zsh", "-c"]

# Create codespace directory
RUN mkdir -p $HOME/$CODESPACE

# Clone dotfiles from public repo
RUN git clone https://github.com/tw-studio/dotfiles .dotfiles

# Install and configure oh-my-zsh
ENV ZSH=$HOME/.oh-my-zsh
ENV RZSH=$RHOME/.oh-my-zsh
ENV SHELL=/bin/zsh
RUN zsh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN cp -r $ZSH $RZSH
RUN cp .dotfiles/zsh/.zshrc $HOME/
RUN cp .dotfiles/zsh/.zshrc $RHOME/
RUN cp .dotfiles/zsh/codespace*.zsh-theme $ZSH/themes/
RUN cp .dotfiles/zsh/codespace*.zsh-theme $RZSH/themes/
RUN git clone https://github.com/jocelynmallon/zshmarks $ZSH/custom/plugins/zshmarks
RUN cp -r $ZSH/custom/plugins/zshmarks $RZSH/custom/plugins/zshmarks

# Install fzf from git
RUN git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf
RUN cp -r $HOME/.fzf $RHOME/.fzf
RUN $HOME/.fzf/install --all || true
RUN rm -f $HOME/.bashrc $HOME/.fzf/code.bash
RUN rm -f $RHOME/.bashrc $RHOME/.fzf.bash

# Configure neovim
RUN mkdir -p $HOME/.config/nvim/colors \
 && mkdir -p $HOME/.local/share/nvim/site/autoload \
 && cp .dotfiles/neovim/init.vim $HOME/.config/nvim/ \
 && cp .dotfiles/neovim/monokai-fusion.vim $HOME/.config/nvim/colors/ \
 && cp .dotfiles/neovim/plug.vim $HOME/.local/share/nvim/site/autoload/ \
 && cp .dotfiles/neovim/dracula-airline.vim $HOME/.config/nvim/dracula.vim \
 && cp .dotfiles/neovim/dracula.vim $HOME/.config/nvim/colors/
RUN mkdir -p $RHOME/.config/nvim/colors \
 && mkdir -p $RHOME/.local/share/nvim/site/autoload \
 && cp .dotfiles/neovim/init.vim $RHOME/.config/nvim/ \
 && cp .dotfiles/neovim/monokai-fusion.vim $RHOME/.config/nvim/colors/ \
 && cp .dotfiles/neovim/plug.vim $RHOME/.local/share/nvim/site/autoload/ \
 && cp .dotfiles/neovim/dracula-airline.vim $RHOME/.config/nvim/dracula.vim \
 && cp .dotfiles/neovim/dracula.vim $RHOME/.config/nvim/colors/
RUN nvim --headless +PlugInstall +qall

# Configure tmux
RUN cp .dotfiles/tmux/.tmux.conf $HOME/
RUN cp .dotfiles/tmux/.tmux.conf $RHOME/
RUN git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
RUN cp -r $HOME/.tmux $RHOME/.tmux
RUN tmux start-server \
 && tmux new-session -d \
 && sleep 1 \
 && $HOME/.tmux/plugins/tpm/scripts/install_plugins.sh \
 && tmux kill-server
RUN mkdir -p $HOME/.tmux/scripts \
 && cp -r .dotfiles/tmux/scripts $HOME/.tmux/
RUN mkdir -p $RHOME/.tmux/scripts \
 && cp -r .dotfiles/tmux/scripts $RHOME/.tmux/

# Cleanup
RUN rm -rf .dotfiles

# Give user their stuff
RUN chown -R $USER $HOME

# Set default shells
RUN usermod -s /bin/zsh $USER
RUN usermod -s /bin/zsh $RUSER

# Set the active user
USER $USER

# Last setup
RUN source ~/.zshrc
ENV OS_NAME=ubuntu

# Set default entrypoint and command
ENTRYPOINT ["zsh", "-c"]
CMD ["/bin/zsh"]
