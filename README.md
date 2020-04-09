# MPL "Fast" Compiler

MPL (previously MPL/Fast) is a programming language in active development since 2006.
This repository contains a self-hosted MPL compiler.

## Building

Because the MPL Compiler is self-hosted, you cannot build it without MPL Compiler.
To help with bootstrapping, we provide precompiled `mplc.ll` files, see [releases](https://github.com/Matway/mpl-c/releases).

### Prerequisites

* `mplc` - MPL Compiler binary
* `clang` - We use Clang binary as the single-entry LLVM optimizer and linker, it is possible to replace it with llvm-opt and a linker of your choice

Make sure both binaries are accessible with your path settings. For example, `/usr/bin/mplc` on Linux, or `%USERPROFILE%\mpl\mplc.exe` on Windows (you will need to add this folder to your user paths).

### Build process

* Go to the `build` folder
* Execute the platform-specific build script, `build.bat` on Windows and `build.sh` on Linux. This will call both compile and link scripts, which produce LLVM IR (mplc.ll) and the resulting binary. If you are bootstrapping from the precompiled `mplc.ll` file, you can execute the link script, `link.bat` on Windows and `link.sh` on Linux

## Usage

Please execute `mplc` to see the usage documentation.

## Documentation

Documentation is a work in progress.
