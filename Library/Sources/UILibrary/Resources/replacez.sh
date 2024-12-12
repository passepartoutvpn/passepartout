#!/bin/bash
for lang in `ls -d *.lproj`; do
    src="$lang/Localizable.strings"
    grep -f list.txt -v $src >tmp.strings
    mv tmp.strings $src
done
