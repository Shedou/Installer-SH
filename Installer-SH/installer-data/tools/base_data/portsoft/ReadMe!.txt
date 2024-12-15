Chimbalix "portsoft" directory v0.3

-= BASIC RULES =-

1) Portable independent software is preferred.

2) Directory Structure:
/PORTSOFT_FOLDER / ARCHI_FOLDERS / program_folder

PORTSOFT_FOLDER - Main folder.
ARCHI_FOLDERS - Software "categories", for example x86/x86_64/script/other.
program_folder - Folder with a specific program, for example ChimbaBench.

-= SYSTEM =-

- System side PORTSOFT_FOLDER and ARCHI_FOLDER:
Path: /portsoft
Path: /portsoft/ARCHI_FOLDER
Rights: 755 (root read/write, others read-only)
Owner-group: root:root

- System side program_folder:
Path: /portsoft/ARCHI_FOLDER/program_folder
Rights: 755
Owner-group: root:root
!!! At the discretion of the software developer/packer, it is possible to set other access rights to the application directory, or internal directories if necessary.

-= USER =-

- User side PORTSOFT_FOLDER and ARCHI_FOLDERS:
Path: /home/USERNAME/portsoft
Path: /home/USERNAME/portsoft/ARCHI_FOLDERS
Owner and rights: Not specified

-= ======== =-
-= Examples =-

-- Folder for x86 (32-bit) software:
/portsoft/x86

-- Folder for x86_64 (64 bit) software:
/portsoft/x86_64
e.g.
/portsoft/x86_64/ChimbaBench_v26_Linux_x64/ChimbaBench.exec

-- Folder for scripts and software without executable binaries:
/portsoft/script
e.g.
/portsoft/script/python_thing/main.py
/portsoft/script/bash_thing/change_bg.sh

-- Folder for other non-software things:
/portsoft/other
e.g.
/portsoft/other/very_nice_icon_pack_v11/purple/some_purple_icons.png
I don't know, think of something...

-- Folder for other architectures (must be created by the distribution developer for a specific platform):
/portsoft/armhf
/portsoft/arm64
/portsoft/riscv
and so on...


- Changelog:
 -= v0.3 =-
 Removed ".local" from portsoft user directory path, the dot could cause problems with some applications.
