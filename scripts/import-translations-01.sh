#!/bin/bash
cwd=`dirname $0`
source $cwd/env.sh
cd $cwd/..

if [[ -z "$1" ]]; then
    echo "Input strings file required"
    exit 1
fi

translations=`cat "$1"`
mkdir -p "$translations_input_path"

# Split translations into separate files
echo "$translations" | awk -v input_path="$translations_input_path" '
BEGIN {
    lang_code = "";
}
/^\/\/ [a-z]{2}/ {
    # Save the language code from lines starting with "//"
    lang_code = substr($0, 4);  # Extract language code (e.g., "de")
    next;
}
/^$/ {
    # Skip empty lines
    next;
}
{
    # Write to the appropriate language file
    if (lang_code != "") {
        file_path = input_path "/" lang_code;
        print $0 >> file_path;
    }
}
' "$1"

echo "Files have been created in the '$translations_input_path' directory."
