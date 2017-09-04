#!/bin/bash

read -p "Unplug the Arduino when plugged in. Then press enter."

OUTPUT_FILE="$(mktemp)"
ls -d /dev/* > "$OUTPUT_FILE"

read -p "Plug in the Arduino now. Then press enter to continue."

echo "Possible devices for the Arduino are:"
comm -1 -3 "$OUTPUT_FILE" <(ls -d /dev/*)
rm -f "$OUTPUT_FILE"
exit 0
