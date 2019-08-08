#!/bin/bash

SOURCE_VERSION=$(git log --date=format:%y%m%d --format=%cd -1)

mplc -D COMPILER_SOURCE_VERSION=$SOURCE_VERSION -D DEBUG=TRUE -ndebug -o mplc.ll\
 ../astNodeType.mpl\
 ../astOptimizers.mpl\
 ../builtinImpl.mpl\
 ../builtins.mpl\
 ../codeNode.mpl\
 ../debugWriter.mpl\
 ../defaultImpl.mpl\
 ../irWriter.mpl\
 ../main.mpl\
 ../parser.mpl\
 ../pathUtils.mpl\
 ../printAST.mpl\
 ../processor.mpl\
 ../processorImpl.mpl\
 ../processSubNodes.mpl\
 ../staticCall.mpl\
 ../variable.mpl\
 ../sl/ascii.mpl\
 ../sl/Array.mpl\
 ../sl/control.mpl\
 ../sl/conventions.mpl\
 ../sl/file.mpl\
 ../sl/HashTable.mpl\
 ../sl/memory.mpl\
 ../sl/Owner.mpl\
 ../sl/String.mpl\
 ../sl/Variant.mpl
