#!/usr/bin/env bash
# This Script part of "Installer-SH"

# Larger size - better compression and more RAM required for unpacking. (256m dictionary requires 256+ MB of RAM for unpacking)
# For applications 150-200 MiB in size, use a dictionary size of 32 - 128m, it is not recommended to use a dictionary size greater than 256m.
Dictionary_Size_Base_Data="2m"

Path_To_Script="$( dirname "$(readlink -f "$0")")"
Spacer="\n ===========================================\n ===========================================\n ==========================================="

Szip_bin="$Path_To_Script/7zip/7zzs"
MD5_File="$Path_To_Script/MD5-Hash.txt"

Base_Data="$Path_To_Script/base_data"

function _pack_archive() {
	Name_File="$1"
	DSize="$2"
	if [ -e "$Szip_bin" ]; then
		if [ -e "$Name_File" ]; then
			if [ -e "$Name_File.7z" ]; then mv -T "$Name_File.7z" "$Name_File-old""_$RANDOM""_$RANDOM"".7z"; fi
			echo -e "$Spacer"
			"$Szip_bin" a -snl -mx6 -m0=LZMA2:d$DSize -ms=8m -mqs=on -mmt=3 "$Name_File.7z" "$Name_File/."
			MD5_DATA=`md5sum "$Name_File.7z" | awk '{print $1}'`
			echo "$(basename $Name_File.7z): $MD5_DATA" >> "$MD5_File"
		fi
	else echo " 7-Zip binary not found, abort."
	fi
}

_pack_archive "$Base_Data" "$Dictionary_Size_Base_Data"

echo -e "$Spacer"
echo -e "\n Pause..."
read pause

# MIT License
#
# Copyright (c) 2024 Chimbal
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
