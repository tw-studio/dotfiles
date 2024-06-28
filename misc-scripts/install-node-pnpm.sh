#!/bin/bash
#
# install-node-pnpm.sh

# errexit
set -e

###
##
# Install node, pnpm, and pm2

# Continue when nvm doesn't exist
if [[ ! -f ~/.nvm/nvm.sh ]]; then

  # Install and activate nvm
  echo "Downloading and running nvm v0.39.7 install script..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  echo "Setting NVM_DIR to $HOME/.nvm..."
  export NVM_DIR="$HOME/.nvm"
  echo "Loading nvm..."
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  echo "Loading nvm bash completion..."
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
  
  # Install node lts
  echo "Installing Node LTS version using nvm..."
  nvm install --lts

  # Ubuntu: use setcap (libcap2-bin) to allow node to open ports <1024
  echo "Allowing node to open ports <1024 using setcap..."
  sudo setcap cap_net_bind_service=+ep $(command -v node)

  # Install pnpm and pm2 globally with npm
  echo "Installing pnpm..."
  npm install -g pnpm

  # Add pnpm global bin env var to .zshrc
  echo "Adding PNPM_HOME to .zshrc..."
  export PNPM_HOME="$HOME/.local/share/pnpm"
  grep -qxF 'export PNPM_HOME="$HOME/.local/share/pnpm"' ~/.zshrc || \
  echo 'export PNPM_HOME="$HOME/.local/share/pnpm"
' >> ~/.zshrc

  # Add pnpm to path in .zshrc
  echo "Updating PATH with pnpm locations in .zshrc..."
  export PATH=$PATH:$(dirname $(command -v pnpm))
  export PATH=$PATH:$(pnpm bin)
  export PATH=$PATH:$PNPM_HOME
  typeset -aU path
  grep -qxF "export PATH=\$PATH:$(dirname $(command -v pnpm))" ~/.zshrc || \
  echo "export PATH=\$PATH:$(dirname $(command -v pnpm))
export PATH=\$PATH:$(pnpm bin)
export PATH=\$PATH:\$PNPM_HOME
typeset -aU path    # dedupes path
" >> ~/.zshrc

  # Use pnpm to install pm2
  echo "Installing pm2 globally using pnpm..."
  pnpm add --global pm2

fi
