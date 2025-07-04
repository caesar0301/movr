#!/bin/bash
echo "Building native code"
./configure

echo "Check package"
R CMD check .

echo "Regenerate documents with enhanced NAMESPACE generation"
Rscript render_docs.R

echo "Build package"
R CMD build .

echo "Do release to CRAN"
R --no-save -e "library(devtools);spell_check();release()"