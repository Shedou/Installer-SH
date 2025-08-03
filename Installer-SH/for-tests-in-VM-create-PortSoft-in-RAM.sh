#!/usr/bin/env bash
RAMSize="4G"
RAMSizeUser=""

PortSoftDir="$HOME/portsoft"

confirmation=""

echo -e "
 WARNING! Use this only in a virtual machine!

 This script creates a PortSoft directory by mapping the file system to RAM!

 This is necessary for testing applications larger than 500 MiB,
  as some Linux distributions leave too little free space for the file system
  in Live-CD mode.
 
 Enter \"y\" or \"yes\" to continue!"

read -r confirmation

if [ "$confirmation" == "y" ] || [ "$confirmation" == "yes" ]; then
	echo -e "
 Current filesystem size for PortSoft directory = $RAMSize.

 Press Enter to continue, or enter a new value in 2G, 4G, 6G, 8G format.
 Incorrectly entered value may lead to errors."
 	
	read -r RAMSizeUser
	if [ "$RAMSizeUser" != "" ]; then RAMSize="$RAMSizeUser"; fi
	
	if [ -e "$PortSoftDir" ]; then
		echo -у "
 ATTENTION! PortSoft directory already exists!
 The existing directory will be renamed before creating the new one!

 Enter \"y\" or \"yes\" to continue!"
 		
		read -r confirmation
		if [ "$confirmation" == "y" ] || [ "$confirmation" == "yes" ]; then
			mv "$PortSoftDir" "$PortSoftDir-$RANDOM"
			mkdir "$PortSoftDir"
			sudo mount -o size="$RAMSize" -t tmpfs none "$PortSoftDir"
		fi
	else
		mkdir "$PortSoftDir"
		sudo mount -o size="$RAMSize" -t tmpfs none "$PortSoftDir"
	fi
fi

echo "end."
read -r confirmation

