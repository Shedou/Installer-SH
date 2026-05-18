## Installer-SH

https://github.com/Shedou/Installer-SH

https://github.com/Shedou/Chimbalix-Software-Catalog

The version and hints are in the file "installer.sh".

### Usage:

Normal installation, just run:

> `./installer.sh`

Help (list of all available commands):

> `./installer.sh -h`\
> `./installer.sh -help`\
> `./installer.sh --help`

Silent installation, no output if everything is installed without errors:

> `./installer.sh -silent`

### Extracting:

TAR extract:

> `tar -xf Installer-SH.tar`

## For developers/packagers

Brief instructions for initial packaging of the program in Installer-SH format.

Important! These instructions are designed for manual application packaging! If you need to automate the process of packaging and updating software in Installer-SH format, you will need to develop your own scripts. Much is already automated using Installer-SH's startup arguments; check out the built-in help by running "`installer.sh -h`"...

After the initial creation of the installation package with the program, further updates of the program can be carried out by simply replacing files in the "program_files/program" directory and changing the versions in the main "installer.sh" script.

### Directory "installer-data/program_files":

1) Prepare the program. Make sure the program is working properly.
2) Copy the program files to the "program" directory.
3) Configure the settings in the "launcher" file.
4) Change the icons in the "icons" directory to match the program.

* If the program has 2 or more executable files, copy and configure launchers for each executable file.

* If the program requires files in the user's home directory to function correctly, place these files in the "userdata" directory and set the `ISHMoveHomeDir="true"` parameter in the launcher settings.

* If the program requires specific libraries to work, which are not in the program itself, they can be placed in the "libs" directory and set the parameter `UseExtraLibs="true"` in the launcher.

### Directory "installer-data/system_files":

1) Configure the shortcuts in the "`desktop`" directory.
2) Configure the shortcuts in the "`menu/apps/UNIQUE_APP_FOLDER_NAME`" directory. Don't touch the "`...open-folder.desktop`" and "`...uninstall.desktop`" shortcuts unless necessary.

* XFCE only: Configure helpers in the "`xfce4/helpers`" directory if the program needs to be integrated into the system. These files will not be used unless they are enabled by a setting in the main "`installer.sh`" script.

* If the program needs additional sections in the menu, configure files in the "`menu/applications-merged`" and "`menu/desktop-directories/apps/UNIQUE_APP_FOLDER_NAME`" directories.

* Do not remove keywords such as "`PATH_TO_FOLDER`," "`ADDITIONAL_CATEGORIES`," and "`UNIQUE_APP_FOLDER_NAME`" unless necessary. You can add custom text to the unique keywords "`PROGRAM_NAME_IN_MENU`" if necessary: ​​"`PROGRAM_NAME_IN_MENU` - Run in safe mode..."

* If the program has two or more launch options using arguments, copy the shortcut and add a unique identifier to the filename, for example: "`UNIQUE_APP_FOLDER_NAME-uniqueID.desktop`" Customize the new shortcuts to match the program.

### Configuration of the main file "installer.sh":

1) Follow the comments (hints) in the SETTINGS section to configure the installation package!
2) Configure the "`Tools_Architecture`" and "`Program_Architecture`" parameters according to the target operating system and program.
3) Do not touch the "`Install_Mode`" and "`Install_Configs`" parameters unless necessary.
4) Important! Configure the "`Unique_App_Folder_Name`" parameter to match the program name and version!
5) In the "`Package Information`" section, you need to specify information about the program.
6) Don't forget to edit the program description in the localization files inside the "`locales`" directory.
7) In the "`Basic Menu File Settings`" section, configure the "`Additional_Categories`" parameter.
8) In the "`Archive packaging parameters`" section, select the appropriate format and compression parameters.

* The "`Install_Mode_CFG_Skip`" and "`Install_Configs_CFG_Skip`" parameters can be used to remove sections for configuring the installation mode and storing configuration files from the user interface.

### When everything is prepared:

1) Manually delete the old archives "`installer-data/program_files.7z`" and "`installer-data/system_files.7z`".
2) Pack the new archives using the command: `./installer.sh -apk` or `./installer.sh -arcpack`
3) Thoroughly test the installation package by running "`installer.sh`" and installing the program.
4) If any errors are found in the shortcuts or installation package parameters, fix the issues and return to step 1.
5) If everything is done correctly, you can clean up any junk using the command: `./installer.sh -clean` or `./installer.sh -cln`
6) To create a distributable tar archive, use the command: `./installer.sh -tpk` or `./installer.sh -tarpack`. The tar archive will be created next to the installation package directory.

* If you need to update the program, unpack the archives in the installer-data directory, update the necessary files, and run the packing and cleaning procedure again. Don't forget to change the versions in the main "`installer.sh`" file.

### General recommendations

- When providing program information, make sure the text doesn't mix Cyrillic and Latin characters, for example: Game10с-10mp and Game10c-10mp. Visually, they're identical, but the first version uses the Cyrillic "с" symbol. Mixing is bad form. Some Linux distributions are too broken out of the box to handle Cyrillic text.

- Whenever possible, include the program name, version, and architecture in the name of the distributed installation package. It is also recommended to include the installation package version in the format 'ISH27'. This will allow installation packages to be located in one directory without name conflicts and will simplify the selection of the required option from the list of available ones.
