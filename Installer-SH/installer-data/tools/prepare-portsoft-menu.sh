#!/usr/bin/env bash
# This Script part of "Installer-SH"
# LICENSE for this script is at the end of this file

######### --------- #########
Base_Header="${Font_Red}${Font_Bold} -=: Preparing PortSoft and Menu (Installer-SH part) :=-${Font_Reset}${Font_Reset_Color}\n"
Base_Temp_Dir="/tmp/chimbalix-portsoft-menu-prepare""_$RANDOM""_$RANDOM" # TEMP Directory

######### - Archive path - #########
Archive_Base_Data="$Path_Installer_Data/tools/base_data.7z"
Archive_Base_Data_MD5="6bb60828b9e2b98d08ffbbf4145c2c0e"

function _BASE_MAIN() {
	_BASE_PRINT_INFO
	_BASE_CHECK_MD5
	_BASE_CREATE_TEMP
	_BASE_PREPARE_FILES
	if [ "$Install_Mode" == "System" ]; then _BASE_INSTALL_SYSTEM; else _BASE_INSTALL_USER; fi;
	_BASE_DELETE_TEMP
	_BASE_INSTALL_COMPLETE
}

function _BASE_PRINT_INFO() {
if [ "$MODE_SILENT" == "false" ]; then
	_CLEAR_BACKGROUND
	echo -e "\
$Base_Header
 ${Font_Bold}${Font_Cyan}$Str_BASEINFO_Head${Font_Reset_Color}${Font_Reset}

  $Str_BASEINFO_Warning

 -${Font_Bold}${Font_Yellow}$Str_BASEINFO_PortSoft${Font_Reset_Color}${Font_Reset}
   $Str_BASEINFO_PortSoft_Full
     $Output_PortSoft
  
 -${Font_Bold}${Font_Yellow}$Str_BASEINFO_MenuApps${Font_Reset_Color}${Font_Reset}
   $Str_BASEINFO_MenuApps_Full
     $Output_Menu_Files/apps.menu
     $Output_Menu_DDir/apps.directory
     $Output_Menu_DDir/apps.png
  
  $Str_BASEINFO_Attention

 -${Font_Bold}${Font_DarkGreen}$Str_PACKAGEINFO_CurrentOS${Font_Reset_Color} $Current_OS_Name_Full ($Current_DE)${Font_Reset}
 -${Font_Bold}${Font_DarkGreen}$Str_PACKAGEINFO_InstallMode${Font_Reset_Color} $Install_Mode${Font_Reset}"
	
	echo -e "\n $Str_BASEINFO_Confirm"
	read base_info_confirm
	if [ "$base_info_confirm" == "y" ] || [ "$base_info_confirm" == "yes" ]; then :
	else _ABORT "${Font_Bold}${Font_Green}$Str_Interrupted_By_User${Font_Reset_Color}${Font_Reset}"; fi
	
	if [ "$MODE_DEBUG" == "true" ]; then echo "_PRINT_PACKAGE_INFO"; read pause; fi
fi
}

######### --------------------------------
######### Check and compare MD5 of archive

function _BASE_CHECK_MD5() {
	Base_Data_MD5=`md5sum "$Archive_Base_Data" | awk '{print $1}'`
	if [ "$Base_Data_MD5" != "$Archive_Base_Data_MD5" ]; then
		_CLEAR_BACKGROUND
		echo -e "\
$Base_Header
 ${Font_Bold}${Font_Cyan}$Str_CHECKMD5PRINT_Head${Font_Reset_Color}${Font_Reset}

  $Str_ATTENTION ${Font_Bold}${Font_DarkRed}$Str_BASECHECKMD5PRINT_Hash_Not_Match${Font_Reset_Color}
  ${Font_Red}$Str_BASECHECKMD5PRINT_Hash_Not_Match2${Font_Reset_Color}${Font_Reset}
  
   ${Font_Bold}$Str_BASECHECKMD5PRINT_Expected_bHash${Font_Reset} \"$Archive_Base_Data_MD5\"
   ${Font_Bold}$Str_BASECHECKMD5PRINT_Real_bHash${Font_Reset}     \"$Base_Data_MD5\""
		
		echo -e "\n  $Str_CHECKMD5PRINT_yes_To_Continue"
		read base_errors_confirm
		if [ "$base_errors_confirm" == "y" ] || [ "$base_errors_confirm" == "yes" ]; then :
		else _ABORT "${Font_Bold}${Font_Green}$Str_Interrupted_By_User${Font_Reset_Color}${Font_Reset}"; fi
	fi
	
	if [ "$MODE_DEBUG" == "true" ]; then echo "_BASE_CHECK_MD5"; read pause; fi
}


