#!/bin/bash

set -euo pipefail

install_nvm() {
  if command -v nvm &> /dev/null; then
    echo "nvm is already installed. Skipping nvm install.";
    return
  fi

  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
  # shellcheck disable=SC2016
  echo 'export NVM_DIR="$HOME/.nvm"' >> "$BASH_ENV";
  # shellcheck disable=SC2016
  echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> "$BASH_ENV";
  # shellcheck disable=SC1090
  source "$BASH_ENV";
}

install_node() {
  local pkg_node_version
  pkg_node_version=$(jq ".engines.node" package.json)

  if [[ "$pkg_node_version" == "null" ]]; then
    echo "No engines.node specified, skipping node installation"
    return
  fi

  local pkg_node_version_stripped
  pkg_node_version_stripped=$(echo "$pkg_node_version" | jq -r .)

  if command -v node > /dev/null 2>&1; then
    if node -v | grep "$pkg_node_version_stripped" > /dev/null 2>&1; then
      echo "node $pkg_node_version_stripped is already installed"
      return
    fi
  fi

  nvm install "$pkg_node_version_stripped"
  nvm alias default "$pkg_node_version_stripped"
  echo 'nvm use default &>/dev/null' >> "$BASH_ENV"
}

install_npm() {
  local pkg_npm_version
  pkg_npm_version=$(jq ".engines.npm" package.json)

  if [[ "$pkg_npm_version" == "null" ]]; then
    echo "No engines.npm specified, skipping npm installation"
    return
  fi

  local pkg_npm_version_stripped
  pkg_npm_version_stripped=$(echo "$pkg_npm_version" | jq -r .)

  if [[ "$pkg_npm_version_stripped" == "please-use-yarn" ]]; then
    echo "please-use-yarn marker found, skipping npm installation"
    return
  fi


  if command -v npm > /dev/null 2>&1; then
    if npm -v | grep "$pkg_npm_version_stripped" > /dev/null 2>&1; then
      echo "npm $pkg_npm_version_stripped is already installed"
      return
    fi
  fi

  npm install -g "npm@$pkg_npm_version_stripped"
}

install_corepack() {
  if ! command -v corepack > /dev/null 2>&1; then
    npm install -g corepack
  fi

  corepack enable
  corepack prepare
}

# Will not run if sourced for bats-core tests.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
  install_nvm
  install_node
  install_npm
  install_corepack
fi
