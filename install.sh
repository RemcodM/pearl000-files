#!/bin/bash
## Arduino tools installation script.
## Part of the pearl Computer Architecture of module Pearls of Computer Science
## Written by Remco de Man for the University of Twente
##
## This script installs the needed Arduino tools for macOS and Linux.
## In essence, it ensures the following things:
## (1) A working version of hex2hex is available, that means one of the
##     following:
##     (1.1) There is an existing binary of hex2hex/hex2hex
##     (1.2) A working version is compiled using hex2hex/hex2hex.c and
##           a locally installed C compiler.
##     (1.3) The python version can be used using a Python interpeter
## (2) Under macOS only, ensure we have access to the XCode command line
##     tools, install them automatically when we don't have them
## (3) Under macOS only, ensure that we have a working Homebrew
##     environment, as per https://brew.sh/. Maybe installed if missing.
## (4) Ensure that we have a working version of avrdude. On Debian based
##     systems this may be installed using APT. On macOS this may be
##     installed using Homebrew.
## (5) Ensure that we have a working version of avra. On Debian based
##     systems this may be installed using APT. On macOS this may be
##     installed using Homebrew.
## (6) Ensure that we have a working version of putty under Linux, or
##     screen under macOS. Putty is more convenient to use but does not
##     work quite well under macOS. Putty may be installed using APT
##     on Debian based systems. GNU screen may be installed using
##     Homebrew on macOS based systems.
## If any of the above `requirements` cannot be resolved, the script will
## stop and inform the user.
## This script does itself not install any files outside of the directory
## the script lives in, however:
## (-) On macOS, it does install XCode command line tools and Homebrew,
##     furthermore, it installs the following Homebrew packages:
##     (1) avra
##     (2) avrdude
##     (3) screen
## (-) On Debian based systems, it might install the following APT packages
##     (1) avra
##     (2) avrdude
##     (3) putty
##     You can remove them later if you want. Use the `--autoremove` flag
##     to also uninstall the dependencies automcatically installed. See
##     `man apt` for more details.
## Usage:
##  install

# Setup some environment variables that contain control characters to change
# the text color and background color of the console output.
TEXT_BOLD=$(tput bold)
TEXT_NORMAL=$(tput sgr0)
TEXT_RED=$(tput setaf 1)
TEXT_GREEN=$(tput setaf 2)
TEXT_YELLOW=$(tput setaf 3)
TEXT_BLUE=$(tput setaf 4)

# Bash oneliner to get the directory the scripts lives in.
DIR="$(dirname "${BASH_SOURCE[0]}")"

function check_error {
	# Simple function which checks if there was an error based on
	# an error code provided as the first argument. Returns the error
	# code if there was in fact an error.
	if [[ "$1" -ne 0 ]]; then
		echo -e "${TEXT_RED}error, exit code $1${TEXT_NORMAL}"
		return $1
	fi
}

function detect_required_program {
	# Function which detects if the program given in the first argument
	# actually is on the PATH of the running system. Using `which` ensures
	# that we also detect aliases/symlinks may someone use a different, but
	# hopefully compatible, tool. Returns correctly if the required program
	# is detected.
	echo -e -n "> $1: "
	local PROGRAM="$(which $2)"
	if [[ -n "$PROGRAM" ]]; then
		echo -e "${TEXT_GREEN}found${TEXT_NORMAL} at ${TEXT_BOLD}${PROGRAM}${TEXT_NORMAL}"
		return 0
	fi
	echo -e "${TEXT_RED}not found${TEXT_NORMAL}"
	echo -e "${TEXT_BLUE}${TEXT_BOLD}Hint:${TEXT_NORMAL} $1 is missing. Please install it first. In most cases, the package will be called '$2'."
	return 1
}

function detect_optional_program {
	# Function which detects if the program given in the first argument
	# actually is on the PATH of the running system. Using `which` ensures
	# that we also detect aliases/symlinks may someone use a different, but
	# hopefully compatible, tool. Returns correctly if the program is
	# detected.
	echo -e -n "> $1: "
	local PATH="$(which $2)"
	if [[ -n "$PATH" ]]; then
		echo -e "${TEXT_GREEN}found${TEXT_NORMAL} at ${TEXT_BOLD}${PATH}${TEXT_NORMAL}"
		return 0
	fi
	echo -e "${TEXT_YELLOW}optional${TEXT_NORMAL}"
	return 1
}