function _BASE_CREATE_TEMP() {
	if [ -e "$Base_Temp_Dir" ]; then rm -rf "$Base_Temp_Dir"; fi;
	mkdir "$Base_Temp_Dir"
	if [ $MODE_DEBUG == true ]; then echo "_BASE_CREATE_TEMP"; read pause; fi
}

function _BASE_DELETE_TEMP() {
	if [ -e "$Base_Temp_Dir" ]; then rm -rf "$Base_Temp_Dir"; fi;
}

function _BASE_PREPARE_INPUT_FILES_GREP() {
	local p_text="$1"; local p_path="$2"
	grep -rl "$p_text" "$Base_Temp_Dir" | xargs sed -i "s~$p_text~$p_path~g" &> /dev/null
}

function _BASE_PREPARE_FILES() {
	if ! [[ -x "$Tool_SevenZip_bin" ]]; then chmod +x "$Tool_SevenZip_bin"; fi
	
	if ! "$Tool_SevenZip_bin" x "$Archive_Base_Data" -o"$Base_Temp_Dir/" &> /dev/null; then
		_ABORT "$Str_PREPAREINPUTFILES_Err_Unpack (_BASE_PREPARE_FILES). $Str_PREPAREINPUTFILES_Err_Unpack2"
	fi
	
	_BASE_PREPARE_INPUT_FILES_GREP "BASE_PATH_TO_SHARE_DDIR" "$Output_Menu_DDir"
}

function _BASE_INSTALL_SYSTEM() {
	if [ ! -e "$Output_Menu_Apps" ]; then sudo mkdir -p "$Output_Menu_Apps"; fi
	if [ ! -e "$Output_Menu_DDir" ]; then sudo mkdir -p "$Output_Menu_DDir"; fi
	if [ ! -e "$Output_Menu_Files" ]; then sudo mkdir -p "$Output_Menu_Files"; fi
	
	sudo cp -rf "$Base_Temp_Dir/desktop-directories/apps/". "$Output_Menu_DDir"
	sudo cp -rf "$Base_Temp_Dir/menus/applications-merged/". "$Output_Menu_Files"
	
	if [ ! -e "$Install_Path_System" ]; then sudo mkdir -p "$Install_Path_System"; fi
	sudo cp -rf "$Base_Temp_Dir/portsoft/". "$Install_Path_System"
}

function _BASE_INSTALL_USER() {
	if [ ! -e "$Output_Menu_Apps" ]; then mkdir -p "$Output_Menu_Apps"; fi
	if [ ! -e "$Output_Menu_DDir" ]; then mkdir -p "$Output_Menu_DDir"; fi
	if [ ! -e "$Output_Menu_Files" ]; then mkdir -p "$Output_Menu_Files"; fi
	
	cp -rf "$Base_Temp_Dir/desktop-directories/apps/". "$Output_Menu_DDir"
	cp -rf "$Base_Temp_Dir/menus/applications-merged/". "$Output_Menu_Files"
	
	if [ ! -e "$Install_Path_User" ]; then mkdir -p "$Install_Path_User"; fi
	cp -rf "$Base_Temp_Dir/portsoft/". "$Install_Path_User"
}

function _BASE_INSTALL_COMPLETE() {
	if [ "$MODE_SILENT" == "false" ]; then
		echo -e " $Str_BASE_COMPLETE"
		read pause
	fi
}

_BASE_MAIN

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
