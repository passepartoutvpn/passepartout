#!/bin/bash
cwd=`dirname $0`
source $cwd/env.sh
source $cwd/env.secrets.sh
cd $cwd/..

set -e
if [[ -z $certs_passphrase ]]; then
    echo "Passphrase required"
    exit 1
fi
rm -rf $tmp_root
mkdir $tmp_root
cp "$certs_p12_path" "$certs_profiles_root"/*.mobileprovision "$certs_profiles_root"/*.provisionprofile "$tmp_root"
rm -f "$certs_zip_path"
zip -ejr9 -P "$certs_passphrase" "$certs_zip_path" "$tmp_root"
