## Installer-SH

The current repository is for active development of Installer-SH, it contains the latest version of the installation package, however it may be unstable.

Stable and archive versions are located in the "[Installer-SH-Archive](https://github.com/Shedou/Installer-SH-Archive)" repository.

Applications packaged in Installer-SH format can be found in the "[Chimbalix-Software-Catalog](https://github.com/Shedou/Chimbalix-Software-Catalog)" repository.

## Features of Installer-SH:

* Ease of use: Installer-SH does not require root rights to install programs, just confirm the installation several times to install the application.

* Reliability and autonomy: The installation package is designed for autonomous installation of applications, which means it is suitable for use on computers without Internet access.

* Backward compatibility: Installer-SH works starting with Debian 7 (Linux Kernel 3.2+), the installation package mainly uses GNU tools (https://www.gnu.org/software/software.html) and the 7-Zip archiver (https://7-zip.org, built into the package). Attention! Compatibility of programs packed in the Installer-SH format is on the conscience of the developer.

* Different versions: The installation package was developed with the expectation of installing a variety of user applications, including different versions of the same program.

* Easily updatable and flexible: Usually the installation package is intended for distribution of one specific version of the application, but it is possible to pack several different programs in one package, or different versions of the same program, at the discretion of the packer. The installation package does not limit the developer in the available methods of updating the application. Multiple installation of the program is possible, a warning will be displayed about overwriting existing files, this allows the developer to create one package in the Installer-SH format under a unique name, and simply update it, already installed applications can be updated using the methods built into the application.

* Standardized: The installation package follows the PortSoft specifications (https://github.com/Shedou/PortSoft) for applications, and the XDG Desktop specifications (https://specifications.freedesktop.org) for menu shortcut placement. Additionally, Installer-SH itself can prepare the PortSoft directory according to the specification on Linux distributions that do not support these specifications out of the box.

* Excellent compression: Thanks to the 7-Zip archiver, the advantage of Installer-SH over AppImage can reach 80% or more, depending on the type of compressed data, size and parameters, the advantage over tar.xz can reach 10% or more, depending on the compressed data, size and parameters.

* Silent mode (v2.3+): It is possible to mass install several programs in Installer-SH format with the "-silent" parameter, for more information read the help, run "installer.sh" with the "-h" parameter to call the help.
