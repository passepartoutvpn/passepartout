#!/bin/sh
git push && git push github
git push --tags && git push --tags github
git checkout stable && git merge master
git push github
git checkout master
