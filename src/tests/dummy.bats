# Runs prior to every test
setup() {
  # Load our script file.
  source ./src/scripts/install-node-npm.sh
}

@test '1: Dummy test' {
  [ "foo" == "foo" ]
}