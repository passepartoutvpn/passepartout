#!/bin/bash
cwd=`dirname $0`
source $cwd/env.sh
cd $cwd/..

# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash

positional_args=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -v)
      opt_version="$2"
      shift # past argument
      shift # past value
      ;;
    -b)
      opt_build="$2"
      shift # past argument
      shift # past value
      ;;
    -s)
      opt_since="$2"
      shift # past argument
      shift # past value
      ;;
    -na)
      opt_no_api=1
      shift # past argument
      ;;
    -nl)
      opt_no_log=1
      shift # past argument
      ;;
    -nt)
      opt_no_tag=1
      shift
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
set -e

cwd=`dirname $0`
cmd_api="$cwd/update-bundled-api.sh"

if [[ -n $opt_dry_run ]]; then
    echo "version = $opt_version"
    echo "build   = $opt_build"
    echo "since   = $opt_since"
    echo "no_api  = $opt_no_api"
    echo "no_log  = $opt_no_log"
    echo "no_tag  = $opt_no_tag"
    if [[ -z $opt_no_api ]]; then
        echo "$cmd_api"
    fi
    exit 0
fi

if [[ -z $opt_no_api ]]; then
    eval "$cmd_api"
fi

if [[ $opt_no_log != "1" ]]; then
    echo "Generate CHANGELOG..."
    if [[ -z "$opt_since" ]]; then
        opt_since=`git describe --abbrev=0 --tags`
    fi
    git_range="$opt_since..HEAD"
    log=$(git log $git_range --pretty="* %s" --date=short)
    log_path="$changelog.tmp"
    echo "$log" >"$log_path"

    set +e
    $EDITOR "$log_path"
    editor_exit=$?
    set -e

    echo "Editor exited with code $editor_exit"
    if [[ $editor_exit != 0 ]]; then
        echo "CHANGELOG editor cancelled"
        rm "$log_path"
        exit 1
    fi

    echo "Copy CHANGELOG..."
    mv "$log_path" "$changelog"
fi

if [[ -z "$opt_build" ]]; then
    current_build=`ci/xcconfig-get.sh "$xcconfig_path" CURRENT_PROJECT_VERSION`
    opt_build=$((current_build + 1))
fi
echo "Set build number to $opt_build..."
ci/xcconfig-set.sh "$xcconfig_path" CURRENT_PROJECT_VERSION "$opt_build"

if [[ -n "$opt_version" ]]; then
    echo "Set version number to $opt_version..."
    ci/xcconfig-set.sh $xcconfig_path MARKETING_VERSION "$opt_version"
fi

if [[ $opt_no_log != "1" ]]; then
    echo "Copy CHANGELOG to release notes..."
    scripts/copy-release-notes.sh
fi

echo "Commit changes to repository..."
git add \
    "$xcconfig_path" \
    "$api_package_path" \
    "$metadata_root" \
    "$changelog"

git commit -m "Bump version"

if [[ -z "$opt_no_tag" ]]; then
    tag="builds/$opt_build"
    echo "Tag commit as $tag..."
    git tag -as "$tag" -m "$tag"
fi

echo "Done!"
