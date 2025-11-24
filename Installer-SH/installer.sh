#!/usr/bin/env bash
# LICENSE for this script is at the end of this file
# FreeSpace=$(df -m "$Out_InstallDir" | grep "/" | awk '{print $4}')\
ScriptVersion="2.6dev"; LocaleVersion="2.4" # Versions... DON'T TOUCH THIS!
Arguments=("$@"); ArgumentsString=""; for i in "${!Arguments[@]}"; do ArgumentsString="$ArgumentsString ${Arguments[$i]}"; done
HOMEDIR="$HOME"

# Main function, don't change!
function _MAIN() {
	_INIT_GLOBAL_VARIABLES; _INSTALLER_SETTINGS; _INIT_TOOLS # -= (1,2,3) =-
		_IMPORTANT_CHECK_FIRST  # -= (4) =- # First important check before UI
	_CHECK_SYSTEM; _INIT_FONTS; _SET_LOCALE # -= (5,6,7) =-
	_CHECK_SYSTEM_DE; _INIT_GLOBAL_PATHS # -= (8,9) =-
		_IMPORTANT_CHECK_LAST # -= (10) =- # Last important check before UI
	_PRINT_PACKAGE_INFO; _CHECK_MD5 # -= (11,12) =-
	_INSTALL_CONFIG_MODE; _INSTALL_CONFIG_CFG; _PRINT_INSTALL_SETTINGS # -= (13,13.1,13.2) =- # Last confirm stage
	_PREPARE_INPUT_FILES; _CHECK_OUTPUTS # -= (14,15) =-
	_INSTALL_APPLICATION; _PREPARE_UNINSTALLER; _PREPARE_LAUNCHERS # -= (16,17,17.1) =-
	_POST_INSTALL # -= (18) =-
}

######### ---- -------- ---- #########
######### ---- SETTINGS ---- #########
######### ---- -------- ---- #########

function _INSTALLER_SETTINGS() { # -= (2) =-
	# Archives MD5 Hash. Necessary for integrity checking. Generated automatically when packing archives (installer.sh -arcpack / -ap).
	Archive_MD5_Hash_ProgramFiles="f83b5a5cc1ed52370cab80aa494ebe4f"
	Archive_MD5_Hash_SystemFiles="f690c912879b507c659fa1870d4f1b7b"
	
	Tools_Architecture="x86_64"     # x86_64, x86
	Program_Architecture="script"   # x86_64, x86, script, other
	Update_Menu="true"              # Automatically updates the menu with available desktop environment features, currently xfce, kde and lxde are supported.
	
	Install_Mode="User"             # "System" / "User". In "User" mode, root rights are not required.
	Install_Configs="PortSoft"      # "SysDef" / "PortSoft". SysDef - System Default. PortSoft - A separate directory for storing configs.The package creator must add the names of the ISH launchers to the "program_files" directory for this feature to work. This functionality may be changed/improved in future versions of Installer-SH.
	Program_Launchers=(
		launcher
		launcher-second
	)
	Install_Desktop_Icons="true"    # Place icons on the desktop (only for current user).
	Install_Helpers="false"         # XFCE Only! Adds "Default Applications" associations, please prepare files in "installer-data/system_files/helpers/" before using.
	
	Debug_Test_Colors="false"       # Test colors (for debugging purposes)
	Font_Styles_RGB="false"         # Disabled for compatibility with older distributions, can be enabled manually.
	
	Unique_App_Folder_Name="installer-sh-26dev" #=> UNIQUE_APP_FOLDER_NAME
	# Unique name of the output directory.
	# WARNING! Do not use capital letters in this place!
	# WARNING! This name is also used as a template for "bin" files in the "/usr/bin" or "/home/USER/.local/bin" directory.
	# good: ex-app-16, exapp-16.
	# BAD: Ex-app-16, ExApp-16.

######### - ------------------- - #########
######### - Package Information - #########
######### - ------------------- - #########

AppVersion="2.6 dev" # Application version

Info_Name="Installer-SH"
Info_Version="v$AppVersion"
Info_Release_Date="2025-xx-xx"
Info_Category="Other"
Info_Platform="Linux - Chimbalix 24, Debian 7-12, Fedora 20-42." # You need to specify the compatibility of the program, not the installation package.
Info_Installed_Size="~1 MiB"
Info_Licensing="Freeware - Open Source (MIT)
   Other Licensing Examples:
    Freeware - Proprietary (EULA, Please read \"EULA-example.txt\")
    Trialware - 30 days free, Proprietary (Other License Name)"
Info_Maintainer="Chimbal" # Package creator
Info_Developer="Chimbal"  # Software developer
Info_URL="https://github.com/Shedou/Chimbalix-Software-Catalog"

# Use this description if there is no suitable localization file.
# WARNING! The maximum number of characters available for description is 100x11, it is not recommended to exceed this limit.
Info_Description_Default="\
  1) This universal installer (short description):
     - Suitable for installation on stand-alone PCs without Internet access.
     - Stores installation files in a 7-zip archive (good compression and fast unpacking).
  2) Check the current \"installer.sh\" file to configure the installation package."

 ### ------------------------ ###
 ### Basic Menu File Settings ###
 ### ------------------------ ###
 # Please manually prepare the menu files in the "installer-data/system_files/" directory before packaging the application.
 # Use the variable names given in the comments to simplify the preparation of menu files.
Menu_Directory_Name="$Info_Name v$AppVersion"                   #=> MENU_DIRECTORY_NAME
Menu_Directory_Icon="/icons/icon.png"                           #=> MENU_DIRECTORY_ICON

Program_Name_In_Menu="$Info_Name $AppVersion"                   #=> PROGRAM_NAME_IN_MENU
Program_Install_Mode="$Install_Mode"                            #=> PROGRAM_INSTALL_MODE

Program_Uninstaller_File="ish-software-uninstaller.sh"                 #=> PROGRAM_UNINSTALLER_FILE
Program_Uninstaller_Icon="/icons/ish-software-uninstaller-icon.png"    #=> PROGRAM_UNINSTALLER_ICON

 # Additional menu categories that will include the main application shortcuts.
Additional_Categories="chi-other;Utility;Education;"            #=> ADDITIONAL_CATEGORIES
 # -=== Chimbalix 24.4+ main categories:
 # Check the "Menu-Categories.ods" table for more information
 # (file will be removed when using the -clean / -cn option).



 ### ---------------------------------------------------------- ###
 ### Archive packaging parameters (installer.sh -arcpack / -ap) ###
 ### ---------------------------------------------------------- ###
 # Larger size - better compression and more RAM required for unpacking. (256 dictionary requires 256+ MB of RAM for unpacking)
 # For applications 150-200 MiB in size, use a dictionary size of 32 - 128, it is not recommended to use a dictionary size greater than 256.
Dictionary_Size_Program_Files="64"
Dictionary_Size_System_Files="8"
 
 ### Archive format. Use 7-Zip for better compression. Tar.xz - for compatibility with very old Linux (Debian <7)
 # "Tar" is not recommended for normal use
Archive_Format="SZip" # "SZip" / "Tar"

 # Application installation directory. Don't touch it if you don't know why you need it!
 # If used incorrectly, it may lead to bad consequences!
# DO NOT TOUCH THIS WITHOUT A SERIOUS REASON!
Install_Path_User="$HOMEDIR/portsoft"
Install_Path_User_Full="$Install_Path_User/$Program_Architecture/$Unique_App_Folder_Name"
# DO NOT TOUCH THIS WITHOUT A SERIOUS REASON!
Install_Path_System="/portsoft"
Install_Path_System_Full="$Install_Path_System/$Program_Architecture/$Unique_App_Folder_Name"
# DO NOT TOUCH THIS WITHOUT A SERIOUS REASON!
Install_Path_Bin_User="$HOMEDIR/.local/bin" # "$HOMEDIR/.local/bin" works starting from Chimbalix 24.4
Install_Path_Bin_System="/usr/bin"

if [ "$Archive_Format" == "Tar" ]; then
	Archive_Program_Files="$Path_Installer_Data/program_files.tar.xz"
	Archive_System_Files="$Path_Installer_Data/system_files.tar.xz"
else
	Archive_Program_Files="$Path_Installer_Data/program_files.7z"
	Archive_System_Files="$Path_Installer_Data/system_files.7z"
fi
}

######### -- ------------ -- #########
######### -- ------------ -- #########
######### -- ------------ -- #########
######### -- ------------ -- #########
######### -- END SETTINGS -- #########
######### -- ------------ -- #########
######### -- ------------ -- #########
######### -- ------------ -- #########
######### -- ------------ -- #########


######### ------------------------- #########
######### Post Install (LAST STAGE) #########

function _POST_INSTALL() { # -= (18) =-
	if [ "$MODE_NOUPDATE_MENU" == "false" ] && [ "$Update_Menu" == "true" ]; then _UPDATE_MENU; fi
	
	# Exit
	if [ "$MODE_SILENT" == "false" ]; then _ABORT "${Font_Bold}${Font_Green}$Str_Complete_Install${Font_Reset_Color}${Font_Reset}"; fi
	
	if [ "$MODE_DEBUG" == "true" ]; then echo "_POST_INSTALL"; read -r pause; fi
}

function _POST_INSTALL_UPDATE_MENU_LXDE() { if type "lxpanelctl" &> /dev/null; then lxpanelctl restart &> /dev/null; fi; }
function _POST_INSTALL_UPDATE_MENU_XFCE() { if type "xfce4-panel" &> /dev/null; then xfce4-panel -r &> /dev/null; fi; }
function _POST_INSTALL_UPDATE_MENU_KDE() {
	if type "kbuildsycoca7" &> /dev/null; then kbuildsycoca7 &> /dev/null
	elif type "kbuildsycoca6" &> /dev/null; then kbuildsycoca6 &> /dev/null
	elif type "kbuildsycoca5" &> /dev/null; then kbuildsycoca5 &> /dev/null
	elif type "kbuildsycoca4" &> /dev/null; then kbuildsycoca4 &> /dev/null
	fi
}

function _UPDATE_MENU() {
	if [ "$Current_DE" == "LXDE" ];    then _POST_INSTALL_UPDATE_MENU_LXDE; fi
	if [ "$Current_DE" == "XFCE" ];    then _POST_INSTALL_UPDATE_MENU_XFCE; fi
	if [ "$Current_DE" == "KDE" ];     then _POST_INSTALL_UPDATE_MENU_KDE; fi
}

######### ----------------------------- #########
######### ----------------------------- #########
######### ----------------------------- #########
######### ----------------------------- #########
######### BEFORE FIRST DEPENDENCY CHECK #########

function _HELP() { # Здесь НЕЛЬЗЯ использовать локализацию т.к. функция "_SET_LOCALE" ещё не заружена!
	echo -e "(-h) (-help) (--help)\n Installer-SH launch parameters: $ArgumentsString
-updatebase -ub - Update base menu files and PortSoft (ISH version $ScriptVersion).
-update     -up - Program update mode, warnings about overwriting existing files
                   will not be displayed!
-silent     -st - Requires confirmation only in case of errors and conflicts.
-cfgportsoft -cps - Store program settings in a dedicated directory.
-cfgsysdef   -csd - Do not override the program settings storage directory.
-modeuser    -mur - Install software only for the current user.
-modesystem  -msm - Install for all system users (root rights required).
-noupdmenu  -nm - Disables automatic menu update after installation.
                   Recommended for use when batch installing
                   multiple applications in \"-silent\" mode.
-forcemenu  -fm - Only refresh menu. Recommended to use after installing
                   many applications in \"-silent\" mode.
                   Works if the working environment is supported.
-arcpack    -ap - Pack \"program_files\" and \"system_files\" into archives.
-clean      -cn - Delete unnecessary files in the package directory.
                   Please make sure that the package is built and ready for use,
                   this cannot be undone!
-tarpack    -tp - Pack the current installation package into a tar archive.
-debug      -dg - Debug mode, for development purposes only."
	exit;
}

function _CHECK_ARGS() {
	if [[ "$ArgumentsString" =~ "-help" ]] || [[ "$ArgumentsString" =~ "-h" ]] || [[ "$ArgumentsString" =~ "--help" ]]; then _HELP; fi
	if [[ "$ArgumentsString" =~ "-forcemenu" ]] || [[ "$ArgumentsString" =~ "-fm" ]];  then _CHECK_SYSTEM_DE; _UPDATE_MENU; exit; fi
	if [[ "$ArgumentsString" =~ "-noupdmenu" ]] || [[ "$ArgumentsString" =~ "-nm" ]];  then MODE_NOUPDATE_MENU="true"; fi
	if [[ "$ArgumentsString" =~ "-debug" ]] || [[ "$ArgumentsString" =~ "-dg" ]];      then MODE_DEBUG="true"; fi
	if [[ "$ArgumentsString" =~ "-silent" ]] || [[ "$ArgumentsString" =~ "-st" ]];     then MODE_SILENT="true"; fi
	if [[ "$ArgumentsString" =~ "-arcpack" ]] || [[ "$ArgumentsString" =~ "-ap" ]];    then MODE_ARCPACK="true"; fi
	if [[ "$ArgumentsString" =~ "-clean" ]] || [[ "$ArgumentsString" =~ "-cn" ]];      then MODE_CLEAN="true"; fi
	if [[ "$ArgumentsString" =~ "-tarpack" ]] || [[ "$ArgumentsString" =~ "-tp" ]];    then MODE_TARPACK="true"; fi
	if [[ "$ArgumentsString" =~ "-updatebase" ]] || [[ "$ArgumentsString" =~ "-ub" ]]; then MODE_UPDATEBASE="true"; fi
	if [[ "$ArgumentsString" =~ "-update" ]] || [[ "$ArgumentsString" =~ "-up" ]];     then MODE_UPDATE="true"; fi
	if [[ "$ArgumentsString" =~ "-cfgportsoft" ]] || [[ "$ArgumentsString" =~ "-cps" ]]; then CFG_PORTSOFT="true"; fi
	if [[ "$ArgumentsString" =~ "-cfgsysdef" ]] || [[ "$ArgumentsString" =~ "-csd" ]];   then CFG_SYSDEF="true"; fi
	if [[ "$ArgumentsString" =~ "-modeuser" ]] || [[ "$ArgumentsString" =~ "-mur" ]];    then MODE_USER="true"; fi
	if [[ "$ArgumentsString" =~ "-modesystem" ]] || [[ "$ArgumentsString" =~ "-msm" ]];  then MODE_SYSTEM="true"; fi
}

