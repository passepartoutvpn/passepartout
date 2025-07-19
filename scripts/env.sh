#!/bin/bash
tmp_root=./tmp
xcconfig_path="Passepartout/Config.xcconfig"
platforms="iOS macOS tvOS"
devices="mac iphone ipad appletv"
changelog="CHANGELOG.txt"
metadata_root="fastlane/metadata"
metadata_path="default/release_notes.txt"
certs_p12_path="/Volumes/Personale/Passepartout/certificates.p12"
certs_profiles_root=~/Library/Developer/Xcode/UserData/Provisioning\ Profiles
certs_zip_path="../notes/certificates.zip"
certs_tmp_root="$tmp_root/certs"
translations_input_path="l10n"
translations_output_path="Packages/App/Sources/AppStrings/Resources"
