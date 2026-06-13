#!/usr/bin/env bash

confirmation=""

Path_To_Script="$( dirname "$(readlink -f "$0")")"

echo -e "
 This script automatically installs many applications in Installer-SH format
  using silent mode.
 Working template: $Path_To_Script/*/installer.sh
 Attention! Check the list of files to be installed:"
for dir in "$Path_To_Script/"*; do
	if [ -d "$dir" ]; then
		if [ -f "$dir/installer.sh" ]; then
			echo "$dir/installer.sh"
		fi
	fi
done
echo -e "\n Enter \"y\" or \"yes\" to continue!"

function InstallFile() {
	local file="$1"
	if [ -e "$file" ]; then
		echo -e " Installing: $file"
		if ! [[ -x "$file" ]]; then chmod +x "$file"; fi
		"$file" -silent
	else
		echo -e "File not found: $file"
	fi
}

read -r confirmation

if [ "$confirmation" == "y" ] || [ "$confirmation" == "yes" ]; then
	for dir in "$Path_To_Script/"*; do
		if [ -d "$dir" ]; then
			if [ -f "$dir/installer.sh" ]; then
				#echo "Dir: $dir"
				InstallFile "$dir/installer.sh"
			fi
		fi
	done
fi

echo "End (pause)"
read -r confirmation

