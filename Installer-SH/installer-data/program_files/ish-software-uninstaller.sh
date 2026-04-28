#!/usr/bin/env bash
# Script version 2.2
# LICENSE for this script is at the end of this file
## ----------------------- ----------------------- ----------------------- ----------------------- ----------------------- ----------------------- ##
## ----------------------- ----------------------- ----------------------- ----------------------- ----------------------- ----------------------- ##
Path_To_Script="$( dirname "$(readlink -f "$0")")" # Current script directory.

# Font styles: "${Font_Bold} BOLD TEXT ${Font_Reset} normal text."
Font_Bold="\e[1m"
Font_Reset="\e[22m"
Font_Reset_Color='\e[38;5;255m'
#Font_Reset_BG='\e[48;5;16m'

Font_Red='\e[38;5;210m'
Font_Green='\e[38;5;82m'
Font_Yellow='\e[38;5;226m'

## ----------------------- ----------------------- ----------------------- ----------------------- ----------------------- ----------------------- ##
## ----------------------- ----------------------- ----------------------- ----------------------- ----------------------- ----------------------- ##

Current_DE="$XDG_SESSION_DESKTOP"
Header="${Font_Red}${Font_Bold} -=: Software Uninstaller Script (Installer-SH) :=-${Font_Reset}${Font_Reset_Color}\n"
printf '\033[8;30;110t' # Resize terminal Window

function _CLEAR_BACKGROUND() {
	clear; clear
	#echo -ne '\e]11;black\e\\'; echo -ne '\e]10;white\e\\'
	echo -ne '\e[48;5;232m';    echo -ne '\e[38;5;255m'
}

# Welcome message
_CLEAR_BACKGROUND
_CLEAR_BACKGROUND
echo -e "$Header"

if_sudo="false"

function _remove {
	local file="$1"
	if [ -e "$file" ]; then
		echo -ne "Removing: $file"
		if [ "$if_sudo" == "false" ]; then
			if rm -rf "$file"; then
				echo -ne " - ok.\n"
			else
				echo -ne "\n ${Font_Yellow}${Font_Bold}Need root rights... Try with sudo.${Font_Reset}${Font_Reset_Color}\n"
				if sudo rm -rf "$file"; then if_sudo="true"; fi
			fi
		else 
			if sudo rm -rf "$file"; then echo -ne " - ok.\n"
			else echo -e " Something went wrong..."; fi
		fi
	else
		echo -e "Object not found, skip:\n $file"
	fi
}

FilesToDelete=(
)

# Display info and wait confirmation
echo -e "\
 XDG_SESSION_DESKTOP: $Current_DE
 
 ${Font_Bold}${Font_Yellow}Attention! Make sure that you do not have any important data in the program directory!${Font_Reset_Color}${Font_Reset}
  $Path_To_Script
 
 ${Font_Red}${Font_Bold}The listed files and directories will be deleted if they are present in the system!${Font_Reset_Color}${Font_Reset}"

echo -e "${Font_Bold} - Files to be deleted:${Font_Reset}"
for i in "${!FilesToDelete[@]}"; do echo "   ${FilesToDelete[$i]}"; done

echo -e "\n Enter \"${Font_Bold}y${Font_Reset}\" or \"${Font_Bold}yes${Font_Reset}\" to begin uninstallation."
Confirm=""
read -r Confirm

# Run if confirm
if [ "$Confirm" == "y" ] || [ "$Confirm" == "yes" ]; then
	for i in "${!FilesToDelete[@]}"; do _remove "${FilesToDelete[$i]}"; done
	
	if type "update-desktop-database" &> /dev/null; then
		update-desktop-database ~/.local/share/applications &> /dev/null
		update-desktop-database /usr/share/applications &> /dev/null
	fi
	
	echo -e "\n ${Font_Bold}${Font_Green}Uninstallation completed.${Font_Reset_Color}${Font_Reset}\n"
fi

echo " Press Enter to exit or close this window."
read -r Confirm

# MIT License
#
# Copyright (c) 2024-2026 Андрей Цымбалов (Chimbal)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