function _INIT_GLOBAL_VARIABLES() { # -= (1) =- # Здесь НЕЛЬЗЯ использовать локализацию т.к. функция "_SET_LOCALE" ещё не заружена!
	
	### --------------------------- ###
	### Do not edit variables here! ###
	### --------------------------- ###
	
	Font_Bold=""; Font_Dim=""; Font_Reset=""; Font_Reset_Color=''; Font_Reset_BG=''
	Font_Black=''; Font_Black_BG=''; Font_DarkGray=''; Font_DarkGray_BG=''; Font_Gray=''; Font_Gray_BG=''; Font_White=''; Font_White_BG=''
	Font_DarkRed=''; Font_DarkRed_BG=''; Font_DarkGreen=''; Font_DarkGreen_BG=''; Font_DarkYellow=''; Font_DarkYellow_BG=''; Font_DarkBlue=''; Font_DarkBlue_BG=''
	Font_DarkMagenta=''; Font_DarkMagenta_BG=''; Font_DarkCyan=''; Font_DarkCyan_BG=''
	Font_Red=''; Font_Red_BG=''; Font_Green=''; Font_Green_BG=''; Font_Yellow=''; Font_Yellow_BG=''; Font_Blue=''; Font_Blue_BG=''
	Font_Magenta=''; Font_Magenta_BG=''; Font_Cyan=''; Font_Cyan_BG=''
	
	Locale_Use_Default="true" # don't change!
	Locale_Display="Default"
	Info_Description="TO BE REPLACED BY LOCALE IF PRESENT, DONT CHANGE THIS"
	Current_Architecture="Unknown"
	# Header Text (unformated)
	Header="-=: Installer-SH v$ScriptVersion - Lang: NOT INITIALIZED :=-"
	
	User_Desktop_Dir="$HOMEDIR/Desktop"
	if [ -e "$HOMEDIR/.config/user-dirs.dirs" ]; then
		source "$HOMEDIR/.config/user-dirs.dirs"; User_Desktop_Dir="$XDG_DESKTOP_DIR"; fi
	
	MODE_DEBUG="false"
	MODE_NOUPDATE_MENU="false"
	MODE_SILENT="false"
	MODE_CLEAN="false"
	MODE_TARPACK="false"
	MODE_ARCPACK="false"
	MODE_UPDATEBASE="false"
	MODE_UPDATE="false"
	CFG_PORTSOFT="false"
	CFG_SYSDEF="false"
	MODE_USER="false"
	MODE_SYSTEM="false"
	
	Script_Name="$(basename "$0")"
	Path_To_Script="$( dirname "$(readlink -f "$0")")"
	Path_Installer_Data="$Path_To_Script/installer-data"
	
	List_Errors=""    # _ERROR "Title" "Message."
	List_Warnings=""  # _WARNING "Title" "Message."
	
	Current_DE="UnknownDE"
	                                # os-release (main)    example (Chimbalix 24.5+)  lsb-release
	Current_OS_Name_Full="Unknown"  # PRETTY_NAME         "Chimbalix 24.5 Alphachi"   DISTRIB_DESCRIPTION
	Current_OS_Name="Unknown"       # NAME                "Chimbalix"                 DISTRIB_ID
	Current_OS_Name_ID="Unknown"    # ID                  "chimbalix"                 DISTRIB_ID
	Current_OS_Version="Unknown"    # VERSION_ID          "24.5"                      DISTRIB_RELEASE
	Current_OS_Codename="Unknown"   # VERSION_CODENAME    "alphachi"                  DISTRIB_CODENAME
	
	_CHECK_ARGS
}

# _INSTALLER_SETTINGS

function _INIT_TOOLS() { # -= (3) =-
	Tool_Tar="tar" # Альтернативный архиватор
	Tool_SevenZip_bin="$Path_Installer_Data/tools/7zip/7zzs"
	if [ "$Tools_Architecture" == "x86" ]; then Tool_SevenZip_bin="$Path_Installer_Data/tools/7zip/7zzs-x86"; fi
}


function _PACK_ARCHIVES() { # Здесь НЕЛЬЗЯ использовать локализацию т.к. функция "_SET_LOCALE" ещё не заружена!
	Program_Files="$Path_Installer_Data/program_files"
	System_Files="$Path_Installer_Data/system_files"
	
	function _pack_archive() {
		Name_File="$1"
		DSize="$2"
		Name_File_Target="$(basename "$3")"
		Name_File_Target_full="$3"
		
		if [ "$Archive_Format" == "SZip" ]; then
			if [ -e "$Name_File" ]; then
				if [ -e "$Name_File_Target" ]; then mv -T "$Name_File_Target" "$Name_File-old""_$RANDOM"".7z"; fi
				echo -e "\n"
				cd "$Path_Installer_Data" || exit
				"$Tool_SevenZip_bin" a -snl -mx9 -m0=LZMA2:d"$DSize"m -ms=1g -mqs=on -mmt=3 "$Name_File_Target" "$Name_File/."
			fi
		fi
		
		if [ "$Archive_Format" == "Tar" ]; then
			if [ -e "$Name_File" ]; then
				if [ -e "$Name_File_Target" ]; then mv -T "$Name_File_Target" "$Name_File-old""_$RANDOM"".tar.xz"; fi
				cd "$Name_File" || exit
				tar -cf ../"$Name_File_Target" -I "xz -9 --lzma2=dict=$DSize"M -- * && echo -e "\nOK" || echo -e "\n BAD, Try with simple tar command..."; tar -cJf ../"$Name_File_Target" -- *
			fi
		fi
		
		PackArcMD5=$(md5sum "$Name_File_Target_full" | awk '{print $1}')
		if [ "$Name_File" == "$Program_Files" ]; then
			sed -i "0,/Archive_MD5_Hash_ProgramFiles=.*/ s/Archive_MD5_Hash_ProgramFiles=.*/Archive_MD5_Hash_ProgramFiles=\"$PackArcMD5\"/" "$Path_To_Script/$Script_Name"
		elif [ "$Name_File" == "$System_Files" ]; then
			sed -i "0,/Archive_MD5_Hash_SystemFiles=.*/ s/Archive_MD5_Hash_SystemFiles=.*/Archive_MD5_Hash_SystemFiles=\"$PackArcMD5\"/" "$Path_To_Script/$Script_Name"
		fi
	}
	
	_pack_archive "$Program_Files" "$Dictionary_Size_Program_Files" "$Archive_Program_Files"
	_pack_archive "$System_Files" "$Dictionary_Size_System_Files" "$Archive_System_Files"
	
	echo -e "\n\n Pause..."
	read -r pause; exit
}

function _TAR_PACK() { # Здесь НЕЛЬЗЯ использовать локализацию т.к. функция "_SET_LOCALE" ещё не заружена!
	TP_OutputFile="$Path_To_Script.tar"
	TP_InputDirName="$(basename "$Path_To_Script")"
	
	cd ..
	
	if [ ! -e "$TP_OutputFile" ]; then 
		tar --owner=ish --group=ish -cf "$TP_OutputFile" "$TP_InputDirName"
		echo -e "Distributable archive created:\n\n $Path_To_Script.tar\n\n COMPLETED"
		read -r pause; exit
	else
		echo -e "File already exists!\n\n $TP_OutputFile\n\n !!! WARNING !!!"
		read -r pause; exit
	fi
}

function _CLEAN() { # Здесь НЕЛЬЗЯ использовать локализацию т.к. функция "_SET_LOCALE" ещё не заружена!
	
	function _CLEAN_FILE() {
		CleanFileName="$1"
		echo "Removing: $CleanFileName"
		if [ -e "$CleanFileName" ]; then rm -rf "$CleanFileName"
		else echo " Skip (not found): $CleanFileName"; fi
	}
	
	echo -e " Removes unnecessary files and directories.\n USE ONLY AFTER COMPLETING AND TESTING THE PACKAGE.\n \"y\" to delete..."
	read -r cleaning_confirmation
	if [ "$cleaning_confirmation" == "y" ] || [ "$cleaning_confirmation" == "yes" ]; then
		_CLEAN_FILE "$Path_To_Script/EULA-example.txt"
		_CLEAN_FILE "$Path_To_Script/Menu-Categories.ods"
		_CLEAN_FILE "$Path_To_Script/for-tests-in-VM-batch-install.sh"
		_CLEAN_FILE "$Path_To_Script/for-tests-in-VM-create-PortSoft-in-RAM.sh"
		_CLEAN_FILE "$Path_Installer_Data/program_files"
		_CLEAN_FILE "$Path_Installer_Data/system_files"
		_CLEAN_FILE "$Path_Installer_Data/tools/MD5-Hash.txt"
		_CLEAN_FILE "$Path_Installer_Data/tools/pack_archive.sh"
		_CLEAN_FILE "$Path_Installer_Data/tools/base_data"
		
		if [ "$Tools_Architecture" == "x86_64" ]; then
			_CLEAN_FILE "$Path_Installer_Data/tools/7zip/7zzs-x86"
		elif [ "$Tools_Architecture" == "x86" ]; then
			_CLEAN_FILE "$Path_Installer_Data/tools/7zip/7zzs"
		fi
		
		echo -e "\n Complete..."
		read -r pause
		if [ "$MODE_TARPACK" == "true" ]; then _TAR_PACK
		else exit; fi
	else
		echo "Abort"
		echo -e "\n Pause..."
		read -r pause
		exit
	fi
}

function _IMPORTANT_CHECK_FIRST() {  # -= (4) =- # Здесь НЕЛЬЗЯ использовать локализацию т.к. функция "_SET_LOCALE" ещё не заружена!
	
	if [ "$MODE_ARCPACK" == "true" ]; then _PACK_ARCHIVES; fi
	if [ "$MODE_CLEAN" == "true" ];   then _CLEAN; fi
	if [ "$MODE_TARPACK" == "true" ]; then _TAR_PACK; fi
	
	if [ "$CFG_SYSDEF" == "true" ];   then Install_Configs="SysDef"; fi
	if [ "$CFG_PORTSOFT" == "true" ]; then Install_Configs="PortSoft"; fi
	if [ "$MODE_SYSTEM" == "true" ];  then Install_Mode="System"; fi
	if [ "$MODE_USER" == "true" ];    then Install_Mode="User"; fi
	
	String_CMD_N_F="Command not found, unable to continue:"
	if ! type "uname" &> /dev/null;     then _ABORT "$String_CMD_N_F 'uname'"; fi
	if ! type "dirname" &> /dev/null;   then _ABORT "$String_CMD_N_F 'dirname'"; fi
	if ! type "clear" &> /dev/null;     then _ABORT "$String_CMD_N_F 'clear'"; fi
	if ! type "readlink" &> /dev/null;  then _ABORT "$String_CMD_N_F 'readlink'"; fi
	if ! type "cut" &> /dev/null;       then _ABORT "$String_CMD_N_F 'cut'"; fi
	if ! type "rm" &> /dev/null;        then _ABORT "$String_CMD_N_F 'rm'"; fi
	if ! type "cp" &> /dev/null;        then _ABORT "$String_CMD_N_F 'cp'"; fi
	if ! type "mkdir" &> /dev/null;     then _ABORT "$String_CMD_N_F 'mkdir'"; fi
	if ! type "touch" &> /dev/null;     then _ABORT "$String_CMD_N_F 'touch'"; fi
	if ! type "awk" &> /dev/null;       then _ABORT "$String_CMD_N_F 'awk'"; fi
	if ! type "find" &> /dev/null;      then _ABORT "$String_CMD_N_F 'find'"; fi
	if ! type "grep" &> /dev/null;      then _ABORT "$String_CMD_N_F 'grep'"; fi
	if ! type "sed" &> /dev/null;       then _ABORT "$String_CMD_N_F 'sed'"; fi
	if ! type "xargs" &> /dev/null;     then _ABORT "$String_CMD_N_F 'xargs'"; fi
	if ! type "chown" &> /dev/null;     then _ABORT "$String_CMD_N_F 'chown'"; fi
	if ! type "chmod" &> /dev/null;     then _ABORT "$String_CMD_N_F 'chmod'"; fi
	if ! type "stat" &> /dev/null;      then _ABORT "$String_CMD_N_F 'stat'"; fi
	if [ "$Install_Mode" == "System" ]; then
		if ! type "sudo" &> /dev/null; then _ABORT "$String_CMD_N_F 'sudo'\n Do not use 'System' installation mode without 'sudo'..."; fi
	fi
	if ! type "tar" &> /dev/null; then      _ABORT "$String_CMD_N_F 'tar'"; fi
	
	if [ -z "$HOMEDIR" ]; then _ABORT "Variable HOME not found"; fi
}

