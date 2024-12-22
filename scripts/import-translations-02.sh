#!/bin/bash
cwd=`dirname $0`
source $cwd/env.sh
cd $cwd/..

for lang in `ls $translations_input_path`; do
    input_path="$translations_input_path/$lang"
    output_path="$translations_output_path/$lang.lproj/Localizable.strings"
    keys_path="$output_path.keys"
    tmp_path="$output_path.tmp"

    # remove keys
    sed -E 's/^"(.*)" = .*$/\1/' $input_path >$keys_path
    grep -vf $keys_path $output_path >$tmp_path

    # append new strings
    cat $input_path >>$tmp_path

    # sort and replace
    sort $tmp_path >$output_path
    rm "$keys_path" "$tmp_path"
done
