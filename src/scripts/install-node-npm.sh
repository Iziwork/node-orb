#!/bin/bash

set -euo pipefail

install_nvm() {
  if command -v nvm &> /dev/null; then
    echo "nvm is already installed. Skipping nvm install.";
    return
  fi

  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
  # shellcheck disable=SC2016
  echo 'export NVM_DIR="$HOME/.nvm"' >> "$BASH_ENV";
  # shellcheck disable=SC2016
  echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> "$BASH_ENV";
  # shellcheck disable=SC1090
  source "$BASH_ENV";
}

install_node() {
  local pkg_node_version
  pkg_node_version=$(jq -r ".engines.node | select (.!=null)" package.json )

  if [ -z "$pkg_node_version" ]; then { echo "engines.node seems to be empty in your package.json"; exit 1; } fi

  if command -v node > /dev/null 2>&1; then
    if node -v | grep "$pkg_node_version" > /dev/null 2>&1; then
      echo "node $pkg_node_version is already installed"
      return
    fi
  fi

  nvm install "$pkg_node_version"
  nvm alias default "$pkg_node_version"
  echo 'nvm use default &>/dev/null' >> "$BASH_ENV"
}

install_npm() {
  local pkg_npm_version
  pkg_npm_version=$(jq -r ".engines.npm" package.json)

  if command -v npm > /dev/null 2>&1; then
    if npm -v | grep "$pkg_npm_version" > /dev/null 2>&1; then
      echo "npm $pkg_npm_version is already installed"
      return
    fi
  fi

  npm install -g "npm@$pkg_npm_version"
}

# Will not run if sourced for bats-core tests.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
  install_nvm

  install_node

  install_npm
fi