######### ---------------------------- #########
######### ---------------------------- #########
######### ---------------------------- #########
######### ---------------------------- #########
######### BEFORE LAST DEPENDENCY CHECK #########

function _CHECK_SYSTEM_VERSION() { # Здесь НЕЛЬЗЯ использовать локализацию т.к. функция "_SET_LOCALE" ещё не заружена!
	
	if [ -f "/etc/os-release" ]; then source "/etc/os-release"
		Current_OS_Name_Full="$PRETTY_NAME"
		Current_OS_Name="$NAME"
		Current_OS_Name_ID="$ID"
		Current_OS_Version="$VERSION_ID"
		Current_OS_Codename="$VERSION_CODENAME"
	elif [ -f "/etc/lsb-release" ]; then source "/etc/lsb-release"
		Current_OS_Name_Full="$DISTRIB_DESCRIPTION"
		Current_OS_Name="$DISTRIB_ID"
		Current_OS_Name_ID="$DISTRIB_ID"
		Current_OS_Version="$DISTRIB_RELEASE"
		Current_OS_Codename="$DISTRIB_CODENAME"
	else
		if type uname &>/dev/null; then Current_OS_Name_Full="$(uname -sr)"
		else _ABORT "The name of the operating system / kernel is not defined!"; fi
	fi
}

function _CHECK_SYSTEM() { # -= (5) =- # Здесь НЕЛЬЗЯ использовать локализацию т.к. функция "_SET_LOCALE" ещё не заружена!
	
	_CHECK_SYSTEM_VERSION
	Current_Architecture="$(uname -m)"
	if [ "$Current_Architecture" == "i686" ]; then Current_Architecture="x86"; fi
	if [ "$Tools_Architecture" != "$Current_Architecture" ]; then
		if [ "$Current_OS_Name" == "Chimbalix" ]; then : # Chimbalix has 32-bit libraries, so it is possible to work within this distribution.
		else _ABORT "The system architecture ($Current_Architecture) does not match the selected tools architecture ($Tools_Architecture)!"; fi
	fi
}

function _INIT_FONTS() { # -= (6) =- # Здесь НЕЛЬЗЯ использовать локализацию т.к. функция "_SET_LOCALE" ещё не заружена!
	
	### Font styles: "${Font_Bold} BLACK TEXT ${Font_Reset} normal text."
	# '\e[38;2;128;128;255m'
	#     fg m  R   G   B
	# \e - escape code, [38 - foreground, [48 - background
	#
	### Old distributions do not support the RGB method, you need to make crutches...
	# '\033[38;5;165m'
	# 165m - 8 bit color number
	
	Font_Bold="\e[1m"
	Font_Dim="\e[2m"
	Font_Reset="\e[22m"
	Font_Reset_Color='\e[38;5;255m'
	Font_Reset_BG='\e[48;5;16m'
	
	Font_Black='\e[38;5;233m'; Font_Black_BG='\e[48;5;233m'
	Font_DarkGray='\e[38;5;240m'; Font_DarkGray_BG='\e[48;5;240m'
	Font_Gray='\e[38;5;248m'; Font_Gray_BG='\e[48;5;248m'
	Font_White='\e[38;5;255m'; Font_White_BG='\e[48;5;255m'
	
	if [ "$Font_Styles_RGB" == "true" ]; then
		Font_DarkRed='\e[38;2;200;0;0m'; Font_DarkRed_BG='\e[48;2;200;0;0m'
		Font_DarkGreen='\e[38;2;0;180;0m'; Font_DarkGreen_BG='\e[48;2;0;180;0m'
		Font_DarkYellow='\e[38;2;180;146;0m'; Font_DarkYellow_BG='\e[48;2;180;146;0m'
		Font_DarkBlue='\e[38;2;72;72;230m'; Font_DarkBlue_BG='\e[48;2;72;72;230m'
		Font_DarkMagenta='\e[38;2;200;0;200m'; Font_DarkMagenta_BG='\e[48;2;200;0;200m'
		Font_DarkCyan='\e[38;2;40;180;160m'; Font_DarkCyan_BG='\e[48;2;40;180;160m'
		
		Font_Red='\e[38;2;255;96;96m'; Font_Red_BG='\e[48;2;255;96;96m'
		Font_Green='\e[38;2;128;255;128m'; Font_Green_BG='\e[48;2;128;255;128m'
		Font_Yellow='\e[38;2;245;245;64m'; Font_Yellow_BG='\e[48;2;245;245;64m'
		Font_Blue='\e[38;2;160;160;255m'; Font_Blue_BG='\e[48;2;160;160;255m'
		Font_Magenta='\e[38;2;255;96;255m'; Font_Magenta_BG='\e[48;2;255;96;255m'
		Font_Cyan='\e[38;2;90;255;240m'; Font_Cyan_BG='\e[48;2;90;255;240m'
	else # For compatibility with older distributions...
		Font_DarkRed='\e[38;5;160m'; Font_DarkRed_BG='\e[48;5;160m'
		Font_DarkGreen='\e[38;5;34m'; Font_DarkGreen_BG='\e[48;5;34m'
		Font_DarkYellow='\e[38;5;178m'; Font_DarkYellow_BG='\e[48;5;178m'
		Font_DarkBlue='\e[38;5;63m'; Font_DarkBlue_BG='\e[48;5;63m'
		Font_DarkMagenta='\e[38;5;164m'; Font_DarkMagenta_BG='\e[48;5;164m'
		Font_DarkCyan='\e[38;5;37m'; Font_DarkCyan_BG='\e[48;5;37m'
		
		Font_Red='\e[38;5;210m'; Font_Red_BG='\e[48;5;210m'
		Font_Green='\e[38;5;82m'; Font_Green_BG='\e[48;5;82m'
		Font_Yellow='\e[38;5;226m'; Font_Yellow_BG='\e[48;5;226m'
		Font_Blue='\e[38;5;111m'; Font_Blue_BG='\e[48;5;111m'
		Font_Magenta='\e[38;5;213m'; Font_Magenta_BG='\e[48;5;213m'
		Font_Cyan='\e[38;5;51m'; Font_Cyan_BG='\e[48;5;51m'
	fi
}

#_SET_LOCALE

function _CHECK_SYSTEM_DE() { # -= (8) =- # Здесь можно использовать локализацию
	
	local check_de_raw=""
	local check_de_err="0"
	
	if   [ "$XDG_CURRENT_DESKTOP" ]; then check_de_raw="$(echo "$XDG_CURRENT_DESKTOP" | cut -d: -f 1)"
	elif [ "$XDG_SESSION_DESKTOP" ]; then _WARNING "XDG_CURRENT_DESKTOP" "$Str_CHECKSYSDE_NotFound"; check_de_raw="$XDG_SESSION_DESKTOP"
	elif [ "$DESKTOP_SESSION" ];     then _WARNING "XDG_SESSION_DESKTOP" "$Str_CHECKSYSDE_NotFound"; check_de_raw="$DESKTOP_SESSION"
	else _WARNING "DESKTOP_SESSION" "$Str_CHECKSYSDE_NotFound"; fi
	
	# Normalize
	### COSMIC - GNOME - KDE - LXDE - LXQT - MATE - RAZOR - ROX - TDE - UNITY - XFCE - EDE - CINNAMON - PANTHEON - DDE - ENDLESS - LEGACY - BUDGIE - OPENBOX - SWAY
	if [ "$check_de_raw" == "COSMIC" ];            then local check_de_raw="COSMIC"   # COSMIC Desktop
	elif [ "$check_de_raw" == "GNOME" ];           then local check_de_raw="GNOME"    # GNOME Desktop
	elif [ "$check_de_raw" == "GNOME-Classic" ];   then local check_de_raw="GNOME"    # GNOME Classic Desktop
	elif [ "$check_de_raw" == "GNOME-Flashback" ]; then local check_de_raw="GNOME"    # GNOME Flashback Desktop
	elif [ "$check_de_raw" == "KDE" ];             then local check_de_raw="KDE"      # KDE Desktop
	elif [ "$check_de_raw" == "LXDE" ];            then local check_de_raw="LXDE"     # LXDE Desktop
	elif [ "$check_de_raw" == "LXQt" ];            then local check_de_raw="LXQT"     # LXQt Desktop
	elif [ "$check_de_raw" == "MATE" ];            then local check_de_raw="MATE"     # MATE Desktop
	elif [ "$check_de_raw" == "Razor" ];           then local check_de_raw="RAZOR"    # Razor-qt Desktop
	elif [ "$check_de_raw" == "ROX" ];             then local check_de_raw="ROX"      # ROX Desktop
	elif [ "$check_de_raw" == "TDE" ];             then local check_de_raw="TDE"      # Trinity Desktop
	elif [ "$check_de_raw" == "Unity" ];           then local check_de_raw="UNITY"    # Unity Shell
	elif [ "$check_de_raw" == "XFCE" ];            then local check_de_raw="XFCE"     # XFCE Desktop
	elif [ "$check_de_raw" == "EDE" ];             then local check_de_raw="EDE"      # EDE Desktop
	elif [ "$check_de_raw" == "Cinnamon" ];        then local check_de_raw="CINNAMON" # Cinnamon Desktop
	elif [ "$check_de_raw" == "Pantheon" ];        then local check_de_raw="PANTHEON" # Pantheon Desktop
	elif [ "$check_de_raw" == "DDE" ];             then local check_de_raw="DDE"      # Deepin Desktop
	elif [ "$check_de_raw" == "Endless" ];         then local check_de_raw="ENDLESS"  # Endless OS desktop
	elif [ "$check_de_raw" == "Old" ];             then local check_de_raw="LEGACY"   # Legacy menu systems
	elif [ "$check_de_raw" == "plasma" ];          then local check_de_raw="KDE" ### Extra names
	elif [ "$check_de_raw" == "xfce" ];            then local check_de_raw="XFCE"
	elif [ "$check_de_raw" == "xubuntu" ];         then local check_de_raw="XFCE"
	elif [ "$check_de_raw" == "lxde" ];            then local check_de_raw="LXDE"
	elif [ "$check_de_raw" == "mate" ];            then local check_de_raw="MATE"
	elif [ "$check_de_raw" == "ubuntu" ];          then local check_de_raw="GNOME"
	elif [ "$check_de_raw" == "lxqt" ];            then local check_de_raw="LXQT"
	elif [ "$check_de_raw" == "Lubuntu" ];         then local check_de_raw="LXQT"
	elif [ "$check_de_raw" == "cinnamon" ];        then local check_de_raw="CINNAMON"
	elif [ "$check_de_raw" == "X-Cinnamon" ];      then local check_de_raw="CINNAMON"
	elif [ "$check_de_raw" == "budgie-desktop" ];  then local check_de_raw="BUDGIE"
	elif [ "$check_de_raw" == "Budgie" ];          then local check_de_raw="BUDGIE"
	elif [ "$check_de_raw" == "openbox" ];         then local check_de_raw="OPENBOX"
	elif [ "$check_de_raw" == "sway" ];            then local check_de_raw="SWAY"
	else local check_de_err="1"; fi
	
	if [ "$check_de_err" == "1" ]; then
		_WARNING "$Str_CHECKSYSDE_DE_CHECK" "$Str_CHECKSYSDE_XDG_INFO_INCORRECT"
		
		if xfce4-session --version &>/dev/null;    then local check_de_raw="XFCE"
		elif plasmashell --version &>/dev/null;    then local check_de_raw="KDE"
		elif plasma-desktop --version &>/dev/null; then local check_de_raw="KDE"
		elif gnome-shell --version &>/dev/null;    then local check_de_raw="GNOME"
		fi
	fi
	
	# Extra checks
	if [ "$check_de_raw" == "OPENBOX" ]; then _WARNING "$Str_CHECKSYSDE_DE_WEIRD (Openbox)" "$Str_CHECKSYSDE_DE_WEIRD_OPENBOX"; fi
	if [ "$check_de_raw" == "SWAY" ];    then _WARNING "$Str_CHECKSYSDE_DE_WEIRD (Sway)" "$Str_CHECKSYSDE_DE_WEIRD_SWAY"; fi
	if [ "$check_de_raw" == "LXQT" ];    then _WARNING "$Str_CHECKSYSDE_DE_WEIRD (LXQt)" "$Str_CHECKSYSDE_DE_WEIRD_LXQT"; fi
	if [ "$check_de_raw" == "BUDGIE" ];  then _WARNING "$Str_CHECKSYSDE_DE_WEIRD (Budgie)" "$Str_CHECKSYSDE_DE_WEIRD_BUDGIE"; fi
	if [ "$check_de_raw" == "GNOME" ];   then _WARNING "$Str_CHECKSYSDE_DE_WEIRD (GNOME)" "$Str_CHECKSYSDE_DE_WEIRD_GNOME"; fi
	
	Current_DE="$check_de_raw"
}

