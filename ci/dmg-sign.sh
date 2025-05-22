#!/bin/bash
cwd=`dirname $0`
name="Passepartout"
arch="$1"
gpg_fingerprint="$2"
gpg_passphrase="$3"

if [[ -z "$arch" ]]; then
    echo "Missing arch"
    exit 1
fi
if [[ -z $gpg_fingerprint ]]; then
    echo "Missing GPG fingerprint"
    exit 1
fi
if [[ -z $gpg_passphrase ]]; then
    echo "Missing GPG passphrase"
    exit 1
fi

dmg="$name.$arch.dmg"
gpg_batch_args="--batch --yes --pinentry-mode loopback"

echo "Signing .dmg..."
gpg $gpg_batch_args --armor --sign-with "$gpg_fingerprint" --passphrase "$gpg_passphrase" --detach-sign "$dmg"
echo "Verifying .dmg..."
gpg $gpg_batch_args --verify "$dmg.asc" "$dmg"
