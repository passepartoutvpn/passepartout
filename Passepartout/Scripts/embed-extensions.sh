#!/bin/sh
app_root="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app"
appex_src="${BUILT_PRODUCTS_DIR}/PassepartoutTunnel.appex"
sysex_src="${BUILT_PRODUCTS_DIR}/com.algoritmico.mac.Passepartout.Tunnel.systemextension"
#codesign_identity="${EXPANDED_CODE_SIGN_IDENTITY}"
cp_alias="cp -rP"

if [ "$CONFIGURATION" == "ReleaseMac" ]; then
    #codesign --force --sign "$codesign_identity" "$sysex_src" --timestamp=none
    sysex_dst="${app_root}/Contents/Library/SystemExtensions"
    mkdir "$sysex_dst"
    $cp_alias "$sysex_src" "$sysex_dst"
    exit
fi

#codesign --force --sign "$codesign_identity" "$appex_src" --timestamp=none
if [ "$PLATFORM_NAME" == "macosx" ]; then
    appex_dst="${app_root}/Contents/PlugIns"
else
    appex_dst="${app_root}/PlugIns"
fi
mkdir "$appex_dst"
$cp_alias "$appex_src" "$appex_dst"
