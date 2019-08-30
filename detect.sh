#!/bin/bash
## Arduino port detection script
## Part of the pearl Computer Architecture of module Pearls of Computer Science
## Written by Remco de Man for the University of Twente
##
## This script can be used to find the UNIX serial device that corresponds to
## the Arduino. Usually /dev/ttyACMX under Linux and /dev/tty.usbmodemXXXX
## under macOS
## Usage:
##  detect

# Ask the user to unplug the Arduino if it is already plugged in.
read -p "Unplug the Arduino if already plugged in. Then press enter."

# Do some magic, we write all devices in /dev currently connected to the system
# to a temporary file.
OUTPUT_FILE="$(mktemp)"
find /dev -maxdepth 1 -not -type d | sort > "$OUTPUT_FILE"

# Ask the user to now plug in the Arduino.
read -p "Plug in the Arduino now. Then press enter to continue."

# Again, list all the devices in /dev, and compare it with our temporary file.
# We show the difference in files in /dev. This works for detecting the
# Arduino as long as this is the only device change on the system. In fact,
# if someone has plugged in another device in the meantime, it will also show
# up.
echo "Possible devices for the Arduino are:"
comm -1 -3 "$OUTPUT_FILE" <(find /dev -maxdepth 1 -not -type d | sort)

# Cleanup our temporary file.
rm -f "$OUTPUT_FILE"
exit 0
