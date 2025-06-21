#!/usr/bin/env bash
# This Script part of "Installer-SH"

Dictionary_Size_Base_Data="8"

Path_To_Script="$( dirname "$(readlink -f "$0")")"

Szip_bin="$Path_To_Script/7zip/7zzs"
MD5_File="$Path_To_Script/MD5-Hash.txt"

Base_Data="$Path_To_Script/base_data"
Base_Data_Archive="$Path_To_Script/base_data.tar.xz"

function _pack_archive() {
	Name_File="$1"
	DSize="$2"
	Name_File_Target="$(basename "$3")"
	Name_File_Target_full="$3"
	
	if [ -e "$Name_File" ]; then
		if [ -e "$Name_File_Target" ]; then mv -T "$Name_File.tar.xz" "$Name_File-old""_$RANDOM"".tar.xz"; fi
		cd "$Name_File" || exit
		tar -cf ../"$Name_File_Target" -I "xz -9 --lzma2=dict=$DSize"M -- *
	fi
	MD5_DATA=$(md5sum "$Name_File_Target_full" | awk '{print $1}')
	echo "$(basename "$Name_File_Target_full"): $MD5_DATA" >> "$MD5_File"
}

_pack_archive "$Base_Data" "$Dictionary_Size_Base_Data" "$Base_Data_Archive"

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
