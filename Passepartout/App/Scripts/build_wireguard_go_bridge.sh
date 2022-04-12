#!/bin/sh

# build_wireguard_go_bridge.sh - Builds WireGuardKitGo
#
# Figures out the directory where the wireguard-apple SPM package
# is checked out by Xcode (so that it works when building as well as
# archiving), then cd-s to the WireGuardKitGo directory
# and runs make there.

project_data_dir="$BUILD_DIR"

# The wireguard-apple README suggests using ${BUILD_DIR%Build/*}, which
# doesn't seem to work. So here, we do the equivalent in script.

while true; do
    parent_dir=$(dirname "$project_data_dir")
    basename=$(basename "$project_data_dir")
    project_data_dir="$parent_dir"
    if [ "$basename" = "Build" ]; then
        break
    fi
done

# The wireguard-apple README looks into
# SourcePackages/checkouts/wireguard-apple, but Xcode seems to place the
# sources in SourcePackages/checkouts/ so just playing it safe and
# trying both.

checkouts_dir="$project_data_dir"/SourcePackages/checkouts
if [ -e "$checkouts_dir"/wireguard-apple ]; then
    checkouts_dir="$checkouts_dir"/wireguard-apple
fi

wireguard_go_dir="$checkouts_dir"/Sources/WireGuardKitGo

# To ensure we have Go in our path, we add where
# Homebrew generally installs executables
export PATH=${PATH}:/opt/homebrew/bin:/usr/local/bin:/usr/local/go/bin

cd "$wireguard_go_dir" && /usr/bin/make
