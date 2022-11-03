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

  # shellcheck disable=SC1091
  source "${SCRIPT_PATH}/install.sh"
}

teardown ()
{
  :
}

@test "init.config BOOST_TMP_DIR defined" {
  export BOOST_TMP_DIR=""
  export TMPDIR=""
  init.config

  assert_equal "${BOOST_TMP_DIR}" "/tmp"
}

@test "init.config BOOST_TMP_DIR preserved" {
  export BOOST_TMP_DIR="/tmp/assert/path"
  init.config

  assert_equal "${BOOST_TMP_DIR}" "/tmp/assert/path"
}

@test "init.config BOOST_TMP_DIR built from WORKSPACE_TMP" {
  export BOOST_TMP_DIR=""
  export WORKSPACE_TMP="/tmp/assert/path"
  init.config

  assert_equal "${BOOST_TMP_DIR}" "/tmp/assert/path"
}

@test "init.config BOOST_TMP_DIR built from TMPDIR" {
  export BOOST_TMP_DIR=""
  export WORKSPACE_TMP=""
  export TMPDIR="/tmp/assert/path"
  init.config

  assert_equal "${BOOST_TMP_DIR}" "/tmp/assert/path"
}

@test "init.config BOOST_EXE defined" {
  export BOOST_EXE=""
  export BOOST_TMP_DIR="/tmp"
  init.config

  assert_equal "${BOOST_EXE}" "/tmp/boost-cli/latest"
}

@test "init.config BOOST_EXE preserved" {
  export BOOST_EXE="/tmp/assert/boost"
  init.config

  assert_equal "${BOOST_EXE}" "/tmp/assert/boost"
}

@test "init.config BOOST_EXE built from BOOST_TMP_DIR" {
  export BOOST_EXE=""
  export BOOST_TMP_DIR="/tmp/assert/path"
  init.config

  assert_equal "${BOOST_EXE}" "/tmp/assert/path/boost-cli/latest"
}

@test "init.config BOOST_CLI_URL defined" {
  export BOOST_CLI_URL=""
  init.config

  assert_equal "${BOOST_CLI_URL}" "https://assets.build.boostsecurity.io"
}

@test "init.config BOOST_CLI_URL preserved" {
  export BOOST_CLI_URL="https://localhost/"
  init.config

  assert_equal "${BOOST_CLI_URL}" "https://localhost"
}

@test "init.config BOOST_DOWNLOAD_URL defined" {
  export BOOST_DOWNLOAD_URL=""
  init.config

  assert_equal "${BOOST_DOWNLOAD_URL}" "https://assets.build.boostsecurity.io/boost-cli/get-boost-cli"
}

@test "init.config BOOST_DOWNLOAD_URL preserved" {
  export BOOST_DOWNLOAD_URL="https://localhost/file"
  init.config

  assert_equal "${BOOST_DOWNLOAD_URL}" "https://localhost/file"
}

@test "init.config BOOST_DOWNLOAD_URL built from BOOST_CLI_URL" {
  export BOOST_CLI_URL="https://localhost/"
  export BOOST_DOWNLOAD_URL=""
  init.config

  assert_equal "${BOOST_DOWNLOAD_URL}" "https://localhost/boost-cli/get-boost-cli"
}

@test "init.cli executes the installer" {
  export BOOST_TMP_DIR=${BATS_TEST_TMPDIR}/tmpdir

  curl () {
    echo "${*}" > ${BATS_TEST_TMPDIR}/curl.call_args
    echo "echo ok"
  }

  init.config
  run init.cli

  curl_call_args=$(cat "${BATS_TEST_TMPDIR}/curl.call_args")

  assert test -d "${BOOST_TMP_DIR}"
  assert_equal "${curl_call_args}" "--silent ${BOOST_DOWNLOAD_URL}"
  assert_output "ok"
}


@test "init.cli noops if executable found" {
  export BOOST_TMP_DIR=${BATS_TEST_TMPDIR}/tmpdir
  export BOOST_EXE=${BATS_TEST_TMPDIR}/file
  touch "${BOOST_EXE}"

  curl () { return 1; }

  init.cli
}

@test "install" {
  export BOOST_TMP_DIR=${BATS_TEST_TMPDIR}
  export BOOST_CLI_ARGUMENTS=--help

  run main.install

  assert test -f "${BATS_TEST_TMPDIR}/boost-cli/latest"
  assert test -d "${BATS_TEST_TMPDIR}/boost-cli/$(ls -1d 1*)"
}

# vim: set ft=bash ts=2 sw=2 et :