function _INIT_OUTPUTS() {
	if [ "$Install_Mode" == "System" ]; then
		Output_Install_Dir="$Install_Path_System_Full"; Output_Bin_Dir="$Install_Path_Bin_System"; Output_Helpers_Dir="$Out_System_Helpers_Dir"
		Output_Menu_Files="$Out_System_Menu_Files"; Output_Menu_DDir="$Out_System_Menu_DDir"; Output_Menu_Apps="$Out_System_Menu_Apps"
		Output_PortSoft="$Install_Path_System"
	else
		Output_Install_Dir="$Install_Path_User_Full"; Output_Bin_Dir="$Install_Path_Bin_User"; Output_Helpers_Dir="$Out_User_Helpers_Dir"
		Output_Menu_Files="$Out_User_Menu_Files"; Output_Menu_DDir="$Out_User_Menu_DDir"; Output_Menu_Apps="$Out_User_Menu_Apps"
		Output_PortSoft="$Install_Path_User"
	fi
	Output_Uninstaller="$Output_Install_Dir/$Program_Uninstaller_File" # Uninstaller template file.
}

function _INIT_GLOBAL_PATHS() { # -= (9) =-
	### --------------------------- ###
	### Do not edit variables here! ###
	### --------------------------- ###
	
	Temp_DirISH="/tmp/installer-sh"
	Temp_Dir="$Temp_DirISH/$Unique_App_Folder_Name""_$RANDOM""_$RANDOM" # TEMP Directory
	Temp_Test="/tmp/installer-sh"
	
	Input_Bin_Dir="$Temp_Dir/bin"
	Input_Helpers_Dir="$Temp_Dir/xfce4/helpers"
	Input_Desktop_Dir="$Temp_Dir/desktop"
	Input_Menu_Files_Dir="$Temp_Dir/menu/applications-merged"
	Input_Menu_Desktop_Dir="$Temp_Dir/menu/desktop-directories/apps"
	Input_Menu_Apps_Dir="$Temp_Dir/menu/apps"
	
	Out_User_Helpers_Dir="$HOMEDIR/.local/share/xfce4/helpers"
	Out_User_Desktop_Dir="$User_Desktop_Dir"
	Out_User_Menu_Files="$HOMEDIR/.config/menus/applications-merged"
	Out_User_Menu_DDir="$HOMEDIR/.local/share/desktop-directories/apps"
	Out_User_Menu_Apps="$HOMEDIR/.local/share/applications/apps"

	Out_System_Helpers_Dir="/usr/share/xfce4/helpers"
	Out_System_Menu_Files="/etc/xdg/menus/applications-merged"
	Out_System_Menu_DDir="/usr/share/desktop-directories/apps"
	Out_System_Menu_Apps="/usr/share/applications/apps"
	
	Out_App_Folder_Owner=root:root  # Only for "System" mode, username:group
	Out_App_Folder_Permissions=755  # Only for "System" mode.
	
	Output_Files_All=("/tmp/ish") # Files list for Uninstaller
	
	# The "PATH_TO_FOLDER" variable points to the application installation directory without the trailing slash (Output_Install_Dir), for example "/portsoft/x86_64/example_application".
	Output_Install_Dir="/tmp/ish"; Output_Bin_Dir="/tmp/ish"; Output_Helpers_Dir="/tmp/ish"; Output_Desktop_Dir="$Out_User_Desktop_Dir"
	Output_Menu_Files="/tmp/ish"; Output_Menu_DDir="/tmp/ish"; Output_Menu_Apps="/tmp/ish"; Output_PortSoft="/tmp/ish"
	
	_INIT_OUTPUTS
}

function _IMPORTANT_CHECK_LAST() { # -= (10) =- # Здесь можно использовать локализацию
	
	if [ "$MODE_SILENT" == "false" ]; then
		_CLEAR_BACKGROUND # Double Clear Crutch for Old GNOME...
		printf '\033[8;32;100t' # Resize terminal Window (100x32)
	fi
	
	# Проверка наличия 7-Zip в каталоге инструментов и установка прав на запуск при необходимости
	if [ "$Archive_Format" == "SZip" ]; then
		if [ -e "$Tool_SevenZip_bin" ]; then
			if ! [[ -x "$Tool_SevenZip_bin" ]]; then
				if ! chmod +x "$Tool_SevenZip_bin"; then _ABORT "chmod Tool_SevenZip_bin error"; fi
			fi
		else _ABORT "$Tool_SevenZip_bin not found"; fi
	fi
	
	if [ "$Current_OS_Name_Full" == "Debian GNU/Linux 9 (stretch)" ]; then
		_WARNING "OS bugs!" "$Str_CHECKLAST_BUI_DebianStretch"
	fi
	
	# Проверка наличия архивов с файлами приложения
	
	if [ ! -e "$Archive_Program_Files" ]; then _ERROR "_IMPORTANT_CHECK_LAST" "Archive \"program_files.\" not found.\n $Archive_Program_Files"; fi
	if [ ! -e "$Archive_System_Files" ]; then _ERROR "_IMPORTANT_CHECK_LAST" "Archive \"system_files\" not found.\n $Archive_System_Files"; fi
	
	if [ -e "$Temp_Dir" ]; then _ERROR "_IMPORTANT_CHECK_LAST" "Temp Dir is already present!\n  $Temp_Dir"; fi
	
	if [ "$Tools_Architecture" != "$Current_Architecture" ]; then _WARNING "$Str_CHECK_ERRORS_ARCH" "$Str_CHECK_ERRORS_ARCH_WARN"; fi
	
	# Check PortSoft
	if [ ! -e "$Output_PortSoft" ] || [ ! -e "$Output_Menu_DDir" ] || [ "$MODE_UPDATEBASE" == "true" ]; then
		_BASE_MAIN
		if [ "$MODE_SILENT" == "false" ]; then _CLEAR_BACKGROUND; fi
	fi
}

######### -------------- #########
######### -------------- #########
######### -------------- #########
######### -------------- #########
######### -------------- #########
######### -------------- #########
######### -------------- #########
######### -------------- #########
######### -------------- #########
######### -------------- #########


function _BASE_MAIN() {
	######### --------- #########
	Base_Header="${Font_Red}${Font_Bold} -=: Preparing PortSoft and Menu (Installer-SH part) :=-${Font_Reset}${Font_Reset_Color}\n"
	Base_Temp_Dir="/tmp/chimbalix-portsoft-menu-prepare""_$RANDOM""_$RANDOM" # TEMP Directory
	
	######### - Archive path - #########
	Archive_Base_Data="$Path_Installer_Data/tools/base_data.tar.xz"
	Archive_Base_Data_MD5="d8241c9a646b80a1d63cbde97369bb26"
	
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
     $Output_Menu_Apps/crutch-for-broken-linuxes.desktop
     $Output_Menu_Files/apps.menu
     $Output_Menu_DDir/apps.directory
     $Output_Menu_DDir/apps.png
  
  $Str_BASEINFO_Attention

 -${Font_Bold}${Font_DarkGreen}$Str_PACKAGEINFO_CurrentOS${Font_Reset_Color} $Current_OS_Name_Full ($Current_DE)${Font_Reset}
 -${Font_Bold}${Font_DarkGreen}$Str_PACKAGEINFO_InstallMode${Font_Reset_Color} $Install_Mode${Font_Reset}"
	
	echo -e "\n $Str_BASEINFO_Confirm"
	read -r base_info_confirm
	if [ "$base_info_confirm" == "y" ] || [ "$base_info_confirm" == "yes" ]; then :
	else _ABORT "${Font_Bold}${Font_Green}$Str_Interrupted_By_User${Font_Reset_Color}${Font_Reset}"; fi
	
	if [ "$MODE_DEBUG" == "true" ]; then echo "_PRINT_PACKAGE_INFO"; read -r pause; fi
fi
}

######### --------------------------------
######### Check and compare MD5 of archive

function _BASE_CHECK_MD5() {
	Base_Data_MD5=$(md5sum "$Archive_Base_Data" | awk '{print $1}')
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
		read -r base_errors_confirm
		if [ "$base_errors_confirm" == "y" ] || [ "$base_errors_confirm" == "yes" ]; then :
		else _ABORT "${Font_Bold}${Font_Green}$Str_Interrupted_By_User${Font_Reset_Color}${Font_Reset}"; fi
	fi
	
	if [ "$MODE_DEBUG" == "true" ]; then echo "_BASE_CHECK_MD5"; read -r pause; fi
}


function _BASE_CREATE_TEMP() {
	if [ -e "$Base_Temp_Dir" ]; then rm -rf "$Base_Temp_Dir"; fi;
	mkdir "$Base_Temp_Dir"
	if [ "$MODE_DEBUG" == "true" ]; then echo "_BASE_CREATE_TEMP"; read -r pause; fi
}

function _BASE_DELETE_TEMP() {
	if [ -e "$Base_Temp_Dir" ]; then rm -rf "$Base_Temp_Dir"; fi;
}

function _BASE_PREPARE_INPUT_FILES_GREP() {
	local p_text="$1"
	local p_path="$2"
	grep -rl "$p_text" "$Base_Temp_Dir" | xargs sed -i "s~$p_text~$p_path~g" &> /dev/null
}

function _BASE_PREPARE_FILES() {
	if ! tar -xf "$Archive_Base_Data" -C "$Base_Temp_Dir" &> /dev/null; then
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
	sudo cp -rf "$Base_Temp_Dir/applications/". "$Output_Menu_Apps"
	
	if [ ! -e "$Install_Path_System" ]; then sudo mkdir -p "$Install_Path_System"; fi
	sudo cp -rf "$Base_Temp_Dir/portsoft/". "$Install_Path_System"
}

function _BASE_INSTALL_USER() {
	if [ ! -e "$Output_Menu_Apps" ]; then mkdir -p "$Output_Menu_Apps"; fi
	if [ ! -e "$Output_Menu_DDir" ]; then mkdir -p "$Output_Menu_DDir"; fi
	if [ ! -e "$Output_Menu_Files" ]; then mkdir -p "$Output_Menu_Files"; fi
	
	cp -rf "$Base_Temp_Dir/desktop-directories/apps/". "$Output_Menu_DDir"
	cp -rf "$Base_Temp_Dir/menus/applications-merged/". "$Output_Menu_Files"
	cp -rf "$Base_Temp_Dir/applications/". "$Output_Menu_Apps"
	
	if [ ! -e "$Install_Path_User" ]; then mkdir -p "$Install_Path_User"; fi
	cp -rf "$Base_Temp_Dir/portsoft/". "$Install_Path_User"
}

function _BASE_INSTALL_COMPLETE() {
	if [ "$MODE_SILENT" == "false" ]; then
		echo -e " $Str_BASE_COMPLETE"
		read -r pause
	fi
}

######### -------------- #########
######### -------------- #########
######### -------------- #########
######### -------------- #########
######### -------------- #########
######### -------------- #########
######### -------------- #########
######### -------------- #########
######### -------------- #########
######### -------------- #########

######### ----------- #########
######### Test colors #########

function _TEST_COLORS() { # Здесь можно использовать локализацию
	
	echo -e "\n${Font_Bold} -= TEST COLORS =-"
	if [ "$Font_Styles_RGB" == "true" ]; then echo -e " RGB Mode"
	else echo -e " 8-bit table Mode"; fi
	echo -e "
 ${Font_Dim}Font_Dim ${Font_Black}Font_Black ${Font_DarkGray}Font_DarkGray ${Font_Gray}Font_Gray ${Font_White}Font_White ${Font_Reset_Color}

 ${Font_DarkRed}DarkRed ${Font_DarkGreen}DarkGreen ${Font_DarkYellow}DarkYellow ${Font_DarkBlue}DarkBlue ${Font_DarkMagenta}DarkMagenta ${Font_DarkCyan}DarkCyan
 ${Font_Red}Red     ${Font_Green}Green     ${Font_Yellow}Yellow     ${Font_Blue}Blue     ${Font_Magenta}Magenta     ${Font_Cyan}Cyan
 ${Font_Reset_Color}
 ${Font_Black_BG} Black_BG ${Font_DarkGray_BG} DarkGray_BG ${Font_Black}${Font_Gray_BG} Gray_BG ${Font_White_BG} White_BG ${Font_Reset_BG} ${Font_Reset_Color}
 ${Font_DarkRed_BG} DRed_BG ${Font_DarkGreen_BG} DGreen_BG ${Font_DarkYellow_BG} DYellow_BG ${Font_DarkBlue_BG} DBlue_BG ${Font_DarkMagenta_BG} DMagenta_BG ${Font_DarkCyan_BG} DCyan_BG ${Font_Reset_BG}
 ${Font_Black}${Font_Red_BG} Red_BG  ${Font_Green_BG} Green_BG  ${Font_Yellow_BG} Yellow_BG  ${Font_Blue_BG} Blue_BG  ${Font_Magenta_BG} Magenta_BG  ${Font_Cyan_BG} Cyan_BG  ${Font_Reset_BG}${Font_Reset_Color}"
}

######### -------------- #########
######### Base functions #########

function _CLEAR_BACKGROUND() {
	clear; clear
	#echo -ne '\e]11;black\e\\'
	echo -ne '\e[48;5;232m'
	#echo -ne '\e]10;white\e\\'
	echo -ne '\e[38;5;255m'
}

