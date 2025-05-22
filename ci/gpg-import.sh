#!/bin/bash
key_file="$1"
if [[ -z "$key_file" ]]; then
    echo "Missing key file"
    exit 1
fi
gpg --batch --yes --pinentry-mode loopback --import "$key_file"
