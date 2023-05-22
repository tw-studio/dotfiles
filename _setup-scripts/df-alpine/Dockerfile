FROM alpine

# Configure home, user, and working dir
ARG NAME=codespace
ENV HOME=/home
WORKDIR $HOME/$NAME

# Optionally add restricted user and group
#RUN groupadd -r $NAME \
#  && useradd -lrg $NAME $NAME
#RUN chown -R $NAME:$NAME /$NAME
#USER $NAME

# Install remaining packages
#ARG DEBIAN_FRONTEND=noninteractive
RUN echo "Installing packages..." \
 && set -ex \
 && apk add --no-cache \
      bash \
      ca-certificates \
      coreutils \
      curl \
      fd \
      git \
      ncurses \
      neovim \
      ripgrep \
      tmux \
      tree \
      util-linux \
      zsh

# Set shell to zsh
SHELL ["zsh", "-c"]

# Fix locale issues, e.g. with Perl
#RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
# && dpkg-reconfigure --frontend=noninteractive locales \
# && update-locale LANG=en_US.UTF-8
#ENV LANG=en_US.UTF-8 

# Clone dotfiles from public repo
RUN git clone https://github.com/tw-space/dotfiles .dotfiles

# Install oh-my-zsh
RUN zsh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
ENV ZSH=$HOME/.oh-my-zsh
RUN cp .dotfiles/zsh/.zshrc $HOME/ \
 && cp .dotfiles/zsh/codespace*.zsh-theme $ZSH/themes/
RUN git clone https://github.com/jocelynmallon/zshmarks $ZSH/custom/plugins/zshmarks

# Install fzf from git
RUN git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf
RUN $HOME/.fzf/install
RUN rm -f $HOME/.bashrc $HOME/.fzf.bash

# Configure neovim
RUN mkdir -p $HOME/.config/nvim/colors \
 && mkdir -p $HOME/.local/share/nvim/site/autoload \
 && cp .dotfiles/neovim/init.vim $HOME/.config/nvim/ \
 && cp .dotfiles/neovim/monokai-fusion.vim $HOME/.config/nvim/colors/ \
 && cp .dotfiles/neovim/plug.vim $HOME/.local/share/nvim/site/autoload/ \
 && cp .dotfiles/neovim/dracula-airline.vim $HOME/.config/nvim/dracula.vim \
 && cp .dotfiles/neovim/dracula.vim $HOME/.config/nvim/colors/
RUN nvim --headless +PlugInstall +qall

# Configure tmux
RUN cp .dotfiles/tmux/.tmux.conf $HOME/
RUN git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
RUN tmux start-server \
 && tmux new-session -d \
 && sleep 1 \
 && $HOME/.tmux/plugins/tpm/scripts/install_plugins.sh \
 && tmux kill-server
RUN mkdir -p $HOME/.tmux/scripts \
 && cp -r .dotfiles/tmux/scripts $HOME/.tmux/

# Cleanup
RUN rm -rf .dotfiles

# Last setup
RUN source ~/.zshrc
ENV OS_NAME=alpine

# Set default entrypoint and command
ENTRYPOINT ["zsh", "-c"]
CMD ["source ~/.zshrc && ~/.tmux/scripts/new-tmux-session-window-panes.zsh"]
