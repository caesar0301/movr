# movr

[![Build Status](https://travis-ci.org/caesar0301/movr.svg)](https://travis-ci.org/caesar0301/movr)

Human mobility data analysis and visualization in R.

## Dependencies

On Ubuntu

    > sudo apt-get install cmake pkg-config libglib2.0-dev

On Mac OS X

    > brew install cmake pkg-config glib
    
## Install

Currently only support installation from Github:

```R
install.packages(c('devtools', 'dplyr', 'tidyr', 'data.table', 'geosphere', 'deldir', 'RColorBrewer', 'igraph'))
devtools::install_github("caesar0301/movr")
```

## Visualization

This package provides a suit of very useful utilities to analyze human
spatio-temporal mobility data.

* `plot.traj3d` (`voronoi3d`)

![draw_mobility3d_example](https://raw.githubusercontent.com/caesar0301/movr/master/examples/mobility3d.png)

* `plot.flowmap` (using mobile data from Senegal, [D4D challenge 2014](http://www.d4d.orange.com/en/Accueil))

![draw_flowmap_example](https://raw.githubusercontent.com/caesar0301/movr/master/examples/flowmap.png)

* `map3d` (3d map layer for `rgl` package)

![map3d_example](https://raw.githubusercontent.com/caesar0301/movr/master/examples/map3d-rgl.png)


## Bug Report

* https://github.com/caesar0301/movr/issues

## Author

© Xiaming Chen - chenxm35@gmail.com
