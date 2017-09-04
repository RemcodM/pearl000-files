#!/bin/bash

read -p "Unplug the Arduino when plugged in. Then press enter."

TEMP_FILE=$(mktemp)
ls -d /dev/* > "$TEMP_FILE"

read -p "Plug in the Arduino now. Then press enter to continue."

echo "Possible devices for the Arduino are:"
comm -1 -3 "$TEMP_FILE" <(ls -d /dev/*)
rm -f "$TEMP_FILE"
exit 0