function detect_hex2hex {
	# Function which detects if the hex2hex dependency is somehow
	# executable.
	local CC=0
	local PYTHON=0
	detect_optional_program "C compiler" "cc" && CC=1
	detect_optional_program "Python" "python" && PYTHON=1

	echo -e -n "> hex2hex: "
	if [[ -x "hex2hex/hex2hex" ]]; then
		# If there is already a binary hex2hex executable found within
		# the tools folder, we will use this to resolve the dependency.
		echo -e "${TEXT_GREEN}found${TEXT_NORMAL} at ${TEXT_BOLD}${DIR}/hex2hex/hex2hex${TEXT_NORMAL}"
	elif [[ -f "hex2hex/hex2hex.c" ]] && [[ "${CC}" == "1" ]]; then
		# If there does exist a hex2hex binary yet, but we have the
		# source code and a working compiler, then compile the source
		# code into a binary and use this to resolve the dependency.
		echo -e -n "${TEXT_NORMAL}compiling ${TEXT_NORMAL}"
		cc hex2hex/hex2hex.c -o hex2hex/hex2hex
		check_error "$?" || exit 1
		echo -e "${TEXT_GREEN}done${TEXT_NORMAL}"
	elif [[ -f "hex2hex/hex2hex.py" ]] && [[ "${PYTHON}" == "1" ]]; then
		# If there is no way to get a working hex2hex binary, but we
		# do have a Python interpreter and a Python version of hex2hex
		# then, use this to resolve the hex2hex dependency.
		echo -e "${TEXT_GREEN}found at ${TEXT_BOLD}${DIR}/hex2hex/hex2hex.py${TEXT_NORMAL}"
	else
		# If we after all these options failed to get the hex2hex
		# dependency resolved, we give up.
		echo -e "${TEXT_RED}not found${TEXT_NORMAL}"
		return 1
	fi
}

function detect_xcode_tools {
	# Function which detects if the XCode command line tools are installed.
	# These tools are needed under macOS to provide certain functionality
	# on the command line, such as a working C compiler and Git. It has no
	# useful effect under Linux. We need this to install homebrew under
	# macOS, which we need to install all needed tools.
	echo -e "${TEXT_BLUE}${TEXT_BOLD}Hint:${TEXT_NORMAL} The script will now try to install the XCode Developer Command Line tools."
	echo -e "${TEXT_BLUE}${TEXT_BOLD}Hint:${TEXT_NORMAL} This might show an confirmation dialog. Please press install when asked."
	xcode-select --install
	echo -e -n "\n"
}

function detect_brew {
	# Function which tries to resolve the Homebrew dependency under macOS.
	# It first checks if there is already a working `brew` command. If
	# there is not, install the Homebrew according to the instructions
	# on the Homebrew webpage, https://brew.sh/index_nl.
	# This should not be run under Linux. Linux does not need it as we
	# already have access to all needed GNU tools (under normal
	# circumstances).
	echo -e -n "> Homebrew: "
	local PROGRAM="$(which brew)"
	if [[ -n "$PROGRAM" ]]; then
		echo -e "${TEXT_GREEN}found${TEXT_NORMAL} at ${TEXT_BOLD}${PROGRAM}${TEXT_NORMAL}"
		return 0
	fi

	echo -e "${TEXT_YELLOW}launching installation...${TEXT_NORMAL}"
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	echo -e -n "\n> Homebrew: "
	check_error "$?" || exit 1
	echo -e "${TEXT_GREEN}done${TEXT_NORMAL}"
}

function detect_or_install_brew {
	# Function which tries to resolve a certain brew package under macOS.
	# The description of the brew package is given as first argument to
	# this function, the name of the package as second argument. If the
	# package is not yet installed, the function will try to install it.
	echo -e -n "> $1: "
	local PROGRAM="$(which $2)"
	if [[ -n "$PROGRAM" ]]; then
		echo -e "${TEXT_GREEN}found${TEXT_NORMAL} at ${TEXT_BOLD}${PROGRAM}${TEXT_NORMAL}"
		return 0
	fi

	echo -e -n "${TEXT_NORMAL}installing ${TEXT_NORMAL}"
	brew install $2 &> /dev/null
	if check_error "$?"; then
		echo -e "${TEXT_GREEN}done${TEXT_NORMAL}"
	else
		echo -e "${TEXT_BLUE}${TEXT_BOLD}Hint:${TEXT_NORMAL} Error while installing package '$2'. Try manually installing the package using 'brew install $2' and try again."
		return 1
	fi
}

