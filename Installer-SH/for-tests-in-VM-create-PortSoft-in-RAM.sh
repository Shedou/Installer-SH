#!/usr/bin/env bash

### !!! Please configure this setting as required !!! ###
### The correct format is: 512M, 1024M, 2G, 4G, 8G... ###
RAMSize="2G" # Default is 2 GiB (1 GiB = 1024 MiB)


PortSoftDir="$HOME/portsoft"
confirmation=""; choice=""

function mount_dir() {
	if sudo mount -o size="$RAMSize" -t tmpfs none "$PortSoftDir"; then
		echo -e "$PortSoftDir - mounted in RAM."
	else
		echo -e " Mount error: Make sure you have full sudo privileges and the correct \"RAMSize\" variable is specified."; exit 1
	fi
}

function create_dir() {
	if mkdir "$PortSoftDir"; then
		echo -e " $PortSoftDir - created.\n"
	else
		echo -e " Need root rights... Try with sudo:\n"
		if sudo mkdir "$PortSoftDir"; then
			echo -e " $PortSoftDir - created.\n"
		else
			echo -e " Error: Failed to create directory \"$PortSoftDir\". Make sure you have all necessary permissions to create the directory."
			exit 1
		fi
	fi
}

echo -e "
 WARNING! Use this only in a virtual machine!

 This script creates a PortSoft directory by mapping the file system to RAM!
 A file system of the following size will be created: $RAMSize
 If necessary, change this value by editing this script.

 This is necessary for testing applications larger than 500 MiB,
  as some Linux distributions leave too little free space for the file system
  in Live-CD mode.
 
 Enter \"y\" or \"yes\" to continue, or \"u\" to unmount the mounted directory."

read -r choice

if [ "$choice" == "y" ] || [ "$choice" == "yes" ]; then
	echo -e "\n Current filesystem size for PortSoft directory = $RAMSize."
	
	if [ -e "$PortSoftDir" ]; then
		echo -у "
 ATTENTION! PortSoft directory already exists!
 The existing directory will be mounted!
 Old files will be inaccessible until the file system is mounted in RAM!
 To access old files, please unmount the mounted directory.
 This can be done by re-running this script and selecting the \"u\" parameter.

 Enter \"y\" or \"yes\" to continue!"
		read -r confirmation
		if [ "$confirmation" == "y" ] || [ "$confirmation" == "yes" ]; then
			mount_dir
		fi
	else
		create_dir
		mount_dir
	fi
fi

if [ "$choice" == "u" ]; then
	if sudo umount "$PortSoftDir"; then
		echo -e "$PortSoftDir - successfully unmounted and freed from memory."
	else
		echo -e " Error while unmounting..."; exit 1
	fi
fi

echo "End (pause)"
read -r confirmation

