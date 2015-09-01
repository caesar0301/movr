#!/bin/bash

base=`dirname $0`

R CMD Rd2pdf -o movr.pdf $base
R CMD check --as-cran $base

# generate namespace: roxygen2::roxygenise()
# update man: dplyr::document()
# check: dplyr::check()

rm -rf $base/..Rcheck