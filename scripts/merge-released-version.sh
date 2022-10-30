#!/bin/bash
VERSION_PREV=$1
if [[ -z $VERSION_PREV ]]; then
    echo "Released version number required"
    exit 1
fi

RELEASE_BASE=`git merge-base master "v$VERSION_PREV" 2>>/dev/null`
if [[ $? != 0 ]]; then
    echo "Version does not exist"
    exit 1
fi

COMMITS_COUNT=`git rev-list --count $RELEASE_BASE..v$VERSION_PREV`
if [[ $COMMITS_COUNT == 0 ]]; then
    echo "Version is already merged"
    exit 1
fi

if ! git checkout -b "merge/v$VERSION_PREV" master; then
    echo "Could not create merge branch"
    exit 1
fi
if ! git cherry-pick $RELEASE_BASE.."v$VERSION_PREV"; then
    echo "Automatic cherry-picking has failed"
    exit 1
fi