function _CLEAR_TEMP() { # Здесь нежелательно использовать локализацию
	
	local clear_temp_test=""
	
	if [ -n "$Temp_Dir" ]; then
		if [ -e "$Temp_Dir" ]; then
			clear_temp_test="$(echo "$Temp_Dir" | cut -d/ -f 1-3)"
			if [ "$clear_temp_test" == "$Temp_Test" ]; then
				if ! rm -rf "$Temp_Dir"; then _ABORT "Error clearinG temporary directory...\n   ($Temp_Dir)"; fi
			else _ABORT "$clear_temp_test != $Temp_Test"; fi
		fi
	fi
}

function _CREATE_TEMP() { # Здесь нежелательно использовать локализацию
	
	local clear_temp_test=""
	
	if [ -n "$Temp_Dir" ]; then
		_CLEAR_TEMP
		create_temp_test="$(echo "$Temp_Dir" | cut -d/ -f 1-3)"
		if [ "$create_temp_test" == "$Temp_Test" ]; then
			if [ ! -e "$Temp_DirISH" ]; then
				if ! mkdir -p "$Temp_DirISH"; then _ABORT "Error Creating temporary directory...\n   ($Temp_DirISH)"; fi
				chmod 777 "$Temp_DirISH"
			fi
			if ! mkdir -p "$Temp_Dir"; then _ABORT "Error Creating temporary directory...\n   ($Temp_Dir)"; fi
			chmod 700 "$Temp_Dir"
		else _ABORT "$create_temp_test != $Temp_Test"; fi
	else _ABORT "_CREATE_TEMP: Temp_Dir variable not found"; fi
}

# Функция экстренного завершения работы
function _ABORT() { # Здесь нежелательно использовать локализацию
	
	_CLEAR_BACKGROUND
	
	# Инициализация базовых переменных если ошибка произошла до загрузки локализации.
	if [ -z "$Header" ];             then local Header=" -= OPERATING SYSTEM NOT SUPPORTED? =-\n"; fi
	if [ -z "$Str_ABORT_Msg" ];      then local Str_ABORT_Msg="Exit code -"; fi
	if [ -z "$Str_ABORT_Exit" ];     then local Str_ABORT_Exit="Press Enter or close the window to exit."; fi
	if [ -z "$Str_ABORT_Errors" ];   then local Str_ABORT_Errors="Errors:"; fi
	if [ -z "$Str_ABORT_Warnings" ]; then local Str_ABORT_Warnings="Warnings:"; fi
	
	# Стандартное сообщение об ошибке если аргументы не были поданы при вызове функции
	local abort_message="${Font_Red}message not set...${Font_Reset_Color}"
	# Проверка наличия первого аргумента, если аргумент есть - стандартное сообщение перезаписывается новым
	if [ -n "$1" ]; then local abort_message="$1"; fi
	
	# Расширенная проверка ошибок
	if [ "$abort_message" == "funcerr" ] && [ -n "$2" ] && [ -n "$3" ]; then
		## Ошибка функции: _ABORT "funcerr" "имя функции" "код ошибки"
		echo -e "\
 $Header
  Error in function: $2
  Error code: $3
  
  $Str_ABORT_Exit"
	else
		## Общее сообщение об ошибке
		echo -e "\
$Header
  $Str_ABORT_Msg $abort_message"
	fi
	
	# Вывод списка ошибок при наличии
	if [ "$List_Errors" != "" ]; then echo -e "
  ${Font_Bold}${Font_Red}- $Str_ABORT_Errors${Font_Reset_Color}${Font_Reset} $List_Errors"; fi
	# Вывод списка предупреждений при наличии
	if [ "$List_Warnings" != "" ]; then echo -e "
  ${Font_Bold}${Font_Yellow}- $Str_ABORT_Warnings${Font_Reset_Color}${Font_Reset} $List_Warnings"; fi
	
	_CLEAR_TEMP # Очистка временных файлов
	
	echo -e "\n  $Str_ABORT_Exit" # "Нажмите Enter или закройте окно для выхода"...
	
	# Пауза, очистка и выход.
	read -r pause; clear; exit 1 # Double clear resets styles before going to the system terminal window
}

# Функция добавления ошибок в список
function _ERROR() {
	local err_first="Empty Error Title"
	local err_second="No description..."
	if [ -n "$1" ]; then local err_first="$1"; fi
	if [ -n "$2" ]; then local err_second="$2"; fi
	List_Errors="${List_Errors}\n   $err_first: $err_second"
}

# Функция добавления предупреждений в список
function _WARNING() {
	local warn_first="Empty Warning Title"
	local warn_second="No description."
	if [ -n "$1" ]; then local warn_first="$1"; fi
	if [ -n "$2" ]; then local warn_second="$2"; fi
	List_Warnings="${List_Warnings}\n   $warn_first: $warn_second"
}

######### ------------------------- #########
######### Print package information #########
function _PRINT_PACKAGE_INFO() { # -= (11) =- # Здесь можно использовать локализацию
if [ "$MODE_SILENT" == "false" ]; then # Пропустить функцию если включен тихий режим
	
	_CLEAR_BACKGROUND
	
	# Установка описания из настроек при стандартной локализации
	if [ "$Locale_Use_Default" == "true" ]; then Info_Description="$Info_Description_Default"; fi
	
	# Вывод описания
	echo -e "\
$Header
 ${Font_Bold}${Font_Cyan}$Str_PACKAGEINFO_Head${Font_Reset_Color}${Font_Reset}
 -${Font_Bold}${Font_Yellow}$Str_PACKAGEINFO_Name${Font_Reset_Color} $Info_Name${Font_Reset} ($Info_Version, $Program_Architecture)
 -${Font_Bold}${Font_Yellow}$Str_PACKAGEINFO_ReleaseDate${Font_Reset}${Font_Reset_Color} $Info_Release_Date
 -${Font_Bold}${Font_Yellow}$Str_PACKAGEINFO_Category${Font_Reset}${Font_Reset_Color} $Info_Category
 -${Font_Bold}${Font_Yellow}$Str_PACKAGEINFO_Platform${Font_Reset}${Font_Reset_Color} $Info_Platform
 -${Font_Bold}${Font_Yellow}$Str_PACKAGEINFO_InstalledSize${Font_Reset}${Font_Reset_Color} $Info_Installed_Size
 -${Font_Bold}${Font_Yellow}$Str_PACKAGEINFO_Licensing${Font_Reset}${Font_Reset_Color} $Info_Licensing
 -${Font_Bold}${Font_Yellow}$Str_PACKAGEINFO_Maintainer${Font_Reset}${Font_Reset_Color} $Info_Maintainer
 -${Font_Bold}${Font_Yellow}$Str_PACKAGEINFO_Developer${Font_Reset}${Font_Reset_Color} $Info_Developer
 -${Font_Bold}${Font_Yellow}$Str_PACKAGEINFO_URL${Font_Reset}${Font_Reset_Color} $Info_URL
 -${Font_Bold}${Font_Yellow}$Str_PACKAGEINFO_Description${Font_Reset_Color}${Font_Reset}
$Info_Description

 -${Font_Bold}${Font_Green}$Str_PACKAGEINFO_CurrentOS${Font_Reset_Color} $Current_OS_Name_Full ($Current_DE)${Font_Reset}
 -${Font_Bold}${Font_Green}$Str_PACKAGEINFO_InstallMode${Font_Reset_Color} $Install_Mode${Font_Reset}"
	
	# Вывод списка ошибок при наличии
	if [ "$List_Errors" != "" ]; then echo -e "\n ${Font_Bold}${Font_Red}- $Str_ABORT_Errors${Font_Reset_Color}${Font_Reset} $List_Errors"; fi
	
	# Вывод списка предупреждений при наличии
	if [ "$List_Warnings" != "" ]; then echo -e "\n ${Font_Bold}${Font_Yellow}- $Str_ABORT_Warnings${Font_Reset_Color}${Font_Reset} $List_Warnings"; fi
	
	# Вывод тестовой таблицы цветовой палитры если указано в настройках
	if [ "$Debug_Test_Colors" == "true" ]; then _TEST_COLORS; fi
	
	# Запрос подтверждения на продолжение
	echo -e "\n $Str_PACKAGEINFO_Confirm"
	read -r package_info_confirm
	if [ "$package_info_confirm" == "y" ] || [ "$package_info_confirm" == "yes" ]; then :
	else _ABORT "${Font_Bold}${Font_Green}$Str_Interrupted_By_User${Font_Reset_Color}${Font_Reset}"; fi
	
	if [ "$MODE_DEBUG" == "true" ]; then echo "_PRINT_PACKAGE_INFO"; read -r pause; fi
fi
}

######### -------------------------------- #########
######### Check and compare MD5 of archive #########

function _CHECK_MD5_COMPARE() {
	MD5_Error_ProgramFiles="false"
	MD5_Error_SystemFiles="false"

	MD5_Warning="false"
	
	MD5_Hash_ProgramFiles=$(md5sum "$Archive_Program_Files" | awk '{print $1}')
	MD5_Hash_SystemFiles=$(md5sum "$Archive_System_Files" | awk '{print $1}')
	
	if [ "$MD5_Hash_ProgramFiles" != "$Archive_MD5_Hash_ProgramFiles" ]; then MD5_Error_ProgramFiles="true"; fi
	if [ "$MD5_Hash_SystemFiles" != "$Archive_MD5_Hash_SystemFiles" ]; then MD5_Error_SystemFiles="true"; fi
	
	if [ "$MD5_Error_ProgramFiles" == "true" ] || [ "$MD5_Error_SystemFiles" == "true" ]; then MD5_Warning="true"; fi
}

function _CHECK_MD5_PRINT_GOOD() { # Здесь можно использовать локализацию
	
	_CLEAR_BACKGROUND
	
	echo -e "\
$Header
 ${Font_Bold}${Font_Cyan}$Str_CHECKMD5PRINT_Head${Font_Reset_Color}${Font_Reset}"
	
	echo -e "
  ${Font_Green}$Str_CHECKMD5PRINT_Verified
   ${Font_Bold}$Str_CHECKMD5PRINT_Real_pHash${Font_Reset}  \"$MD5_Hash_ProgramFiles\"
   ${Font_Bold}$Str_CHECKMD5PRINT_Real_sHash${Font_Reset}   \"$MD5_Hash_SystemFiles\""
	
	echo -e "${Font_Reset_Color}
  ${Font_Bold}$Str_CHECKMD5PRINT_Enter_To_Continue${Font_Reset}"
	
	read -r pause
}

function _CHECK_MD5_PRINT_WARNING() { # Здесь можно использовать локализацию
	
	_CLEAR_BACKGROUND
	
	echo -e "\
$Header
 ${Font_Bold}${Font_Cyan}$Str_CHECKMD5PRINT_Head${Font_Reset_Color}${Font_Reset}"
	echo -e "\

  $Str_ATTENTION ${Font_Bold}${Font_DarkRed}$Str_CHECKMD5PRINT_Hash_Not_Match${Font_Reset_Color}
  ${Font_Red}$Str_CHECKMD5PRINT_Hash_Not_Match2${Font_Reset_Color}${Font_Reset}"
	if [ "$MD5_Error_ProgramFiles" == "true" ]; then
		echo -e "\

   ${Font_Bold}$Str_CHECKMD5PRINT_Expected_pHash${Font_Reset} \"$Archive_MD5_Hash_ProgramFiles\"
   ${Font_Bold}$Str_CHECKMD5PRINT_Real_pHash${Font_Reset}     \"$MD5_Hash_ProgramFiles\""; fi
	if [ "$MD5_Error_SystemFiles" == "true" ]; then
		echo -e "\

   ${Font_Bold}$Str_CHECKMD5PRINT_Expected_sHash${Font_Reset} \"$Archive_MD5_Hash_SystemFiles\"
   ${Font_Bold}$Str_CHECKMD5PRINT_Real_sHash${Font_Reset}     \"$MD5_Hash_SystemFiles\""; fi
	
	echo -e "\n  $Str_CHECKMD5PRINT_yes_To_Continue"
	read -r errors_confirm
	if [ "$errors_confirm" == "y" ] || [ "$errors_confirm" == "yes" ]; then :
	else _ABORT "${Font_Bold}${Font_Green}$Str_Interrupted_By_User${Font_Reset_Color}${Font_Reset}"; fi
}

function _CHECK_MD5_PRINT() { # Здесь можно использовать локализацию
	
	_CLEAR_BACKGROUND
	
	echo -e "\
$Header
 ${Font_Bold}${Font_Cyan}$Str_CHECKMD5_Head${Font_Reset_Color}${Font_Reset}
  $Str_CHECKMD5_Sub_Head
   $Str_CHECKMD5_Sub_Head2"
}

function _CHECK_MD5() { # -= (12) =- # Проверить хэши и вывести ошибки при наличии если активен тихий режим, иначе полностью вывести информацию
	
	if [ "$MODE_SILENT" == "true" ]; then _CHECK_MD5_COMPARE
		if [ "$MD5_Warning" == "true" ]; then _CHECK_MD5_PRINT_WARNING; fi
	else
		_CHECK_MD5_PRINT
		_CHECK_MD5_COMPARE
		if [ "$MD5_Warning" == "true" ]; then _CHECK_MD5_PRINT_WARNING
		else _CHECK_MD5_PRINT_GOOD; fi
		
		if [ "$MODE_DEBUG" == "true" ]; then echo "_CHECK_MD5"; read -r pause; fi
	fi
}

