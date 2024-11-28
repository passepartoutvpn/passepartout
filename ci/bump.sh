#!/bin/bash
# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -v)
      OPT_VERSION="version:$2"
      shift # past argument
      shift # past value
      ;;
    -b)
      OPT_BUILD="build:$2"
      shift # past argument
      shift # past value
      ;;
    -s)
      OPT_SINCE="since:$2"
      shift # past argument
      shift # past value
      ;;
    -na)
      OPT_NO_API=1
      shift # past argument
      ;;
    -nl)
      OPT_NO_LOG="no_log:true"
      shift # past argument
      ;;
    -d)
      OPT_DRY_RUN=1
      shift # past argument
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

CMD_API=$(dirname "$0")/update-bundled-api.sh
CMD_RELEASE_NOTES=$(dirname "$0")/update-release-notes.sh
CMD_FASTLANE="bundle exec fastlane bump $OPT_VERSION $OPT_BUILD $OPT_SINCE $OPT_NO_LOG"

if [[ -n $OPT_DRY_RUN ]]; then
    echo "VERSION = $OPT_VERSION"
    echo "BUILD   = $OPT_BUILD"
    echo "SINCE   = $OPT_SINCE"
    echo "NO_API  = $OPT_NO_API"
    echo "NO_LOG  = $OPT_NO_LOG"
    if [[ -z $OPT_NO_API ]]; then
        echo "$CMD_API"
    fi
    echo "$CMD_RELEASE_NOTES"
    echo "$CMD_FASTLANE"
    exit 0
fi

if [[ -z $OPT_NO_API ]]; then
    eval "$CMD_API"
fi
eval "$CMD_RELEASE_NOTES"
eval "$CMD_FASTLANE"
