#!/bin/bash
cwd=`dirname $0`
source $cwd/env.sh
cd $cwd/..

if [[ -n "$1" ]]; then
    platforms="$1"
fi
for platform in $platforms; do
    release_notes="$metadata_root/$platform/$metadata_path"
    rm -f "$release_notes"
    cp "$changelog" "$release_notes"
done