######### -------------------------- #########
######### Installation configuration #########

function _INSTALL_CONFIG_MODE() { # -= (13) =- # Здесь можно использовать локализацию
if [ "$MODE_SILENT" == "true" ]; then : # Пропустить функцию если включен тихий режим
else
	_CLEAR_BACKGROUND
	
	echo -e "\
$Header
 ${Font_Bold}${Font_Cyan}Настройка режима установки:${Font_Reset_Color}${Font_Reset}

 -${Font_Bold}${Font_Green} Текущий режим:${Font_Yellow} $Install_Mode${Font_Reset_Color}${Font_Reset}
   $Output_Install_Dir

 -${Font_Bold} Описание режима \"User\":${Font_Reset}
   Устанавливливает программу в домашний каталог PortSoft.
   + Root права для установки не нужны.
   + Программа устанавливается только для текущего пользователя.

 -${Font_Bold} Описание режима \"System\":${Font_Reset}
   Устанавливает программу в системный каталог PortSoft (/portsoft).
   + Программа устанавливается для всех пользователей системы.
   - Нужны root права."

	echo -e "

 Нажмите Enter чтобы продолжить в текущем режиме (настроен создателем пакета).
 Введите \"${Font_Green}u${Font_Reset_Color}\" или \"${Font_Yellow}s${Font_Reset_Color}\" чтобы изменить режим установки (${Font_Green}u - User${Font_Reset_Color} | ${Font_Yellow}s - System${Font_Reset_Color})."
	
	read -r install_config_confirm_s
	if [ "$install_config_confirm_s" == "s" ]; then Install_Mode="System"
	elif [ "$install_config_confirm_s" == "u" ]; then Install_Mode="User"; fi

	if [ "$MODE_DEBUG" == "true" ]; then echo "_PRINT_INSTALL_SETTINGS"; read -r pause; fi
fi
}

function _INSTALL_CONFIG_CFG() { # -= (13.1) =- # Здесь можно использовать локализацию
if [ "$MODE_SILENT" == "true" ]; then : # Пропустить функцию если включен тихий режим
else
	_CLEAR_BACKGROUND
	
	echo -e "\
$Header
 ${Font_Bold}${Font_Cyan}Настройка файлов конфигурации:${Font_Reset_Color}${Font_Reset}

 -${Font_Bold}${Font_Green} Текущий режим:${Font_Yellow} $Install_Configs${Font_Reset_Color}${Font_Reset}

 -${Font_Bold} Описание режима \"PortSoft\":${Font_Reset}
   Файлы конфигурации находятся в специально отведенном каталоге.
   Это необходимо для установки некоторых программ.
   + Решает проблему конфликта файлов конфигурации при установке разных версий программы.
   + Решает проблему накопления мусора в домашнем каталоге пользователя.
   + Позволяет создать резервную копию программы вместе с настройками.
   ~ Создатель установочного пакета должен грамотно настроить лаунчеры для правильной работы.

 -${Font_Bold} Описание режима \"SysDef\":${Font_Reset}
   Используется домашний каталог пользователя для размещения файлов конфигурации.
   Используйте это только при необходимости.
   ~ Так работает большинство программ в среде Linux."

	echo -e "

 Нажмите Enter чтобы продолжить в текущем режиме (настроен создателем пакета).
 Введите \"${Font_Green}p${Font_Reset_Color}\" или \"${Font_Yellow}s${Font_Reset_Color}\" чтобы изменить режим установки (${Font_Green}p - PortSoft${Font_Reset_Color} | ${Font_Yellow}s - SysDef${Font_Reset_Color})."
	
	read -r install_config_confirm_c
	if [ "$install_config_confirm_c" == "s" ]; then Install_Configs="SysDef"
	elif [ "$install_config_confirm_c" == "p" ]; then Install_Configs="PortSoft"; fi

	if [ "$MODE_DEBUG" == "true" ]; then echo "_PRINT_INSTALL_SETTINGS"; read -r pause; fi
fi
}

######### --------------------------- #########
######### Print installation settings #########

function _PRINT_INSTALL_SETTINGS() { # -= (13.2) =- # Здесь можно использовать локализацию
if [ "$MODE_SILENT" == "true" ]; then : # Пропустить функцию если включен тихий режим
else
	_INIT_OUTPUTS
	_CLEAR_BACKGROUND
	
	echo -e "\
$Header
 ${Font_Bold}${Font_Cyan}$Str_PRINTINSTALLSETTINGS_Head 

 -${Font_Bold}${Font_Green}Режим установки:${Font_Yellow} $Install_Mode${Font_Reset_Color}${Font_Reset}
 -${Font_Bold}${Font_Green}Файлы конфигурации:${Font_Yellow} $Install_Configs${Font_Reset_Color}${Font_Reset}

 -${Font_Bold}${Font_Green}$Str_PRINTINSTALLSETTINGS_Temp_Dir${Font_Reset_Color}${Font_Reset} $Temp_Dir
 
 -${Font_Bold}${Font_Green}$Str_PRINTINSTALLSETTINGS_App_Inst_Dir
   ${Font_Reset_Color}${Font_Reset}$Output_Install_Dir

 -${Font_Bold}${Font_Green}$Str_PRINTINSTALLSETTINGS_Menu_Dirs${Font_Reset_Color}${Font_Reset}
   $Output_Menu_Files
   $Output_Menu_DDir
   $Output_Menu_Apps

 -${Font_Bold}${Font_Green}$Str_PRINTINSTALLSETTINGS_Bin_Dir${Font_Reset_Color}${Font_Reset} $Output_Bin_Dir"
		
	if [ "$Install_Helpers" == "true" ]; then
		if [ "$Current_DE" == "XFCE" ]; then
			echo -e "
 -${Font_Bold}${Font_Green}$Str_PRINTINSTALLSETTINGS_Helpers_Dir${Font_Reset_Color}${Font_Reset} $Output_Helpers_Dir"; fi; fi

	if [ "$Install_Desktop_Icons" == "true" ]; then
		echo -e "
 -${Font_Bold}${Font_Green}$Str_PRINTINSTALLSETTINGS_Desktop_Dir${Font_Reset_Color}${Font_Reset} $Output_Desktop_Dir"; fi
	
	if [ "$Install_Mode" == "System" ]; then
		echo -e "
 -$Str_ATTENTION! ${Font_Bold}${Font_Yellow}$Str_PRINTINSTALLSETTINGS_System_Mode${Font_Reset_Color}${Font_Reset}"; fi
		
	echo -e "
 $Str_PRINTINSTALLSETTINGS_Before_Install

 ${Font_Bold}${Font_Red}$Str_PRINTINSTALLSETTINGS_Confirm${Font_Reset_Color}${Font_Reset}"
	
	read -r install_settings_confirm
	if [ "$install_settings_confirm" == "y" ] || [ "$install_settings_confirm" == "yes" ]; then :
	else _ABORT "${Font_Bold}${Font_Green}$Str_Interrupted_By_User${Font_Reset_Color}${Font_Reset}"; fi

	if [ "$MODE_DEBUG" == "true" ]; then echo "_PRINT_INSTALL_SETTINGS"; read -r pause; fi
fi
}

######### ------------------- #########
######### Prepare Input Files #########

function _PREPARE_INPUT_FILES_GREP() { # Здесь можно использовать локализацию
	
	local prepare_text="/tmp/ish"
	local prepare_path="/tmp/ish"
	local prepare_error="false"
	
	if [ -n "$1" ] && [ -n "$2" ]; then
		local prepare_text="$1"
		local prepare_path="$2"
	else
		local prepare_error="true"
		_WARNING "PREPARE_INPUT_FILES_GREP" "not enough arguments for the function to work."
	fi
	
	if [ "$prepare_error" == "false" ]; then 
		grep -rl "$prepare_text" "$Temp_Dir" | xargs sed -i "s~$prepare_text~$prepare_path~g" &> /dev/null; fi
}

