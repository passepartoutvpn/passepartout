#!/bin/bash
# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash

positional_args=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -v)
      opt_version="version:$2"
      shift # past argument
      shift # past value
      ;;
    -b)
      opt_build="build:$2"
      shift # past argument
      shift # past value
      ;;
    -s)
      opt_since="since:$2"
      shift # past argument
      shift # past value
      ;;
    -na)
      opt_no_api=1
      shift # past argument
      ;;
    -nl)
      opt_no_log="no_log:true"
      shift # past argument
      ;;
    -d)
      opt_dry_run=1
      shift # past argument
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      positional_args+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${positional_args[@]}" # restore positional parameters

cwd=`dirname $0`
cmd_api="$cwd/update-bundled-api.sh"
cmd_release_notes="$cwd/copy-release-notes.sh"
cmd_fastlane="cd $cwd/.. && bundle exec fastlane bump $opt_version $opt_build $opt_since $opt_no_log"

if [[ -n $opt_dry_run ]]; then
    echo "version = $opt_version"
    echo "build   = $opt_build"
    echo "since   = $opt_since"
    echo "no_api  = $opt_no_api"
    echo "no_log  = $opt_no_log"
    if [[ -z $opt_no_api ]]; then
        echo "$cmd_api"
    fi
    echo "$cmd_release_notes"
    echo "$cmd_fastlane"
    exit 0
fi

if [[ -z $opt_no_api ]]; then
    eval "$cmd_api"
fi
eval "$cmd_release_notes"
eval "$cmd_fastlane"
