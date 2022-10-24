#!/bin/bash
PLIST_COMMAND="Add :com.algoritmico.Passepartout.config:app_type integer 2"
PLIST_PATH="Passepartout/App/Info.plist"
/usr/libexec/PlistBuddy -c "$PLIST_COMMAND" "$PLIST_PATH"