function _PREPARE_INPUT_FILES() { # -= (14) =- # Здесь можно использовать локализацию
	
	_CREATE_TEMP
	
	if [ "$Archive_Format" == "SZip" ]; then
		if ! "$Tool_SevenZip_bin" x "$Archive_System_Files" -o"$Temp_Dir/" &> /dev/null; then
			_ABORT "$Str_PREPAREINPUTFILES_Err_Unpack (_PREPARE_INPUT_FILES). $Str_PREPAREINPUTFILES_Err_Unpack2"; fi
	fi
	
	if [ "$Archive_Format" == "Tar" ]; then
		if ! "$Tool_Tar" -xf "$Archive_System_Files" -C "$Temp_Dir"; then
			_ABORT "$Str_PREPAREINPUTFILES_Err_Unpack (_PREPARE_INPUT_FILES). $Str_PREPAREINPUTFILES_Err_Unpack2"; fi
	fi
	
	for file in "$Temp_Dir"/*; do
		_PREPARE_INPUT_FILES_GREP "PATH_TO_FOLDER" "$Output_Install_Dir"
		_PREPARE_INPUT_FILES_GREP "UNIQUE_APP_FOLDER_NAME" "$Unique_App_Folder_Name"
		_PREPARE_INPUT_FILES_GREP "PROGRAM_NAME_IN_MENU" "$Program_Name_In_Menu"
		_PREPARE_INPUT_FILES_GREP "PROGRAM_INSTALL_MODE" "$Program_Install_Mode"
		_PREPARE_INPUT_FILES_GREP "PROGRAM_UNINSTALLER_FILE" "$Program_Uninstaller_File"
		_PREPARE_INPUT_FILES_GREP "PROGRAM_UNINSTALLER_ICON" "$Program_Uninstaller_Icon"
		_PREPARE_INPUT_FILES_GREP "ADDITIONAL_CATEGORIES" "$Additional_Categories"
		_PREPARE_INPUT_FILES_GREP "MENU_DIRECTORY_NAME" "$Menu_Directory_Name"
		_PREPARE_INPUT_FILES_GREP "MENU_DIRECTORY_ICON" "$Menu_Directory_Icon"
	done
	
	local All_Renamed="false"
	
	while [ "$All_Renamed" == "false" ]; do
		if find "$Temp_Dir/" -name "UNIQUE_APP_FOLDER_NAME*" | sed -e "p;s~UNIQUE_APP_FOLDER_NAME~$Unique_App_Folder_Name~" | xargs -n2 mv &> /dev/null; then
			local All_Renamed="true"
		fi
	done
	
	OLD_IFS=$IFS; IFS=''
	
	local Files_Bin_Dir=();   while read -r line; do Files_Bin_Dir+=("$line");   done < <(ls "$Input_Bin_Dir")
	local Files_Menu=();      while read -r line; do Files_Menu+=("$line");      done < <(ls "$Input_Menu_Files_Dir")
	local Files_Menu_Dir=();  while read -r line; do Files_Menu_Dir+=("$line");  done < <(ls "$Input_Menu_Desktop_Dir")
	local Files_Menu_Apps=(); while read -r line; do Files_Menu_Apps+=("$line"); done < <(ls "$Input_Menu_Apps_Dir")
	
	local arr_0=(); local arr_1=(); local arr_2=(); local arr_3=(); local arr_4=(); local arr_5=()
	
	for file in "${!Files_Bin_Dir[@]}"; do local arr_0[file]="$Output_Bin_Dir/${Files_Bin_Dir[$file]}"; done
	
	if [ "$Install_Helpers" == "true" ]; then 
		if [ "$Current_DE" == "XFCE" ]; then
			local Files_Helpers_Dir=(); while read -r line; do Files_Helpers_Dir+=("$line"); done < <(ls "$Input_Helpers_Dir")
			for file in "${!Files_Helpers_Dir[@]}"; do local arr_1[file]="$Output_Helpers_Dir/${Files_Helpers_Dir[$file]}"; done
		fi
	fi
	
	if [ "$Install_Desktop_Icons" == "true" ]; then 
		local Files_Desktop_Dir=(); while read -r line; do Files_Desktop_Dir+=("$line"); done < <(ls "$Input_Desktop_Dir")
		for file in "${!Files_Desktop_Dir[@]}"; do local arr_2[file]="$Output_Desktop_Dir/${Files_Desktop_Dir[$file]}"; done
	fi
	
	IFS=$OLD_IFS
	
	for file in "${!Files_Menu[@]}"; do local arr_3[file]="$Output_Menu_Files/${Files_Menu[$file]}"; done
	for file in "${!Files_Menu_Dir[@]}"; do local arr_4[file]="$Output_Menu_DDir/${Files_Menu_Dir[$file]}"; done
	for file in "${!Files_Menu_Apps[@]}"; do local arr_5[file]="$Output_Menu_Apps/${Files_Menu_Apps[$file]}"; done
	
	Output_Files_All=("$Output_Install_Dir" "${arr_0[@]}" "${arr_1[@]}" "${arr_2[@]}" "${arr_3[@]}" "${arr_4[@]}" "${arr_5[@]}")
	
	if [ "$MODE_DEBUG" == "true" ]; then echo "_PREPARE_INPUT_FILES"; read -r pause; fi
}

######### ------------- #########
######### Check outputs #########

function _CHECK_OUTPUTS() { # -= (15) =- # Здесь можно использовать локализацию
	
	local check_outputs_error="false"
	local arr_files_sorted=()
	
	for file in "${!Output_Files_All[@]}"; do
		if [ -e "${Output_Files_All[$file]}" ]; then arr_files_sorted[file]="${Output_Files_All[$file]}"; local check_outputs_error="true"; fi
	done
	
	if [ "$check_outputs_error" == "true" ] && [ "$MODE_UPDATE" == "false" ]; then
		_CLEAR_BACKGROUND
		echo -e "\
$Header
 ${Font_Bold}${Font_Cyan}$Str_CHECKOUTPUTS_Head${Font_Reset_Color}${Font_Reset}"
		echo -e "
  $Str_ATTENTION! $Str_CHECKOUTPUTS_Already_Present
$(for file in "${!arr_files_sorted[@]}"; do echo "   ${arr_files_sorted[$file]}"; done)"
		echo -e "
   $Str_CHECKOUTPUTS_Attention
   ${Font_Yellow}$Str_CHECKOUTPUTS_Attention2${Font_Reset_Color}

 $Str_CHECKOUTPUTS_Confirm"
		
		read -r install_confirm
		if [ "$install_confirm" == "y" ] || [ "$install_confirm" == "yes" ]; then :
		else _ABORT "${Font_Bold}${Font_Green}$Str_Interrupted_By_User${Font_Reset_Color}${Font_Reset}"; fi
	else :
	fi
	
	if [ "$MODE_DEBUG" == "true" ]; then echo "_CHECK_OUTPUTS"; read -r pause; fi
}

######### --------------- #########
######### Install Helpers #########

### -------------- ###
### Helpers (XFCE) ###
# Default paths:
#  /usr/share/xfce4/helpers/
#  ~/.local/share/xfce4/helpers/

function _INSTALL_HELPERS_XFCE_SYSTEM() {
	if [ ! -e "$Output_Helpers_Dir" ]; then sudo mkdir -p "$Output_Helpers_Dir"; fi
	sudo cp -rf "$Input_Helpers_Dir/." "$Output_Helpers_Dir"
}

function _INSTALL_HELPERS_XFCE_USER() {
	if [ ! -e "$Output_Helpers_Dir" ]; then mkdir -p "$Output_Helpers_Dir"; fi
	cp -rf "$Input_Helpers_Dir/." "$Output_Helpers_Dir"
}

function _INSTALL_HELPERS() { # Здесь можно использовать локализацию
	
	if [ -e "$Input_Helpers_Dir" ]; then
		if [ "$Current_DE" == "XFCE" ]; then
			if [ "$Install_Mode" == "System" ]; then _INSTALL_HELPERS_XFCE_SYSTEM; else _INSTALL_HELPERS_XFCE_USER; fi; fi
	else _ERROR "_INSTALL_HELPERS" "Input_Helpers_Dir not found."; fi
}

######### --------------------- #########
######### Install Desktop Icons #########

function _INSTALL_DESKTOP_ICONS() { # Здесь можно использовать локализацию
	
	if [ -e "$Input_Desktop_Dir" ]; then
		cp -rf "$Input_Desktop_Dir/." "$Output_Desktop_Dir"
	else _ERROR "_INSTALL_DESKTOP_ICONS" "Input_Desktop_Dir not found."; fi
}

######### ------------------------------- #########
######### Install application (USER MODE) #########

function _INSTALL_APP_USER() { # Здесь можно использовать локализацию
	Unpack_Error_Code=""
	if [ "$MODE_SILENT" == "false" ]; then
		_CLEAR_BACKGROUND
		echo -e "\
$Header
 ${Font_Bold}${Font_Cyan}$Str_INSTALLAPP_Head${Font_Reset_Color}${Font_Reset}"; fi
	
	if [ "$MODE_SILENT" == "false" ]; then echo " $Str_INSTALLAPP_Create_Out"; fi
	
	# Check Output Folder
	if [ ! -e "$Output_Install_Dir" ]; then if ! mkdir -p "$Output_Install_Dir"; then _ABORT "$Str_INSTALLAPP_No_Rights"; fi
	elif ! touch "$Output_Install_Dir"; then _ABORT "$Str_INSTALLAPP_No_Rights"; fi
	
	if [ "$MODE_SILENT" == "false" ]; then echo " $Str_INSTALLAPP_Unpack_App"; fi
	
	if [ "$Archive_Format" == "SZip" ]; then
		if ! "$Tool_SevenZip_bin" x -snld -aoa "$Archive_Program_Files" -o"$Output_Install_Dir/" &> /dev/null; then
			Unpack_Error_Code="error"
		fi
	fi
	
	if [ "$Archive_Format" == "Tar" ]; then
		if ! "$Tool_Tar" -xf "$Archive_Program_Files" -C "$Output_Install_Dir"; then
			Unpack_Error_Code="error"
		fi
	fi
	
	if [ "$Unpack_Error_Code" == "error" ]; then
		echo -e "\n $Str_ATTENTION $Str_INSTALLAPP_Unpack_Err"
		echo " $Str_INSTALLAPP_Unpack_Err2"
		echo -e "\n $Str_INSTALLAPP_Unpack_Err_Continue"
		read -r confirm_unpack
		if [ "$confirm_unpack" == "y" ] || [ "$confirm_unpack" == "yes" ]; then echo "  $Str_INSTALLAPP_Unpack_Continue"
		else _ABORT "$Str_ERROR! ${Font_Bold}${Font_Yellow}$Str_INSTALLAPP_Unpack_Err_Abort${Font_Reset_Color}${Font_Reset}"; fi
	fi
	
	if [ "$MODE_SILENT" == "false" ]; then echo " $Str_INSTALLAPP_Install_Bin_Menu"; fi
	
	# Check Bin folder
	if [ ! -e "$Output_Bin_Dir" ]; then mkdir "$Output_Bin_Dir"; fi
	
	# Copy Bin files
	cp -rf "$Input_Bin_Dir/." "$Output_Bin_Dir"
	
	# Сopy Menu files
	cp -rf "$Input_Menu_Files_Dir/." "$Output_Menu_Files"
	cp -rf "$Input_Menu_Desktop_Dir/." "$Output_Menu_DDir"
	cp -rf "$Input_Menu_Apps_Dir/." "$Output_Menu_Apps"
	
	# Install Helpers
	if [ "$Install_Helpers" == "true" ]; then _INSTALL_HELPERS; fi
	# Install Desktop files
	if [ "$Install_Desktop_Icons" == "true" ]; then _INSTALL_DESKTOP_ICONS; fi
	
	if [ "$MODE_DEBUG" == "true" ]; then echo "_INSTALL_APP"; read -r pause; fi
}

######### --------------------------------- #########
######### Install application (SYSTEM MODE) #########

function _INSTALL_APP_SYSTEM() { # Здесь можно использовать локализацию
	Unpack_Error_Code=""
	if [ "$MODE_SILENT" == "false" ]; then
		_CLEAR_BACKGROUND
		echo -e "\
$Header
 ${Font_Bold}${Font_Cyan}$Str_INSTALLAPP_Head${Font_Reset_Color}${Font_Reset}"; fi
		
	if [ "$MODE_SILENT" == "false" ]; then echo " $Str_INSTALLAPP_Create_Out"; fi
	
	# Check Output Folder
	if [ ! -e "$Output_Install_Dir" ]; then if ! sudo mkdir -p "$Output_Install_Dir"; then _ABORT "$Str_INSTALLAPP_No_Rights"; fi
	elif ! sudo touch "$Output_Install_Dir"; then _ABORT "$Str_INSTALLAPP_No_Rights"; fi
	
	if [ "$MODE_SILENT" == "false" ]; then echo " $Str_INSTALLAPP_Unpack_App"; fi
	
	if [ "$Archive_Format" == "SZip" ]; then
		if ! sudo "$Tool_SevenZip_bin" x -snld -aoa "$Archive_Program_Files" -o"$Output_Install_Dir/" &> /dev/null; then
			Unpack_Error_Code="error"
		fi
	fi
	
	if [ "$Archive_Format" == "Tar" ]; then
		if ! sudo "$Tool_Tar" -xf "$Archive_Program_Files" -C "$Output_Install_Dir"; then
			Unpack_Error_Code="error"
		fi
	fi
	
	if [ "$Unpack_Error_Code" == "error" ]; then
		echo -e "\n $Str_ATTENTION $Str_INSTALLAPP_Unpack_Err"
		echo " $Str_INSTALLAPP_Unpack_Err2"
		echo -e "\n $Str_INSTALLAPP_Unpack_Err_Continue"
		read -r confirm_unpack
		if [ "$confirm_unpack" == "y" ] || [ "$confirm_unpack" == "yes" ]; then echo "  $Str_INSTALLAPP_Unpack_Continue"
		else _ABORT "$Str_ERROR! ${Font_Bold}${Font_Yellow}$Str_INSTALLAPP_Unpack_Err_Abort${Font_Reset_Color}${Font_Reset}"; fi
	fi
	
	if [ "$MODE_SILENT" == "false" ]; then echo " $Str_INSTALLAPP_Install_Bin_Menu"; fi
	
	if [ "$MODE_SILENT" == "false" ]; then echo " $Str_INSTALLAPP_Set_Rights"; fi
	sudo chmod -R $Out_App_Folder_Permissions "$Output_Install_Dir"
	sudo chown -R $Out_App_Folder_Owner "$Output_Install_Dir"
	
	# Copy Bin files
	sudo cp -rf "$Input_Bin_Dir/." "$Output_Bin_Dir"
	
	# Сopy Menu files
	sudo cp -rf "$Input_Menu_Files_Dir/." "$Output_Menu_Files"
	sudo cp -rf "$Input_Menu_Desktop_Dir/." "$Output_Menu_DDir"
	sudo cp -rf "$Input_Menu_Apps_Dir/." "$Output_Menu_Apps"
	
	# Install Helpers
	_INSTALL_HELPERS
	
	# Install Desktop files
	if [ "$Install_Desktop_Icons" == "true" ]; then
		_INSTALL_DESKTOP_ICONS; fi
	
	if [ "$MODE_DEBUG" == "true" ]; then echo "_INSTALL_APP"; read -r pause; fi
}

######### ------------------- #########
######### Install application #########

function _INSTALL_APPLICATION() { # -= (16) =-
	if [ "$Install_Mode" == "System" ]; then _INSTALL_APP_SYSTEM; else _INSTALL_APP_USER; fi
}

######### ------------------------ #########
######### Prepare uninstaller file #########

function _PREPARE_UNINSTALLER_SYSTEM() { # Здесь можно использовать локализацию
	
	if [ -e "$Output_Uninstaller" ]; then
		for filename in "${!Output_Files_All[@]}"; do
			# КОСТЫЛЬ ДЛЯ КРИВЫХ ДИСТРИБУТИВОВ, У КОТОРЫХ СЛЕТАЮТ ПРАВА ДОСТУПА К ФАЙЛУ ПОСЛЕ РАБОТЫ УТИЛИТЫ "SED"!
			if [ "$(stat -c "%a" "$Output_Uninstaller")" != "755" ]; then
				sudo chmod 755 "$Output_Uninstaller"
			fi
			
			local CurrentFile="${Output_Files_All[$filename]}"
			sudo sed -i "s~FilesToDelete=(~&\n$CurrentFile~" "$Output_Uninstaller"
		done
		sudo chmod 755 "$Output_Uninstaller"
		sudo chown $Out_App_Folder_Owner "$Output_Uninstaller"
	else _ERROR "_PREPARE_UNINSTALLER_SYSTEM" "Output_Uninstaller not found."; fi
}

function _PREPARE_UNINSTALLER_USER() { # Здесь можно использовать локализацию
	
	if [ -e "$Output_Uninstaller" ]; then
		for filename in "${!Output_Files_All[@]}"; do
			# КОСТЫЛЬ ДЛЯ КРИВЫХ ДИСТРИБУТИВОВ, У КОТОРЫХ СЛЕТАЮТ ПРАВА ДОСТУПА К ФАЙЛУ ПОСЛЕ РАБОТЫ УТИЛИТЫ "SED"!
			if [ "$(stat -c "%a" "$Output_Uninstaller")" != "744" ]; then
				chmod 744 "$Output_Uninstaller"
			fi
			
			local CurrentFile="${Output_Files_All[$filename]}"
			sed -i "s~FilesToDelete=(~&\n$CurrentFile~" "$Output_Uninstaller"
		done
		chmod 744 "$Output_Uninstaller"
	else _ERROR "_PREPARE_UNINSTALLER_USER" "Output_Uninstaller not found."; fi
}

function _PREPARE_UNINSTALLER() { # -= (17) =-
	if [ "$Install_Mode" == "System" ]; then _PREPARE_UNINSTALLER_SYSTEM; fi
	if [ "$Install_Mode" == "User" ]; then _PREPARE_UNINSTALLER_USER; fi
	
	if [ "$MODE_DEBUG" == "true" ]; then echo "_PREPARE_UNINSTALLER"; read -r pause; fi
}

function _PREPARE_LAUNCHERS_SYSTEM() {
	for filename in "${!Program_Launchers[@]}"; do
		local CurrentFile="${Program_Launchers[$filename]}"
		if [ "$Install_Configs" == "SysDef" ]; then
			sudo sed -i 's/ISHMoveHomeDir=.*/ISHMoveHomeDir="false"/' "$Output_Install_Dir/$CurrentFile"
		else
			sudo sed -i 's/ISHMoveHomeDir=.*/ISHMoveHomeDir="true"/' "$Output_Install_Dir/$CurrentFile"
		fi
		
		sudo sed -i "s/ISHPogramArch=.*/ISHPogramArch=\"$Program_Architecture\"/" "$Output_Install_Dir/$CurrentFile"
		sudo sed -i "s/ISHProgramName=.*/ISHProgramName=\"$Unique_App_Folder_Name\"/" "$Output_Install_Dir/$CurrentFile"
		#sudo sed -i "s/ISHInstallMode=.*/ISHInstallMode=\"$Install_Mode\"/" "$Output_Install_Dir/$CurrentFile"
		
		# КОСТЫЛЬ ДЛЯ КРИВЫХ ДИСТРИБУТИВОВ, У КОТОРЫХ СЛЕТАЮТ ПРАВА ДОСТУПА К ФАЙЛУ ПОСЛЕ РАБОТЫ УТИЛИТЫ "SED"!
		if [ "$(stat -c "%a" "$Output_Install_Dir/$CurrentFile")" != "755" ]; then chmod 755 "$Output_Install_Dir/$CurrentFile"; fi
	done
}

