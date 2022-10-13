setup ()
{
  bats_load_library "bats-assert"
  bats_load_library "bats-file"
  bats_load_library "bats-support"

  PROJECT_ROOT=$(git rev-parse --show-toplevel)

  export BATS_ENABLED=true
  export SCRIPT_PATH=${PROJECT_ROOT}/src/scripts

  export CIRCLE_BRANCH="main"
  export BOOST_GIT_MAIN_BRANCH="main" # do not attempt git ops
  export BOOST_API_TOKEN_VAR=BOOST_API_TOKEN_VALUE
  export BOOST_API_TOKEN_VALUE=123456

  # shellcheck disable=SC1091
  source "${SCRIPT_PATH}/scan.sh"
}

teardown ()
{
  :
}

@test "init.ci.config BOOST_API_TOKEN defined" {
  export BOOST_API_TOKEN
  export BOOST_API_TOKEN_VAR=BOOST_API_TOKEN_DATA
  export BOOST_API_TOKEN_DATA=123456
  init.config

  assert_equal "${BOOST_API_TOKEN}" "${BOOST_API_TOKEN_DATA}"
}

@test "init.ci.config BOOST_API_TOKEN undefined" {
  export BOOST_API_TOKEN
  export BOOST_API_TOKEN_VAR=BOOST_API_TOKEN_DATA
  init.config

  assert_equal "${BOOST_API_TOKEN}" ""
}

@test "init.ci.config BOOST_GIT_BASE defined" {
  export BOOST_GIT_BASE=""
  export BOOST_GIT_MAIN_BRANCH="test"
  export CIRCLE_BRANCH=not-main
  export CIRCLE_PULL_REQUEST=http://url/123
  init.config

  assert_equal "${BOOST_GIT_BASE}" "${BOOST_GIT_MAIN_BRANCH}"
}

@test "init.ci.config CIRCLE_PULL_REQUEST required" {
  export CIRCLE_BRANCH="potato"
  run init.config

  assert_output --partial "non-main branch without a pull-request is not supported"
}

# vim: set ft=bash ts=2 sw=2 et :
