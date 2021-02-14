@ECHO OFF
clang.exe -O3 -Wl,/STACK:reserve=1048576 -Wno-override-module -o mplc.exe mplc.ll