function _PREPARE_LAUNCHERS_USER() {
	for filename in "${!Program_Launchers[@]}"; do
		local CurrentFile="${Program_Launchers[$filename]}"
		if [ "$Install_Configs" == "SysDef" ]; then
			sed -i 's/ISHMoveHomeDir=.*/ISHMoveHomeDir="false"/' "$Output_Install_Dir/$CurrentFile"
		else
			sed -i 's/ISHMoveHomeDir=.*/ISHMoveHomeDir="true"/' "$Output_Install_Dir/$CurrentFile"
		fi
		
		sed -i "s/ISHPogramArch=.*/ISHPogramArch=\"$Program_Architecture\"/" "$Output_Install_Dir/$CurrentFile"
		sed -i "s/ISHProgramName=.*/ISHProgramName=\"$Unique_App_Folder_Name\"/" "$Output_Install_Dir/$CurrentFile"
		#sed -i "s/ISHInstallMode=.*/ISHInstallMode=\"$Install_Mode\"/" "$Output_Install_Dir/$CurrentFile"
		
		# КОСТЫЛЬ ДЛЯ КРИВЫХ ДИСТРИБУТИВОВ, У КОТОРЫХ СЛЕТАЮТ ПРАВА ДОСТУПА К ФАЙЛУ ПОСЛЕ РАБОТЫ УТИЛИТЫ "SED"!
		if [ "$(stat -c "%a" "$Output_Install_Dir/$CurrentFile")" != "755" ]; then chmod 755 "$Output_Install_Dir/$CurrentFile"; fi
	done
}

function _PREPARE_LAUNCHERS() { # -= (17.1) =-
	if [ "$Install_Mode" == "System" ]; then _PREPARE_LAUNCHERS_SYSTEM; fi
	if [ "$Install_Mode" == "User" ]; then _PREPARE_LAUNCHERS_USER; fi
	
	if [ "$MODE_DEBUG" == "true" ]; then echo "_PREPARE_LAUNCHERS"; read -r pause; fi
}

#Install_Configs="PortSoft"

######### ---- #########
####### Strings! #######
###### Set Locale ######

function _SET_LOCALE_DEFAULT() {
	Info_Description="  Not used in this place... The translation is located in the \"locales/\" directory."
	
	Str_ERROR="${Font_Bold}${Font_Red}ERROR${Font_Reset_Color}${Font_Reset}"
	Str_ATTENTION="${Font_Bold}${Font_Yellow}ATTENTION${Font_Reset_Color}${Font_Reset}"
	Str_WARNING="${Font_Bold}${Font_Yellow}WARNING${Font_Reset_Color}${Font_Reset}"
	
	Str_Interrupted_By_User="Interrupted by user"
	Str_Complete_Install="The installation process has been completed successfully."
	
	Str_ABORT_Msg="Exit code -"
	Str_ABORT_Exit="Press Enter or close the window to exit."
	Str_ABORT_Errors="Errors:"
	Str_ABORT_Warnings="Warnings:"
	
	Str_BASEINFO_Head="Installing basic components:"
	Str_BASEINFO_Warning="Attention! Your system requires preparation, the following basic components must be installed:"
	Str_BASEINFO_PortSoft="PortSoft directory:"
	Str_BASEINFO_PortSoft_Full="Basic directory for placing programs."
	Str_BASEINFO_MenuApps="Stable \"Applications\" menu category:"
	Str_BASEINFO_MenuApps_Full="Stable \"Applications\" category in the menu for placing shortcuts to installed programs."
	Str_BASEINFO_Attention="Attention! The components will be installed according to the current installation mode.\n  AFTER CONFIRMATION, THIS ACTION CANNOT BE CANCELLED!\n  For proper operation, your distribution must support the XDG standard!\n  The menu must also support subcategories!\n  You may also need to Log Out to refresh the menu after installation."
	Str_BASEINFO_Confirm="Start the installation process? Enter \"y\" or \"yes\" to confirm."
	Str_BASE_COMPLETE="Done, depending on the distribution the menu may not appear until you log in again.\n Press \"Enter\" to continue."
	
	Str_BASECHECKMD5PRINT_Hash_Not_Match="The Base Data archive hash sum does not match the value specified in the settings!"
	Str_BASECHECKMD5PRINT_Hash_Not_Match2="The files may have been copied with errors or modified! Be careful!"
	Str_BASECHECKMD5PRINT_Expected_bHash="Expected MD5 hash of \"Base Data\":"
	Str_BASECHECKMD5PRINT_Real_bHash="Real MD5 hash of \"Base Data\":"
	
	Str_CHECKLAST_BUI_DebianStretch="Application menu does not work correctly in Debian 9!\n   New shortcuts may not be displayed!"
	
	Str_PACKAGEINFO_Head="Software Info:"
	Str_PACKAGEINFO_Name="Name:"
	Str_PACKAGEINFO_ReleaseDate="Release Date:"
	Str_PACKAGEINFO_Category="Category:"
	Str_PACKAGEINFO_Platform="Platform (tested):"
	Str_PACKAGEINFO_InstalledSize="Installed Size:"
	Str_PACKAGEINFO_Licensing="Licensing:"
	Str_PACKAGEINFO_Maintainer="Package creator:"
	Str_PACKAGEINFO_Developer="Developer:"
	Str_PACKAGEINFO_URL="URL:"
	Str_PACKAGEINFO_Description="Description:"
	Str_PACKAGEINFO_CurrentOS="Current OS:"
	Str_PACKAGEINFO_InstallMode="Installation Mode:"
	Str_PACKAGEINFO_Confirm="Start the application installation process? Enter \"y\" or \"yes\" to confirm."
	
	Str_CHECKMD5PRINT_Head="Integrity check:"
	Str_CHECKMD5PRINT_Hash_Not_Match="The archives hash sum does not match the value specified in the settings!"
	Str_CHECKMD5PRINT_Hash_Not_Match2="The files may have been copied with errors or modified! Be careful!"
	Str_CHECKMD5PRINT_Expected_pHash="Expected MD5 hash of \"Program Files\":"
	Str_CHECKMD5PRINT_Expected_sHash="Expected MD5 hash of \"System Files\":"
	Str_CHECKMD5PRINT_Real_pHash="Real MD5 hash of \"Program Files\":"
	Str_CHECKMD5PRINT_Real_sHash="Real MD5 hash of \"System Files\":"
	Str_CHECKMD5PRINT_yes_To_Continue="Enter \"y\" or \"yes\" to continue installation (not recommended):"
	Str_CHECKMD5PRINT_Enter_To_Continue="Press Enter to continue."
	Str_CHECKMD5PRINT_Verified="The integrity of the installation archive has been successfully verified"
	
	Str_CHECKMD5_Head="Checking archives integrity:"
	Str_CHECKMD5_Sub_Head="Checking the integrity of the installation archives, please wait..."
	Str_CHECKMD5_Sub_Head2="(this may take some time if the application is large)"
	
	Str_PRINTINSTALLSETTINGS_Head="Installation settings:"
	Str_PRINTINSTALLSETTINGS_Temp_Dir="Temporary Directory:"
	Str_PRINTINSTALLSETTINGS_App_Inst_Dir="Application install Directory:"
	Str_PRINTINSTALLSETTINGS_Menu_Dirs="Menu files will be installed to:"
	Str_PRINTINSTALLSETTINGS_Bin_Dir="Bin files will be installed to:"
	Str_PRINTINSTALLSETTINGS_System_Mode="Root rights are required to perform the installation!"
	Str_PRINTINSTALLSETTINGS_Before_Install="Please close all important applications before installation."
	Str_PRINTINSTALLSETTINGS_Confirm="Enter \"y\" or \"yes\" to begin the installation."
	Str_PRINTINSTALLSETTINGS_Helpers_Dir="Helper files will be installed to:"
	Str_PRINTINSTALLSETTINGS_Desktop_Dir="Desktop shortcuts will be installed to:"
	
	Str_PREPAREINPUTFILES_Err_Unpack="Error unpacking temp files:"
	Str_PREPAREINPUTFILES_Err_Unpack2="Try copying the installation files to another disk before running."
	
	Str_CHECKOUTPUTS_Head="Checking output directories:"
	Str_CHECKOUTPUTS_Already_Present="Folders|Files already present"
	Str_CHECKOUTPUTS_Attention="Continue installation and overwrite directories/files?"
	Str_CHECKOUTPUTS_Attention2="Please make a backup copy of your data in the above directories."
	Str_CHECKOUTPUTS_Confirm="Enter \"y\" or \"yes\" to continue."
	
	Str_INSTALLAPP_Head="Installing..."
	Str_INSTALLAPP_No_Rights="No rights to the application installation directory?"
	Str_INSTALLAPP_Create_Out="Creating output folder if it does not exist..."
	Str_INSTALLAPP_Unpack_App="Unpacking application files..."
	Str_INSTALLAPP_Unpack_Err="Error unpacking program files..."
	Str_INSTALLAPP_Unpack_Err2="Broken archive? Or symbolic links with absolute paths as part of an application?"
	Str_INSTALLAPP_Unpack_Err_Continue="Enter \"y\" or \"yes\" to continue the installation process..."
	Str_INSTALLAPP_Unpack_Err_Abort="At the stage of unpacking program files."
	Str_INSTALLAPP_Unpack_Continue="The installation continues..."
	Str_INSTALLAPP_Set_Rights="Setting rights and owner..."
	Str_INSTALLAPP_Install_Bin_Menu="Installing Bin files and copy menu files..."
	
	Str_CHECKSYSDE_NotFound="Not found..."
	Str_CHECKSYSDE_XDG_INFO_INCORRECT="The distribution did not provide correct information via the \"XDG\" variables..."
	Str_CHECKSYSDE_DE_CHECK="DE Check"
	Str_CHECKSYSDE_DE_WEIRD="Weird DE"
	Str_CHECKSYSDE_DE_WEIRD_OPENBOX="This DE may not follow XDG specifications!\n    The installer is not designed to work with the specific structure of the OpenBox menu."
	Str_CHECKSYSDE_DE_WEIRD_SWAY="What the hell..."
	Str_CHECKSYSDE_DE_WEIRD_LXQT="Re-login to the system if new shortcuts do not appear in the menu!"
	Str_CHECKSYSDE_DE_WEIRD_BUDGIE="New shortcuts may not appear in the menu..."
	Str_CHECKSYSDE_DE_WEIRD_GNOME="The menu doesn't match XDG specifications very well...\n    Re-login to the system if new shortcuts do not appear in the menu!"
	
	Str_CHECK_ERRORS_ARCH="Attention!"
	Str_CHECK_ERRORS_ARCH_WARN="The system architecture ($Current_Architecture) does not match the selected tools architecture ($Tools_Architecture)!"
}

function _SET_LOCALE() { # -= (7) =-
	local Language="${LANG%%.*}"
	local Locale_File="$Path_To_Script/locales/$Language"
	
	_SET_LOCALE_DEFAULT
	if [ "$MODE_SILENT" == "false" ]; then
		if [ -e "$Locale_File" ]; then
			if [ "$(grep Locale_Version "$Locale_File")" == "Locale_Version=\"$LocaleVersion\"" ]; then
				Locale_Use_Default="false"
				Locale_Display="$Language"
				source "$Locale_File"
			fi
		fi
	else Locale_Display="-silent"; fi
	
	Header="-=: Universal Software Installer Script for Chimbalix (Installer-SH v$ScriptVersion) - Lang: $Locale_Display :=-"
	Header="${Font_DarkYellow}${Font_Bold}${Header}${Font_Reset}${Font_Reset_Color}\n"
}

######### ---- --------- ---- #########
######### -- END FUNCTIONS -- #########
######### ---- --------- ---- #########

## START ##

_MAIN

if [ "$MODE_DEBUG" == "true" ]; then
	echo "$Str_WARNING"
	echo "$pause"
	echo "$Current_OS_Name_Full"
	echo "$Current_OS_Name"
	echo "$Current_OS_Name_ID"
	echo "$Current_OS_Version"
	echo "$Current_OS_Codename"
	read -r pause
fi

## End ##

# MIT License
#
# Copyright (c) 2025 Chimbal
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
