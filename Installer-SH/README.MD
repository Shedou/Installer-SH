## Installer-SH

https://github.com/Shedou/Chimbalix-Software-Catalog

The version and hints are in the file "install.sh".

### Usage:

Normal installation, just run:

> `./installer.sh`

Help:

> `./installer.sh -h`\
> `./installer.sh -help`\
> `./installer.sh --help`

Silent installation, no output if everything is installed without errors:

> `./installer.sh -silent`

Pack the directory with installation files into a TAR archive::

> `./installer.sh -tarpack`

Disables automatic menu update after installation.\
Recommended for use when batch installing multiple applications in "-silent" mode.

> `./installer.sh -noupdmenu`

Only refresh menu. Recommended to use after installing many applications in "-silent" mode.\
Works if the working environment is supported.

> `./installer.sh -forcemenu`

### Creating installation packages (v1.7):

1) Delete all unnecessary example files in the "program_files" directory except "ish-software-uninstaller.sh" and "ish-software-uninstaller-icon.png", and also delete the archives in the "installer-data" directory.
2) The "user_files" directory should be deleted if it is not needed.
3) Place the application files in the "program_files" directory.
4) Configure files according to the application in the directory "system_files".
5) Then configure the "install.sh" file and fill in the application information.
6) Checking that everything worked correctly.
7) Pack the archives using "pack_archives.sh", you can also set the compression level in this file.
8) If everything is correct, in the "installer-data" directory, delete everything except the "tools" folder and the "program_files.7z / system_files.7z" archives
9) Checking that everything worked correctly.
10) If a problem is found, come back and fix it.

### Extra:

TAR extract:

> `tar -xf Installer-SH.tar`
