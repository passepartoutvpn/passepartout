#!/bin/sh
CURRENT_BRANCH=`git branch --show-current`
if [[ $CURRENT_BRANCH != "master" ]]; then
    echo "Not on master branch"
    exit
fi
if !(git checkout stable && git merge master && git push github); then
    echo "Error while pushing stable"
    exit
fi
git checkout master
