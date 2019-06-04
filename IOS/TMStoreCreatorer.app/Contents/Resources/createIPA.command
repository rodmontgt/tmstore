#!/bin/bash -vx
export LANG=en_US.UTF-8
export TERM=${TERM:-dumb}
WORKSPACE_PATH="$1"
IPA_FULL_NAME="$2_V$3_B$4"
IPA_TYPE="$5"
WORKSPACE_NAME="TMStore.xcworkspace"
PROJECT_SCHEME_NAME="$2"
IPA_DIR="OutputFiles"
WORKSPACE_FILE_PATH="$WORKSPACE_PATH/$WORKSPACE_NAME"
IPA_DIR_PATH="$WORKSPACE_PATH/$IPA_DIR"
IPA_TEMP_PATH="$IPA_DIR_PATH/$IPA_FULL_NAME.ipa"
DSYM_TEMP_PATH="$IPA_DIR_PATH/$IPA_FULL_NAME.app.dSYM.zip"
/usr/local/bin/gym -a -c -w "$WORKSPACE_FILE_PATH" -s "$PROJECT_SCHEME_NAME" -o "$IPA_DIR_PATH" -j "$IPA_TYPE" -n "$IPA_FULL_NAME"
#gym -a -c -w "$WORKSPACE_FILE_PATH" -s "$PROJECT_SCHEME_NAME" -o "$IPA_DIR_PATH" -j "$IPA_TYPE" -n "$IPA_FULL_NAME"
rm "$DSYM_TEMP_PATH"
open "$IPA_DIR_PATH"
osascript -e 'tell application "Terminal" to close first window' & exit




