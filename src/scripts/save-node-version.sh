#!/bin/bash

set -euo pipefail

save_node_version() {
  local pkg_node_version
  pkg_node_version=$(jq -r ".engines.node // empty" package.json)

  if [ -z "$pkg_node_version" ]; then
    echo "No engines.node specified, skipping"
    exit 1
  fi

  echo "$pkg_node_version" > /tmp/node-version
}

# Will not run if sourced for bats-core tests.
ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" = "$0" ]; then
  save_node_version
fi
