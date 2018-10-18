#!/bin/sh
BASE=`agvtool what-version -terse`
COUNT=`git rev-list --count HEAD`
echo $((BASE + COUNT))
