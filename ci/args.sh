#!/bin/bash
POSITIONAL_ARGS=()

# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash

while [[ $# -gt 0 ]]; do
  case $1 in
    -b)
      OPT_BUILD="$2"
      shift # past argument
      shift # past value
      ;;
    -s)
      OPT_SINCE="$2"
      shift # past argument
      shift # past value
      ;;
    -n)
      OPT_NO_LOG=1
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

if [[ -n $OPT_DRY_RUN ]]; then
    echo "BUILD   = ${OPT_BUILD}"
    echo "SINCE   = ${OPT_SINCE}"
    echo "NO_LOG  = ${OPT_NO_LOG}"
    exit 0
fi
