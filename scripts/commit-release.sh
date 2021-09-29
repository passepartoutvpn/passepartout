#!/bin/sh
CURRENT_BRANCH=`git branch --show-current`
if [[ $CURRENT_BRANCH != "master" ]]; then
    echo "Not on master branch"
    exit
fi

ci/update-asc-metadata.sh mac
ci/update-asc-metadata.sh ios
