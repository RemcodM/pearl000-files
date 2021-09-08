#!/bin/bash
## Assembly upload script for Arduino
## Part of the pearl Computer Architecture of module Pearls of Computer Science
## Written by Remco de Man for the University of Twente
##
## This script uploads assembly files to the arduino.
## Usage:
##  asmupload DEVICE ASSEMBLY_FILE

# Check if the usage is correct.
if [[ "$1" == "help" ]] || [[ "$1" == "" ]] || [[ "$2" == "" ]]; then
	echo "Usage: $0 port filename"
	exit 0
fi

# Bash oneliner to get the directory the scripts lives in.
DIR="$(cd ""$(dirname ""${BASH_SOURCE[0]}"")"" && pwd)"

# Create a temporary output file, this will contains the machine code.
OUTPUT_FILE="$(mktemp)"

# Use the avra tool to convert the assembly to valid machine code.
echo "-- Converting to hex..."
avra -I "$DIR" "$2"
ERROR_CODE=$?
if [[ $ERROR_CODE -ne 0 ]]; then
	# If avra has failed, cleanup the temporary file. Return the error.
	echo "-- Aborted due to error (exit code $ERROR_CODE)."
	rm -f "$OUTPUT_FILE"
	exit $ERROR_CODE
fi

# If .asm is used, strip file extension
if [[ "${2: -4}" == ".asm" ]]; then
	STRIPPED_FN="${2%.*}"
else
	STRIPPED_FN="${2}"
fi

# All this cleaning up is needed because avra never implemented all their
# fileout parameters...
# Basically it deletes all the extra files avra creates in the process. We
# cannot control how avra writes these from the command line because the
# avra source code reveals they are never implemented, although they are
# mentioned within the documentation.
rm "$STRIPPED_FN.eep.hex"
rm "$STRIPPED_FN.obj"
rm "$STRIPPED_FN.cof"
mv "$STRIPPED_FN.hex" "$OUTPUT_FILE"

# Upload our machine code to the Arduino using avrdude
echo "-- Uploading..."
avrdude -q -q -patmega328p -carduino -P "$1" -b115200 -D "-Uflash:w:$OUTPUT_FILE:i"
ERROR_CODE=$?
rm -f "$OUTPUT_FILE"
if [[ $ERROR_CODE -ne 0 ]]; then
	# If avrdude has failed for some reason, return the error code.
	echo "-- Aborted due to error (exit code $ERROR_CODE)."
	exit $ERROR_CODE
fi
