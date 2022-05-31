#!/bin/bash

set -e
set -o pipefail
set -u

export BOOST_TMP_DIR=${BOOST_TMP_DIR:-${WORKSPACE_TMP:-${TMPDIR:-/tmp}}}
export BOOST_EXE=${BOOST_EXE:-${BOOST_TMP_DIR}/boost/cli/latest/boost.sh}


log.info ()
{ # $@=message
  printf "$(date +'%H:%M:%S') [\033[34m%s\033[0m] %s\n" "INFO" "${*}";
}

log.error ()
{ # $@=message
  printf "$(date +'%H:%M:%S') [\033[31m%s\033[0m] %s\n" "ERROR" "${*}";
}

init.config ()
{
  log.info "initializing configuration"

  export BOOST_CLI_URL=${BOOST_CLI_URL:-https://assets.build.boostsecurity.io}
         BOOST_CLI_URL=${BOOST_CLI_URL%*/}
  export BOOST_DOWNLOAD_URL=${BOOST_DOWNLOAD_URL:-${BOOST_CLI_URL}/boost/get-boost-cli}
  export BOOST_EXEC_COMMAND=${INPUT_EXEC_COMMAND:-}

  export BOOST_MAIN_BRANCH
         BOOST_MAIN_BRANCH=$(git ls-remote --symref origin HEAD | awk '/^ref:/{sub(/refs\/heads\//, "", $2); print $2}')
  if [ "${CIRCLE_BRANCH}" != "${BOOST_MAIN_BRANCH}" ]; then
    export BOOST_GIT_BASE=${BOOST_MAIN_BRANCH}
  fi

  if [ -n "${BOOST_API_ENDPOINT_VAR:-}" ]; then
    export BOOST_API_ENDPOINT=${!BOOST_API_ENDPOINT_VAR}
  fi

  if [ -n "${BOOST_API_TOKEN_VAR:-}" ]; then
    export BOOST_API_TOKEN=${!BOOST_API_TOKEN_VAR}
  fi
}

init.cli ()
{
  if [ -f "${BOOST_BIN:-}" ]; then
    return
  fi

  mkdir -p "${BOOST_TMP_DIR}"
  curl --silent "${BOOST_DOWNLOAD_URL}" | bash
}

main.exec ()
{
  init.config
  init.cli

  if [ -z "${BOOST_EXEC_COMMAND:-}" ]; then
    log.error "the 'exec_command' option must be defined when in exec mode"
    exit 1
  fi

  if [ -z "${BOOST_STEP_NAME:-}" ]; then
    log.error "the 'step_name' option must be defined in exec mode"
    exit 1
  fi

  # shellcheck disable=SC2086
  exec ${BOOST_EXE} scan exec ${BOOST_CLI_ARGUMENTS:-} --command "${BOOST_EXEC_COMMAND}"
}

main.scan ()
{
  init.config
  init.cli

  if [ -n "${BOOST_EXEC_COMMAND:-}" ]; then
    log.error "the 'exec_command' option must only be defined in exec mode"
    exit 1
  fi

  # shellcheck disable=SC2086
  exec ${BOOST_EXE} scan run ${BOOST_CLI_ARGUMENTS:-}
}

case "${BOOST_ACTION:-scan}" in
  exec)     main.exec ;;
  scan)     main.scan ;;
  *)        log.error "invalid action ${BOOST_ACTION}"
            exit 1
            ;;
esac

