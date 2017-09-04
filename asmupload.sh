#!/bin/bash

OUTPUT_FILE="$(mktemp)"

if [[ "$1" == "help" ]] || [[ "$1" == "" ]]; then
	echo "Usage: $0 port filename"
	exit 0
fi

echo "-- Converting to hex..."
avra "$2" -o "$OUTPUT_FILE"
ERROR_CODE=$?
if [[ $ERROR_CODE -ne 0 ]]; then
	echo "-- Aborted due to error (exit code $ERROR_CODE)."
	rm -f "$OUTPUT_FILE"
	exit $ERROR_CODE
fi
rm "$2.eep.hex"
rm "$2.obj"
rm "$2.cof"

echo "-- Uploading..."
avrdude -q -q -patmega328p -carduino -P "$1" -b115200 -D "-Uflash:w:$OUTPUT_FILE:i"
ERROR_CODE=$?
rm "$OUTPUT_FILE"
if [[ $ERROR_CODE -ne 0 ]]; then
	echo "-- Aborted due to error (exit code $ERROR_CODE)."
	exit $ERROR_CODE
fi
