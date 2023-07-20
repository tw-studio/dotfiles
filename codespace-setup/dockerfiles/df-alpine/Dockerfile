FROM alpine:latest

# errexit, xtrace
RUN set -ex

# Install packages
RUN echo "Installing packages..." \
 && apk update \
 && apk add --no-cache \
      bash \
      ca-certificates \
      coreutils \
      curl \
      fd \
      git \
      ncurses \
      neovim \
      perl \
      ripgrep \
      sudo \
      tmux \
      tree \
      tzdata \
      util-linux \
      zsh
RUN apk add --no-cache perl-file-rename --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing/
RUN apk -v cache clean

# Configure su
RUN chmod u+s $(which su)
      
# Set timezone
RUN cp /usr/share/zoneinfo/America/Los_Angeles /etc/localtime \
 && echo "America/Los_Angeles" > /etc/timezone \
 && apk del tzdata

# Configure home, user, and working dir
ARG USER=alpine
RUN adduser -s /bin/zsh -D -g '' $USER
RUN echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo EDITOR='tee -a' visudo
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

# Modify .zshrc for Alpine Linux
RUN echo "alias rename=file-rename" >> $HOME/.zshrc
RUN echo "alias rename=file-rename" >> $RHOME/.zshrc

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

# Set default shell for root
RUN perl -i -pe 's:/bin/ash:/bin/zsh:' /etc/passwd

# Set the active user
USER $USER

# Last setup
RUN source ~/.zshrc
ENV OS_NAME=alpine

# Set default entrypoint and command
ENTRYPOINT ["zsh", "-c"]
CMD ["/bin/zsh"]
