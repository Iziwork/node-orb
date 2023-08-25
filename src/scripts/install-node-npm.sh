#!/bin/bash

set -euo pipefail

# we force curl to use http1.1 to prevent http2 errors on CircleCI
shopt -s expand_aliases
alias curl='curl --http1.1'

install_nvm() {
  if command -v nvm &> /dev/null; then
    echo "nvm is already installed. Skipping nvm install.";
    return
  fi

  NVM_VERSION='0.39.5'
  mkdir -p "$PWD"/.nvm
  export NVM_DIR=$PWD/.nvm
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh | bash
  # shellcheck disable=SC2016
  echo 'export NVM_DIR="$PWD/.nvm"' >> "$BASH_ENV";
  # shellcheck disable=SC2016
  echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> "$BASH_ENV";
  # shellcheck disable=SC1090
  source "$BASH_ENV";
}

install_node() {
  local pkg_node_version
  pkg_node_version=$(jq -r ".engines.node // empty" package.json)

  if [ -z "$pkg_node_version" ]; then
    echo "No engines.node specified, skipping node installation"
    return
  fi

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
  pkg_npm_version=$(jq -r ".engines.npm // empty" package.json)

  if [ -z "$pkg_npm_version" ]; then
    echo "No engines.npm specified, skipping npm installation"
    return
  fi

  if [ "$pkg_npm_version" = "please-use-yarn" ]; then
    echo "please-use-yarn marker found, skipping npm installation"
    return
  fi


  if command -v npm > /dev/null 2>&1; then
    if npm -v | grep "$pkg_npm_version" > /dev/null 2>&1; then
      echo "npm $pkg_npm_version is already installed"
      return
    fi
  fi

  npm install -g "npm@$pkg_npm_version"
}

install_corepack() {
  if ! command -v corepack > /dev/null 2>&1; then
    npm install -g corepack
  fi

  corepack enable
  corepack prepare || true
}

# Will not run if sourced for bats-core tests.
ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" = "$0" ]; then
  install_nvm
  install_node
  install_npm
  install_corepack
fi
