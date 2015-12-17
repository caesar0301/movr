#!/bin/bash

pkg=`dirname $0`
R CMD check $pkg
cp $pkg.Rcheck/movr-manual.pdf $pkg
echo "library(devtools); check_doc(); install()" | R --no-save
