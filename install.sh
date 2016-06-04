#!/bin/bash

PKG=`dirname $0`

rm -rf $PKG/_builds $PKG/_install $PKG/man $PKG/..RCheck

R CMD check $PKG
cp $pkg.Rcheck/movr-manual.pdf $PKG
echo "library(devtools); check_doc(); install()" | R --no-save
