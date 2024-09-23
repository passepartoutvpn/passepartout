#!/bin/bash
HOSTNAME=`echo $MATCH_GIT_URL | sed -E "s/^.*@(.*):.*$/\1/"`
grep -q $HOSTNAME ~/.ssh/known_hosts
if [[ $? != 0 ]]; then
    ssh-keyscan $HOSTNAME 2>/dev/null >>~/.ssh/known_hosts
fi
