#!/usr/bin/env bash
# This Script part of "Installer-SH"

Path_To_Script="$( dirname "$(readlink -f "$0")")"
remove_ok=false

function remove() {
	Name_File="$1"
	if [ -e "$Name_File" ]; then rm -rf "$Name_File"
	else echo " $Name_File - not found"; fi
}


function main_f() {
	echo -e " Removes unnecessary files and directories.\n USE ONLY AFTER COMPLETING AND TESTING THE PACKAGE.\n \"y\" to delete..."
	read confirm
	if [ "$confirm" == "y" ] || [ "$confirm" == "yes" ]; then remove_ok=true
	else echo "Abort"; read pause; exit; fi

	if [ $remove_ok == true ]; then
		remove "$Path_To_Script/MD5-Hash.txt"
		remove "$Path_To_Script/program_files"
		remove "$Path_To_Script/system_files"
		remove "$Path_To_Script/user_files"
		remove "$Path_To_Script/pack_archives.sh"
		remove "$Path_To_Script/tools/MD5-Hash.txt"
		remove "$Path_To_Script/tools/pack_archive.sh"
		remove "$Path_To_Script/tools/base_data"
		
		remove "$Path_To_Script/clean.sh" # This file
	fi
	
	echo -e "\n Pause..."
	read pause
}

main_f