function detect_or_install_apt {
	# Function which tries to resolve an installed package under Debian
	# based Linux distributions (the ones that use APT as their package
	# manager).
	# The description of the brew package is given as first argument to
        # this function, the name of the package as second argument. If the
        # package is not yet installed, the function will try to install it.
	echo -e -n "> $1: "
	local PROGRAM="$(which $2)"
	if [[ -n "$PROGRAM" ]]; then
		echo -e "${TEXT_GREEN}found${TEXT_NORMAL} at ${TEXT_BOLD}${PROGRAM}${TEXT_NORMAL}"
		return 0
	fi

	echo -e -n "${TEXT_NORMAL}installing ${TEXT_NORMAL}"
	apt-get install -q -y $2 &> /dev/null
	if check_error "$?"; then
		echo -e "${TEXT_GREEN}done${TEXT_NORMAL}"
	else
		echo -e "${TEXT_BLUE}${TEXT_BOLD}Hint:${TEXT_NORMAL} Error while installing package '$2'. Maybe you should run the script as root? Try manually installing the package using 'apt install $2' and try again."
		return 1
	fi
}

echo -e "${TEXT_NORMAL}Arduino Tools configure script for Linux/macOS${TEXT_NORMAL}"
pushd "$DIR" > /dev/null

# Detect our OS type first.
if [[ $OSTYPE == darwin* ]]; then
	# Seems like we are on a macOS based system.
	echo -e "Detected ${TEXT_BLUE}macOS${TEXT_NORMAL}\n"

	# First check if we have access to the XCode command line tools.
	# Install them when neccessary.
	detect_xcode_tools

	# Resolve a working version of hex2hex.
	detect_hex2hex || (echo -e "${TEXT_BLUE}${TEXT_BOLD}Hint:${TEXT_NORMAL} Please install a C compiler or the Python runtime first." && exit 1)

	# Resolve homebrew for access to more command line tools.
	detect_brew

	# Ensure we have `avrdude` installed via Homebrew such that we
	# can upload programs to the Arduino.
	detect_or_install_brew "avrdude uploader" "avrdude" || exit 1

	# Ensure we have `avra` installed via Homebrew such that we
	# can assemble programs for the Arduino.
	detect_or_install_brew "avra assembler" "avra" || exit 1

	# Ensure we have GNU `screen` installed for reading serial
	# connections.
	detect_or_install_brew "screen" "screen" || exit 1
elif [[ $OSTYPE == linux* ]]; then
	# Seems like we are on a Linux based system, let's check which kind...
	if [[ -n "$(which apt-get)" ]]; then
		# We are on a Debian based system. We can use APT to
		# install tools that are missing.
		echo -e "Detected ${TEXT_BLUE}Debian-based Linux${TEXT_NORMAL}\n"

		# Resolve a working version of hex2hex.
		detect_hex2hex || (echo -e "${TEXT_BLUE}${TEXT_BOLD}Hint:${TEXT_NORMAL} Please install a C compiler or the Python runtime first." && exit 1)

		# Ensure we have `avrdude` installed such that we
		# can upload programs to the Arduino.
		detect_or_install_apt "avrdude uploader" "avrdude" || exit 1

		# Ensure we have `avra` installed via Homebrew such that we
		# can assemble programs for the Arduino.
		detect_or_install_apt "avra assembler" "avra" || exit 1

		# Ensure that we have `putty` installed for reading the serial
		# output of the Arduino.
		detect_or_install_apt "putty" "putty" || exit 1
	else
		# We are on a non-Debian based system (Fedora, Arch, etc.).
		# The script can only give advice on missing tools, but not
		# install them automatically.
		echo -e "Detected ${TEXT_BLUE}Linux${TEXT_NORMAL}\n"

		# Resolve a working version of hex2hex.
		detect_hex2hex || (echo -e "${TEXT_BLUE}${TEXT_BOLD}Hint:${TEXT_NORMAL} Please install a C compiler or the Python runtime first." && exit 1)

		# Ensure we have `avrdude` installed such that we
		# can upload programs to the Arduino.
		detect_required_program "avrdude uploader" "avrdude" || exit 1

		# Ensure we have `avra` installed such that we
		# can assemble programs for the Arduino.
		detect_required_program "avra assembler" "avra" || exit 1

		# Ensure that we have `putty` installed for reading the serial
		# output of the Arduino.
		detect_required_program "putty" "putty" || exit 1
	fi
else
	# We did not successfully detect macOS of Linux. Let's... just stop.
	echo -e "${TEXT_RED}Unknown OS${TEXT_NORMAL}"
	echo -e "${TEXT_BLUE}${TEXT_BOLD}Hint:${TEXT_NORMAL} Run this script on a compatible operating system to continue."
	exit 1
fi

echo -e "\n${TEXT_GREEN}${TEXT_BOLD}Successful:${TEXT_NORMAL} All tools are installed and successfully configured."
