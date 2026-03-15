## Installer-SH [![Github Releases](https://img.shields.io/github/downloads/Shedou/Installer-SH/total.svg)](https://github.com/Shedou/Installer-SH/releases)

The current repository is for active development of Installer-SH, it contains the latest version of the installation package, however it may be unstable.

Stable and archived versions are available on the [downloads page](https://github.com/Shedou/Installer-SH/releases) or in the "[Installer-SH-Archive](https://github.com/Shedou/Installer-SH-Archive)" repository.

Applications packaged in Installer-SH format can be found in the "[Chimbalix-Software-Catalog](https://github.com/Shedou/Chimbalix-Software-Catalog)" repository.

## Features of Installer-SH:

* Ease of use: Installer-SH does not require root rights to install programs, just confirm the installation several times to install the application.

* Reliability and autonomy: The installation package is designed for autonomous installation of applications, which means it is suitable for use on computers without Internet access.

* Backward compatibility: Installer-SH works starting with Debian 7 (Linux Kernel 3.2+), the installation package mainly uses GNU tools (https://www.gnu.org/software/software.html) and the 7-Zip archiver (https://7-zip.org, built into the package). Attention! Compatibility of programs packed in the Installer-SH format is on the conscience of the developer.

* FreeBSD support: Starting with Installer-SH 2.6, FreeBSD support has been added.

* Different versions: The installation package was developed with the expectation of installing a variety of user applications, including different versions of the same program.

* Easily updated and flexible: The installation package is designed to distribute one specific version of the application, but it is possible to pack several different programs, or different versions of the same program, at the discretion of the packer. Multiple installations of the program are possible, a warning will be displayed about overwriting existing files, this allows the developer to create one package in the Installer-SH format under a unique name, and simply update the archive with the application files.

* Standardized: The installation package follows the PortSoft specifications (https://github.com/Shedou/PortSoft) for applications, and the XDG Desktop specifications (https://specifications.freedesktop.org) for menu shortcut placement. Additionally, Installer-SH itself can prepare the PortSoft directory according to the specification on Linux distributions that do not support these specifications out of the box.

* Excellent compression: Thanks to the 7-Zip archiver, the advantage of Installer-SH over AppImage can reach up to 80% or more, depending on the type of compressed data, size and parameters, the advantage over tar.xz can reach up to 10% or more, depending on the compressed data, size and parameters.

* Silent mode (v2.3+): It is possible to mass install several programs in Installer-SH format with the "-silent" parameter, for more information read the help, run "installer.sh" with the "-h" parameter to call the help.

## License Installer-SH
```
MIT License

Copyright (c) 2024-2026 Андрей Цымбалов (Chimbal)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## License 7-Zip
Detailed information about the 7-Zip license can be found in the file at "Installer-SH/installer-data/tools/7zip/License.txt"
```
  ~~~~~~~~~~~~~~~~~~~~~~~~~
  License for use and distribution
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  7-Zip Copyright (C) 1999-2024 Igor Pavlov.

  The licenses for 7zz and 7zzs files are:

         - The "GNU LGPL" as main license for most of the code
         - The "GNU LGPL" with "unRAR license restriction" for some code
         - The "BSD 3-clause License" for some code
         - The "BSD 2-clause License" for some code

  Redistributions in binary form must reproduce related license information from this file.

  Note:
    You can use 7-Zip on any computer, including a computer in a commercial
    organization. You don't need to register or pay for 7-Zip.
```
