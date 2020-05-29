@ECHO OFF

FOR /F "tokens=*" %%v IN ('git log --date^=format:%%y%%m%%d --format^=%%cd -1') DO SET SOURCE_VERSION=%%v

mplc.exe -D COMPILER_SOURCE_VERSION=%SOURCE_VERSION% -D DEBUG=FALSE -D DEBUG_MEMORY=TRUE -call_trace 0 -debug_memory -ndebug -o mplc.ll^
 ../astNodeType.mpl^
 ../astOptimizers.mpl^
 ../Block.mpl^
 ../builtinImpl.mpl^
 ../builtins.mpl^
 ../codeNode.mpl^
 ../debugWriter.mpl^
 ../declarations.mpl^
 ../defaultImpl.mpl^
 ../File.mpl^
 ../irWriter.mpl^
 ../main.mpl^
 ../Mref.mpl^
 ../NameManager.mpl^
 ../parser.mpl^
 ../pathUtils.mpl^
 ../processor.mpl^
 ../processorImpl.mpl^
 ../processSubNodes.mpl^
 ../schemas.mpl^
 ../staticCall.mpl^
 ../Var.mpl^
 ../variable.mpl^
 ../sl/Array.mpl^
 ../sl/ascii.mpl^
 ../sl/control.mpl^
 ../sl/conventions.mpl^
 ../sl/file.mpl^
 ../sl/HashTable.mpl^
 ../sl/memory.mpl^
 ../sl/Owner.mpl^
 ../sl/String.mpl^
 ../sl/Variant.mpl
