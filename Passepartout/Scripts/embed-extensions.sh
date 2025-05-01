#!/bin/sh
app_root="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app"
login_src="${BUILT_PRODUCTS_DIR}/PassepartoutLoginItem.app"
appex_src="${BUILT_PRODUCTS_DIR}/PassepartoutTunnel.appex"
sysex_src="${BUILT_PRODUCTS_DIR}/com.algoritmico.mac.Passepartout.Tunnel.systemextension"
mkdir_alias="mkdir -p"
cp_alias="cp -rP"

if [ "$PLATFORM_NAME" == "macosx" ]; then
    login_dst="${app_root}/Contents/Library/LoginItems"
    $mkdir_alias "$login_dst"
    $cp_alias "$login_src" "$login_dst"
fi

if [ "$CONFIGURATION" == "ReleaseMac" ]; then
    sysex_dst="${app_root}/Contents/Library/SystemExtensions"
    $mkdir_alias "$sysex_dst"
    $cp_alias "$sysex_src" "$sysex_dst"
    exit
fi

if [ "$PLATFORM_NAME" == "macosx" ]; then
    appex_dst="${app_root}/Contents/PlugIns"
else
    appex_dst="${app_root}/PlugIns"
fi
$mkdir_alias "$appex_dst"
$cp_alias "$appex_src" "$appex_dst"
