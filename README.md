# movr

[![Build Status](https://travis-ci.org/caesar0301/movr.svg)](https://travis-ci.org/caesar0301/movr)

Human mobility data analysis and visualization in R.

## Dependencies

    > sudo apt-get install cmake pkg-config libglib2.0-dev

On Mac OS X

    > brew install cmake pkg-config glib

## Install

You can install the library from CRAN

```R
install.packages('movr')
```

Or install the development version from GitHub

```R
install.packages("devtools")
devtools::install_github("caesar0301/movr")
```

## Visualization

This package provides a suit of very useful utilities to analyze human
spatio-temporal mobility data.

* `draw_mobility3d`

![draw_mobility3d_example](https://raw.githubusercontent.com/caesar0301/movr/master/examples/mobility3d.png)

* `draw_flowmap`

![draw_flowmap_example](https://raw.githubusercontent.com/caesar0301/movr/master/examples/flowmap.png)

## Bug Report

* https://github.com/caesar0301/movr/issues

## Author

© Xiaming Chen - chenxm35@gmail.com
