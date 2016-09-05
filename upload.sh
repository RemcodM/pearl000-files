#!/bin/bash

OUTPUT_FILE=hex2hex/output.hex

if [[ "$1" == "help" ]] || [[ "$1" == "" ]]; then
	echo "Usage: $0 port filename"
	exit 0
fi

echo "-- Converting to hex..."
if [[ -f "$OUTPUT_FILE" ]]; then
	rm "$OUTPUT_FILE"
fi
if [[ -x "hex2hex/hex2hex" ]]; then
	hex2hex/hex2hex < $2 > $OUTPUT_FILE
	ERROR_CODE=$?
elif [[ -n $(which python) ]]; then
	python hex2hex/hex2hex.py < $2 > $OUTPUT_FILE
	ERROR_CODE=$?
else
	ERROR_CODE=9
fi
if [[ $ERROR_CODE -ne 0 ]]; then
	echo "-- Aborted due to error (exit code $ERROR_CODE)."
	exit $ERROR_CODE
fi

echo "-- Uploading..."
avrdude -q -q -patmega328p -carduino -P $1 -b115200 -D -Uflash:w:$OUTPUT_FILE:i
ERROR_CODE=$?
if [[ $ERROR_CODE -ne 0 ]]; then
	echo "-- Aborted due to error (exit code $ERROR_CODE)."
	exit $ERROR_CODE
fi

echo "-- OK!"
