# Pearl 000 Arduino Toolset for macOS and Linux based operating systems
This repository contains the supporting tools for fulfilling the Arduino assignments of the first pearl under Linux and macOS. It is based on the Windows version of the toolset with little modifications.

## Installation
Clone the git repository into any folder on your filesystem, or download a ZIP file of the repository and unpack this somewhere on your filesystem. Then, proceed based on your operating system.

### macOS
The included `install.sh` script will install all needed tools on your computer. First, launch the terminal from the Launchpad or by searching for 'Terminal' in Spotlight. In the terminal, navigate to the directory in which you have unpacked the files. The easiest way to do this is by typing `cd ` and then dragging the folder with the downloaded files to the terminal. This will result in (for example):
```
# cd /Users/remco/Downloads/pearl000-files
```
Press enter to navigate to this directory. Once here, run the `install.sh` script, by typing:
```
# ./install.sh
```
Follow the instructions on the screen. If everything went well, you should see `Successful: All tools are installed and successfully configured.` at the end of the terminal screen.

### Debian based Linux installation (Debian, Ubuntu, Mint, etc.)
The included `install.sh` script will install all needed tools on your computer. Open a terminal and navigate to the directory in which you placed the repository files. From there, run:
```
# ./install.sh
```
This will install and configure all needed packages and tools. If everything went well, you should see `Successful: All tools are installed and successfully configured.` at the end of the terminal screen.

### Other Linux based installations (Fedora, Arch Linux, Gentoo, others)
The included `install.sh` script will compile the needed hex2hex tool and gives instructions about installing missing packages. Because the script only supports automated installation of the missing tools on Debian based Linux installations, it cannot automatically install all packages. It will only give hints about how to proceed.

Open a terminal and navigate to the directory in which you placed the repository files. From there, run:
```
# ./install.sh
```

Follow the instructions on the screen. You might have to install multiple packages. After multiple runs of the `install.sh` script, you should see `Successful: All tools are installed and successfully configured.` at the end of the terminal screen.

#### Some useful hints for installing packages on different installations

**Arch Linux**: `avrdude` and `putty` can be easily installed using the official repositories and `pacman`, for `avra`, make use of the Arch User Repository (AUR): https://aur.archlinux.org/packages/avra/

**Fedora**: All packages can be found in the Fedora repositories, just install them using `dnf` (or `yum` on older systems).

## Usage
The scripts `upload.sh` and `asmupload.sh` can be used to upload assignments to the Arduino. The `upload.sh` script uses `hex2hex` (included with this repository) to assemble hex files and uses `avrdude` to upload the result to the Arduino. You will need this script in exercises 1.7-1.11. The `asmupload.sh` script uses the `avra` assembler to assemble programs written in the higher level assembly and again uses `avrdude` to upload the result to the Arduino. You will need this script in exercises 1.12-1.14 as well as the bonus assignments.

### Assembling hex files using `upload.sh`
When the `upload.sh` script is invoked without arguments, the usage is printed:
```
# ./upload.sh
Usage: ./upload.sh port filename
```
Replace `port` with the device entry of your Arduino. `/dev/ttyACM0` or `/dev/tty.usbmodem1111` are examples of device entries on respectively Debian based systems and macOS. If you are unsure about how to find the correct device entry, please read the next section. Replace `filename` with the hex file you wrote, for example, `exercise.txt`. This will write:
```
# ./upload.sh /dev/ttyACM0 exercise.txt 
-- Converting to hex...
-- Uploading...
-- OK!
```
When you see the `-- OK!` line, your program has successfully been uploaded to the Arduino.

### Assembling higher level assembly files using `asmupload.sh`
When the `asmupload.sh` script is invoked without arguments, the usage is printed:
```
# ./asmupload.sh
Usage: ./asmupload.sh port filename
```
Replace `port` with the device entry of your Arduino. `/dev/ttyACM0` or `/dev/tty.usbmodem1111` are examples of device entries on respectively Debian based systems and macOS. If you are unsure about how to find the correct device entry, please read the next section. Replace `filename` with the assembly file you wrote, for example, `exercise.txt`. This will write:
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
When you see the `-- Uploading...` line, without any errors, the program has successfully been uploaded to the Arduino.

## Finding the Arduino device entry
When the Arduino is connected to a Linux or macOS based system using the USB connection, the kernel will automatically detect the Arduino as a USB serial device and place a device entry in `/dev/`. However, the device entry may be called different across different systems. To make finding the Arduino device entry easier, use the included `detect.sh` script. When you call it, follow the instructions on the screen:
```
# ./detect.sh
Unplug the Arduino if already plugged in. Then press enter.
Plug in the Arduino now. Then press enter to continue.
Possible devices for the Arduino are:
/dev/ttyACM0
```
Look for the `Possible devices for the Arduino are:` line. All lines following this lines list the devices added to your computer during the execution of the script. In this case, only the Arduino was connected and detected as `/dev/ttyACM0`.

## Reading the serial connection 
To read out the data written to the serial connection by your Arduino, we need a tool to read out the serial connection.

### Reading the serial connection on macOS using `screen`.
On macOS, the serial connection can be most easily read out using the `screen` command. Run the following command in a terminal.
```
# screen PORT 9600
```
Replace `PORT` with your device entry, for example:
```
# screen /dev/tty.usbmodem1111 9600
```
This will show the output in your terminal. Make sure to close `screen` when uploading a new program, or else you will get error messages from `avrdude`, which won't be able to upload the newer program to your Arduino while `screen` is using it.

To quit `screen` press `Control-A` and then press `\`

### Reading the serial connection on Linux using `putty`.
On Linux, you can use the `putty` tool to read out the serial connection, just as on Windows. To open the serial console using `putty`, execute the following command in a terminal
```
# putty -serial PORT -sercfg 9600
```
Replace `PORT` with your device entry, for example:
```
# putty -serial /dev/ttyACM0 -sercfg 9600
```
This will open a new window with the serial output. Make sure to close `putty` when uploading a new program, or else you will get error messages from `avrdude`, which won't be able to upload the newer program to your Arduino while `putty` is using it.
