# Pearl 000 Arduino toolset for Linux based operating systems
This repository contains a linux version of the Arduino toolset needed to perform the assignments of Pearl 000. It is based on the Windows version of the toolset with little modifications. Please note that instead of cutecom suggested in the module guide, we use `putty` as a replacement. Both provide the same functionality.

## Installation
Clone the git repository into any folder on your filesystem, or download a ZIP file of the repository and unpack this somewhere on your filesystem. Then, proceed based on your linux distribution.

### Debian based (Debian, Ubuntu, Mint, etc.)
The included `install.sh` script will install all needed tools on your computer. Open a terminal and navigate to the directory in which you placed the repository files. From there, run:
```
# ./install.sh
```
This will install all needed packages and compile the C version of hex2hex, when possible. Otherwise the included python version is used.

### Other distros
The `install.sh` script included in the repository will not work for distro's that do no use the `apt` package manager. Please install the `avra`, `avrdude` and `putty` packages yourself using the package manager of your distro. Some hints:

**Arch Linux**: `avrdude` and `putty` can be easily installed using the official repositories and `pacman`, for `avra`, make use of the Arch User Repository (AUR): https://aur.archlinux.org/packages/avra/

**Fedora**: All packages can be found in the Fedora repositories, just install them using `dnf` (or `yum` on older systems).

## Usage
The scripts `upload.sh` and `asmupload.sh` can be used to upload assignments to the Arduino. The `upload.sh` script uses `hex2hex` (included with this repository) to assemble hex files and uses `avrdude` to upload the result to the Arduino. You will need this script in exercises 7-11. The `asmupload.sh` script uses the `avra` assembler to assemble programs written in the higher level assembly and again uses `avrdude` to upload the result to the Arduino. You will need this script in exercises 12-14 as well as the bonus assignments.

### Assembling hex files using `upload.sh`
When the `upload.sh` script is invoked without arguments, the usage is printed:
```
# ./upload.sh
Usage: ./upload.sh port filename
```
Replace `port` with the device entry of your Arduino, for example `/dev/ttyACM0` on many Debian systems. To find this device entry, read the next section. Replace `filename` with the hex file you wrote, for example `exercise.txt`. So, for example:
```
# ./upload.sh /dev/ttyACM0 exercise.txt 
-- Converting to hex...
-- Uploading...
-- OK!
```
When you see the `-- OK!` line, your program has succesfully been uploaded to the Arduino.

### Assembling higher level assembly files using `asmupload.sh`
When the `asmupload.sh` script is invoked without arguments, the usage is printed:
```
# ./asmupload.sh
Usage: ./asmupload.sh port filename
```
Replace `port` with the device entry of your Arduino, for example `/dev/ttyACM0` on many Debian systems. To find this device entry, read the next section. Replace `filename` with the assembly file you wrote, for example `exercise.txt`. So, for example:
```
# ./asmupload.sh /dev/ttyACM0 exercise.txt 
-- Converting to hex...
AVRA: advanced AVR macro assembler Version 1.3.0 Build 1 (8 May 2010)
Copyright (C) 1998-2010. Check out README file for more info

   AVRA is an open source assembler for Atmel AVR microcontroller family
   It can be used as a replacement of 'AVRASM32.EXE' the original assembler
   shipped with AVR Studio. We do not guarantee full compatibility for avra.

   AVRA comes with NO WARRANTY, to the extent permitted by law.
   You may redistribute copies of avra under the terms
   of the GNU General Public License.
   For more information about these matters, see the files named COPYING.

Pass 1...
Pass 2...
done

Used memory blocks:
   Code      :  Start = 0x0000, End = 0x0046, Length = 0x0047

Assembly complete with no errors.
Segment usage:
   Code      :        71 words (142 bytes)
   Data      :         0 bytes
   EEPROM    :         0 bytes
-- Uploading...
```
When you see the `-- Uploading...` line, without any errors, the program has succesfully been uploaded to the Arduino.

## Finding the Arduino device entry
When the Arduino is connected to a Linux based operating system using the USB connection, Linux will automatically detect the Arduino as a USB serial device and place a device entry in `/dev/`. However, the device entry may be called different across distros and Linux kernel versions. To make finding the Arduino device entry easier, use the included `detect.sh` script. When you call it, follow the instructions on screen:
```
# ./detect.sh
Unplug the Arduino when plugged in. Then press enter.
Plug in the Arduino now. Then press enter to continue.
Possible devices for the Arduino are:
/dev/ttyACM0
```
Look for the `Possible devices for the Arduino are:` line. All lines following this lines list the devices added to your computer during the execution of the script. In this case, only the Arduino was connected and detected as `/dev/ttyACM0`.

## Reading the serial connection using `putty`.
In the module guide, `cutecom` is advised as a way to read the serial connection under Linux based operating systems. However, you can also use `putty`, which is also used by the Windows toolset. To open the serial console using putty, execute the following command in a terminal
```
# putty -serial PORT -sercfg 115200
```
Replace `PORT` with your device entry, for example:
```
# putty -serial /dev/ttyACM0 -sercfg 115200
```
This will open a new window with the serial output. Make sure to close `putty` when uploading a new program, or else you will get error messages from `avrdude`, which won't be able to upload the newer program to your Arduino while `putty` is using it.
