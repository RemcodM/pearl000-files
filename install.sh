#!/bin/bash

install_package() {
	if [[ -n $(which apt-get) ]]; then
		echo "->> Installing package(s): $1..."
		apt-get install -q -y --allow-change-held-packages $1 &> /dev/null
		ERROR_CODE=$?
		if [[ "$ERROR_CODE" -ne 0 ]]; then
			echo "-!! An error occured while installing package $1. Please install them manually!"
			return 1
		fi
		return 0
	fi
	echo "-!! Cannot install packages on non-apt based system. Please install the package $1 manually!"
	return 0
}

check_error() {
	if [[ "$1" -ne 0 ]]; then
		echo "-!! An error occured, exit code: $1."
		exit $1
	fi
}

if [[ "$EUID" -ne 0 ]]; then
	echo "Please run this script as root!"
	exit 1
fi

echo "- Detecting hex2hex..."
if [[ -x "hex2hex/hex2hex" ]]; then
	echo "-> Detected native hex2hex in hex2hex/hex2hex."
elif [[ -f "hex2hex/hex2hex.c" ]] && [[ -n $(which gcc) ]]; then
	echo "-> Detected hex2hex source code and working C compiler."
	echo "->> Compiling hex2hex.c..."
	gcc hex2hex/hex2hex.c -o hex2hex/hex2hex
	check_error $?
elif [[ -f "hex2hex/hex2hex.py" ]] && [[ -n $(which python) ]]; then
	echo "-> Detected python hex2hex in hex2hex/hex2hex.py."
elif [[ -f "hex2hex/hex2hex.py" ]]; then
	echo "-> Detected hex2hex python source without working python."
	install_package python
	check_error $?
else
	echo "Could not install working hex2hex version."
	check_error 1
fi

for package in $(echo "avrdude avra putty"); do
	echo "- Detecting $package"
	if [[ -n $(which $package) ]]; then
		echo "-> Detected working $package installation."
	else
		echo "-> No working install of $package detected."
		install_package $package
		check_error $?
	fi
done

echo "Installation successful!"
