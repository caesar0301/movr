#!/bin/bash

PKG=`dirname $0`

rm -rf $PKG/_builds $PKG/_install $PKG/man $PKG/..RCheck

R CMD check $PKG
# cp $pkg.Rcheck/movr-manual.pdf $PKG
# echo "install.packages('devtools')" | R --no-save
echo "library(devtools); run_examples(); install()" | R --no-save
