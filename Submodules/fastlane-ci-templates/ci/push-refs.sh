#!/bin/bash
if !(git checkout master && git push && git push github); then
    echo "Error while pushing master"
    exit 1
fi
if !(git push --tags && git push --tags github); then
    echo "Error while pushing tags"
    exit 1
fi
if !(git checkout stable && git merge master && git push github); then
    echo "Error while pushing stable"
    exit 1
fi
git checkout master
