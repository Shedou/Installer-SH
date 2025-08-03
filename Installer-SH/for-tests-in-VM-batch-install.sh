#!/usr/bin/env bash

confirmation=""

Path_To_Script="$( dirname "$(readlink -f "$0")")"

###### SET THIS UP BEFORE USE!!! ######
Installers=(
"$Path_To_Script/ProgramOne/installer.sh"
"$Path_To_Script/ProgramTwo/installer.sh"
"$Path_To_Script/ProgramThree/installer.sh"
)

### InstallLast:
### If the desktop environment is supported,
### the menu will be automatically updated after installing this application.
### Remove the value of this variable if you do not want to update the menu after installing all applications.
InstallLast="$Path_To_Script/ProgramFour/installer.sh"


echo -e "
 ATTENTION! Configure this script before using!

 This script automatically installs many applications in Intaller-SH format
  using silent mode.
 
 Enter \"y\" or \"yes\" to continue!"

function InstallFile() {
	file="$1"
	mode="$2"
	if [ -e "$file" ]; then
		echo -e " Installing: $file"
		if ! [[ -x "$file" ]]; then chmod +x "$file"; fi
		
		if [ "$mode" == "NoUpdateMenu" ]; then
			"$file" -silent -noupdmenu
		else
			"$file" -silent
		fi
	else
		echo -e "File not found: $file"
	fi
}

read -r confirmation

if [ "$confirmation" == "y" ] || [ "$confirmation" == "yes" ]; then

	for i in "${!Installers[@]}"; do InstallFile "${Installers[$i]}" "NoUpdateMenu"; done
	if [ "$InstallLast" != "" ]; then InstallFile "$InstallLast" "sss"; fi
fi

echo "end."
read -r confirmation

