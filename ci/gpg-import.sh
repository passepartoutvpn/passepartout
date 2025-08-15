#!/bin/bash
key_content="$1"
if [[ -z "$key_content" ]]; then
    echo "Missing key file"
    exit 1
fi
key_file="gpg.key"
echo "$key_content" >"$key_file"
gpg --batch --yes --pinentry-mode loopback --import "$key_file"
rm "$key_file"
