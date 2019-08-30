#!/bin/bash
## Machine code upload script for Arduino
## Part of the pearl Computer Architecture of module Pearls of Computer Science
## Written by Remco de Man for the University of Twente
##
## This script uploads hexadecimal text files to the Arduino.
## Usage:
##  upload DEVICE ASSEMBLY_FILE

# Check if the usage is correct.
if [[ "$1" == "help" ]] || [[ "$1" == "" ]] || [[ "$2" == "" ]]; then
	echo "Usage: $0 port filename"
	exit 0
fi

# Bash oneliner to get the directory the scripts lives in.
DIR="$(cd ""$(dirname ""${BASH_SOURCE[0]}"")"" && pwd)"

# Create a temporary output file, this will contains the machine code.
OUTPUT_FILE="$(mktemp)"

# Convert the text file containing the hexadecimal program to machine code...
echo "-- Converting to hex..."
if [[ -x "$DIR/hex2hex/hex2hex" ]]; then
	# If we have a binary version of hex2hex, we will happily use this.
	# The machine code will be written to our temporary file.
	"$DIR/hex2hex/hex2hex" < "$2" > "$OUTPUT_FILE"
	ERROR_CODE=$?
elif [[ -n $(which python) ]]; then
	# If we do not have a binary version of hex2hex, but we do in fact
	# find Python on the PATH, then use the provided Python version.
	# The machine code will be written to our temporary file.
	python "$DIR/hex2hex/hex2hex.py" < "$2" > "$OUTPUT_FILE"
	ERROR_CODE=$?
else
	# We could not find any version of hex2hex that works. Abort...
	ERROR_CODE=9
fi
if [[ $ERROR_CODE -ne 0 ]]; then
	# If we somehow failed to generate the machine code, cleanup
        # and return the error to the user.
	echo "-- Aborted due to error (exit code $ERROR_CODE)."
	rm -f "$OUTPUT_FILE"
	exit $ERROR_CODE
fi

# Upload the machine code to the Arduino using avrdude.
echo "-- Uploading..."
avrdude -q -q -patmega328p -carduino -P "$1" -b115200 -D "-Uflash:w:$OUTPUT_FILE:i"
ERROR_CODE=$?
rm -f "$OUTPUT_FILE"
if [[ $ERROR_CODE -ne 0 ]]; then
	# If avrdude has failed for some reason, return the error code.
	echo "-- Aborted due to error (exit code $ERROR_CODE)."
	exit $ERROR_CODE
fi

echo "-- OK!"
