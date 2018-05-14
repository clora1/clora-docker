#!/usr/bin/env bash

# I/O helpers
red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)
info() {
  printf "%s\n" "$@"
}

success() {
  printf "${green}%s${reset}\n" "$@"
}

error() {
  printf "${red}%s${reset}\n" "$@"
}

ask() {
  local prompt default reply

  if [ "${2:-}" = "Y" ]; then
    prompt="Y/n"
    default=Y
  elif [ "${2:-}" = "N" ]; then
    prompt="y/N"
    default=N
  else
    prompt="y/n"
    default=
  fi

  while true; do
    echo -n "$1 [$prompt] "
    read reply </dev/tty

    if [ -z "$reply" ]; then
      reply=$default
    fi

    case "$reply" in
      Y*|y*) return 0 ;;
      N*|n*) return 1 ;;
    esac
  done
}

pushd () {
  command pushd "$@" > /dev/null
}

popd () {
  command popd "$@" > /dev/null
}

# Check dependencies
if hash tac 2>/dev/null; then
  TAC_CMD="tac"
else
  TAC_CMD="/usr/bin/tail -r"
fi

! read -r -d '' DOCKERFILE_HEADER <<- EOF
# vim: set ai et ts=2 sts=2 sw=2:

# WARNING: This Dockerfile is auto-generated; do not modify directly. For more
# details, see README.md at the top level of this repository.
EOF
