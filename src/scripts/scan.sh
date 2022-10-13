#!/bin/bash

log.info ()
{ # $@=message
  printf "$(date +'%H:%M:%S') [\033[34m%s\033[0m] %s\n" "INFO" "${*}";
}

log.error ()
{ # $@=message
  printf "$(date +'%H:%M:%S') [\033[31m%s\033[0m] %s\n" "ERROR" "${*}";
}

git.ls_remote ()
{
  git ls-remote --symref origin HEAD \
    | awk '/^ref:/{sub(/refs\/heads\//, "", $2); print $2}'
}

init.config ()
{
  log.info "initializing configuration"

  export BOOST_TMP_DIR=${BOOST_TMP_DIR:-${WORKSPACE_TMP:-${TMPDIR:-/tmp}}}
  export BOOST_EXE=${BOOST_EXE:-${BOOST_TMP_DIR}/boost-cli/latest}

  export BOOST_CLI_URL=${BOOST_CLI_URL:-https://assets.build.boostsecurity.io}
         BOOST_CLI_URL=${BOOST_CLI_URL%*/}
  export BOOST_DOWNLOAD_URL=${BOOST_DOWNLOAD_URL:-${BOOST_CLI_URL}/boost-cli/get-boost-cli}

  export BOOST_GIT_MAIN_BRANCH
         BOOST_GIT_MAIN_BRANCH=${BOOST_GIT_MAIN_BRANCH:-$(git.ls_remote)}

  init.ci.config
}

init.ci.config ()
{
  export BOOST_API_TOKEN=${!BOOST_API_TOKEN_VAR}

  if [ "${CIRCLE_BRANCH:-}" != "${BOOST_GIT_MAIN_BRANCH}" ]; then
    export BOOST_GIT_BASE=${BOOST_GIT_MAIN_BRANCH}

    if [ -z "${CIRCLE_PULL_REQUEST:-}" ]; then
      log.info "non-main branch without a pull-request is not supported"
      exit 0
    fi
  fi
}

init.cli ()
{
  if [ -f "${BOOST_EXE:-}" ]; then
    return
  fi

  mkdir -p "${BOOST_TMP_DIR}"
  curl --silent "${BOOST_DOWNLOAD_URL}" | bash
}

main.scan ()
{
  init.config
  init.cli

  # shellcheck disable=SC2086
  exec ${BOOST_EXE} scan repo ${BOOST_CLI_ARGUMENTS:-}
}

if ! ${BATS_ENABLED:-false}; then
  set -e
  set -o pipefail
  set -u

  main.scan
fi
