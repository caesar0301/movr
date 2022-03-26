#!/bin/bash
set -e

PKG_ROOT=`dirname $0`

if [ -e ${PKG_ROOT}/build ]; then
rm -rf ${PKG_ROOT}/build
fi
mkdir ${PKG_ROOT}/build

cd ${PKG_ROOT}/build && cmake .. && make && cd -

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;libname=libmovr.so;;
    Darwin*)    machine=Mac;libname=libmovr.dylib;;
    CYGWIN*)    machine=Cygwin;libname=libmovr.dll;;
    MINGW*)     machine=MinGw;libname=libmovr.dll;;
    *)          machine="UNKNOWN:${unameOut}"
esac
echo "Machine platform: ${machine}"

if [ ! -e ${PKG_ROOT}/build/${libname} ]; then
echo "Error: Shared lib not built, exit" && exit 1
fi

# Inform useDynLib search path
cp ${PKG_ROOT}/build/${libname} ${PKG_ROOT}/src/${libname}

echo "Run R CMD check"
R CMD check ${PKG_ROOT}

echo "Run movr examples"
echo "library(devtools); run_examples(); install()" | R --no-save