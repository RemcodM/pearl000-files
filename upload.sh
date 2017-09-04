#!/bin/bash

DIR="$(cd ""$(dirname ""${BASH_SOURCE[0]}"")"" && pwd)"
OUTPUT_FILE="$(mktemp)"

if [[ "$1" == "help" ]] || [[ "$1" == "" ]]; then
	echo "Usage: $0 port filename"
	exit 0
fi

echo "-- Converting to hex..."
if [[ -x "$DIR/hex2hex/hex2hex" ]]; then
	"$DIR/hex2hex/hex2hex" < "$2" > "$OUTPUT_FILE"
	ERROR_CODE=$?
elif [[ -n $(which python) ]]; then
	python "$DIR/hex2hex/hex2hex.py" < "$2" > "$OUTPUT_FILE"
	ERROR_CODE=$?
else
	ERROR_CODE=9
fi
if [[ $ERROR_CODE -ne 0 ]]; then
	echo "-- Aborted due to error (exit code $ERROR_CODE)."
	rm -f "$OUTPUT_FILE"
	exit $ERROR_CODE
fi

echo "-- Uploading..."
avrdude -q -q -patmega328p -carduino -P "$1" -b115200 -D "-Uflash:w:$OUTPUT_FILE:i"
ERROR_CODE=$?
rm -f "$OUTPUT_FILE"
if [[ $ERROR_CODE -ne 0 ]]; then
	echo "-- Aborted due to error (exit code $ERROR_CODE)."
	exit $ERROR_CODE
fi

echo "-- OK!"
