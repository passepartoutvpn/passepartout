#!/bin/bash
cwd=`dirname $0`
source $cwd/env.sh
cd $cwd/..

cd $translations_output_path

# Base language file
base_file="en.lproj/Localizable.strings"
keys_file="keys.tmp"

# Extract all keys from the base file
sed -n 's/^"\(.*\)"[[:space:]]*=.*/"\1"/p' "$base_file" >"$keys_file"

# Process all other localization files
for dir in *.lproj; do
    if [[ "$dir" != "en.lproj" && -d "$dir" ]]; then
        target_file="$dir/Localizable.strings"

        if [[ -f "$target_file" ]]; then
            echo "Cleaning $target_file..."

            # Use grep to filter only keys that exist in the base file
            grep -f "$keys_file" "$target_file" > "$target_file.tmp"

            # Overwrite the original file with the cleaned version
            mv "$target_file.tmp" "$target_file"
        fi
    fi
done

rm "$keys_file"
echo "Localization files cleaned."
