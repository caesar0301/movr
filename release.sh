#!/bin/bash
echo "Building native code"
./configure

echo "Check package"
R CMD check .

echo "Regenerate documents"
R --no-save -e "library(devtools);document(roclets=c('collate','namespace','rd'))"

echo "Build package"
R CMD build .

echo "Do release to CRAN"
R --no-save -e "library(devtools);spell_check();release()"