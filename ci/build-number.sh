#!/bin/sh
BASE=`agvtool what-version -terse`
COUNT=`git rev-list --count master`
echo $((BASE + COUNT))
