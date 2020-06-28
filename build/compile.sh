#!/bin/bash

SOURCE_VERSION=$(git log --date=format:%y%m%d --format=%cd -1)

mplc -D COMPILER_SOURCE_VERSION=$SOURCE_VERSION -I ../sl -ndebug -o mplc.ll ../main.mpl
