#!/bin/bash
for lang in `ls -d *.lproj`; do
    src="$lang/Localizable.strings"
    sort $src | grep -v ^$ | grep -v ^// >tmp.strings
    mv tmp.strings $src
done
