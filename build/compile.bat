@ECHO OFF

FOR /F "tokens=*" %%v IN ('git log --date^=format:%%y%%m%%d --format^=%%cd -1') DO SET SOURCE_VERSION=%%v

mplc.exe -D COMPILER_SOURCE_VERSION=%SOURCE_VERSION% -D DEBUG=FALSE -D DEBUG_MEMORY=TRUE -I ../sl -call_trace 0 -debug_memory -ndebug -o mplc.ll ../main.mpl
