#!/bin/bash

TEXT_BOLD=$(tput bold)
TEXT_NORMAL=$(tput sgr0)
TEXT_RED=$(tput setaf 1)
TEXT_GREEN=$(tput setaf 2)
TEXT_YELLOW=$(tput setaf 3)
TEXT_BLUE=$(tput setaf 4)

DIR="$(dirname "${BASH_SOURCE[0]}")"

function check_error {
	if [[ "$1" -ne 0 ]]; then
		echo -e "${TEXT_RED}error, exit code $1${TEXT_NORMAL}"
		return $1
	fi
}

function detect_required_program {
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
	local CC=0
	local PYTHON=0
	detect_optional_program "C compiler" "cc" && CC=1
	detect_optional_program "Python" "python" && PYTHON=1

	echo -e -n "> hex2hex: "
	if [[ -x "hex2hex/hex2hex" ]]; then
		echo -e "${TEXT_GREEN}found${TEXT_NORMAL} at ${TEXT_BOLD}${DIR}/hex2hex/hex2hex${TEXT_NORMAL}"
	elif [[ -f "hex2hex/hex2hex.c" ]] && [[ "${CC}" == "1" ]]; then
		echo -e -n "${TEXT_NORMAL}compiling ${TEXT_NORMAL}"
		cc hex2hex/hex2hex.c -o hex2hex/hex2hex
		check_error "$?" || exit 1
		echo -e "${TEXT_GREEN}done${TEXT_NORMAL}"
	elif [[ -f "hex2hex/hex2hex.py" ]] && [[ "${PYTHON}" == "1" ]]; then
		echo -e "${TEXT_GREEN}found at ${TEXT_BOLD}${DIR}/hex2hex/hex2hex.py${TEXT_NORMAL}"
	else
		echo -e "${TEXT_RED}not found${TEXT_NORMAL}"
		return 1
	fi
}

function detect_xcode_tools {
	echo -e "${TEXT_BLUE}${TEXT_BOLD}Hint:${TEXT_NORMAL} The script will now try to install the XCode Developer Command Line tools."
	echo -e "${TEXT_BLUE}${TEXT_BOLD}Hint:${TEXT_NORMAL} This might show an confirmation dialog. Please press install when asked."
	xcode-select --install
	echo -e "\n"
}

function detect_brew {
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

if [[ $OSTYPE == darwin* ]]; then
	echo -e "Detected ${TEXT_BLUE}macOS${TEXT_NORMAL}\n"
	detect_xcode_tools
	detect_hex2hex || (echo -e "${TEXT_BLUE}${TEXT_BOLD}Hint:${TEXT_NORMAL} Please install a C compiler or the Python runtime first." && exit 1)
	detect_brew
	detect_or_install_brew "avrdude uploader" "avrdude" || exit 1
	detect_or_install_brew "avra assembler" "avra" || exit 1
	detect_or_install_brew "screen" "screen" || exit 1
elif [[ $OSTYPE == linux* ]]; then
	if [[ -n "$(which apt-get)" ]]; then
		echo -e "Detected ${TEXT_BLUE}Debian-based Linux${TEXT_NORMAL}\n"
		detect_hex2hex || (echo -e "${TEXT_BLUE}${TEXT_BOLD}Hint:${TEXT_NORMAL} Please install a C compiler or the Python runtime first." && exit 1)
		detect_or_install_apt "avrdude uploader" "avrdude" || exit 1
		detect_or_install_apt "avra assembler" "avra" || exit 1
		detect_or_install_apt "putty" "putty" || exit 1
	else
		echo -e "Detected ${TEXT_BLUE}Linux${TEXT_NORMAL}\n"
		detect_hex2hex || (echo -e "${TEXT_BLUE}${TEXT_BOLD}Hint:${TEXT_NORMAL} Please install a C compiler or the Python runtime first." && exit 1)
		detect_required_program "avrdude uploader" "avrdude" || exit 1
		detect_required_program "avra assembler" "avra" || exit 1
		detect_required_program "putty" "putty" || exit 1
	fi
else
	echo -e "${TEXT_RED}Unknown OS${TEXT_NORMAL}"
	echo -e "${TEXT_BLUE}${TEXT_BOLD}Hint:${TEXT_NORMAL} Run this script on a compatible operating system to continue."
	exit 1
fi

echo -e "\n${TEXT_GREEN}${TEXT_BOLD}Successful:${TEXT_NORMAL} All tools are installed and successfully configured."
