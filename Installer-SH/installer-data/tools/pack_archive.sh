#!/usr/bin/env bash
# This Script part of "Installer-SH"

Path_To_Script="$( dirname "$(readlink -f "$0")")"
MD5_File="$Path_To_Script/MD5-Hash.txt"

InputDataFolder="$Path_To_Script/base_data"
OutputBaseArchive="$Path_To_Script/base_data.tar.xz"
CurrentDateAndTime="$(date "+%Y-%m-%d_%H-%M-%S")"

function create_base_archive() {
	local temp_pwd="$PWD"
	local exit_code=""
	cd "$InputDataFolder" || exit
	tar -cJf "$OutputBaseArchive" -- *
	exit_code="$?"
	if [ "$exit_code" -eq 0 ]; then
		echo -e "The archive has been successfully created."
	else
		echo -e "Error creating archive (exit code: $exit_code). Exit!"
		cd "$temp_pwd" || exit
		exit 1
	fi
	cd "$temp_pwd" || exit
}

function check_files() {
	if [ -e "$OutputBaseArchive" ]; then
		echo -e "The archive already exists: $OutputBaseArchive"
		echo -e " Creating a backup..."
		if mv -T "$OutputBaseArchive" "$OutputBaseArchive""_$CurrentDateAndTime"; then
			echo " Archive backup created: $OutputBaseArchive""_$CurrentDateAndTime"
		else
			echo -e " Error creating backup copy of existing archive... Exit!"
			exit 1
		fi
	fi
	
	if [ ! -d "$InputDataFolder" ]; then
		echo -e "Input data folder not found. Exit!"
		exit 1
	fi
	
	if [ -z "$(ls -A "$InputDataFolder")" ]; then
		echo "The directory intended for archiving is empty! Exit!"
		exit 1
	fi
}

function create_md5_hash() {
	MD5_DATA=$(md5sum "$OutputBaseArchive" | awk '{print $1}')
	echo "$(basename "$OutputBaseArchive"): $MD5_DATA" >> "$MD5_File"
}

check_files
create_base_archive
create_md5_hash

read -r -p "Pause..."

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
