# movr

Human mobility data analysis and visualization in R.

## Prerequisites

On Ubuntu

    > sudo apt-get install cmake pkg-config libglib2.0-dev

On Mac OS X

    > brew install cmake pkg-config glib
    
## Install

1. Install dependencies

```R
# for pkg installation
install.packages('devtools')

# for movr
install.packages(c('dplyr', 'tidyr', 'data.table', 'geosphere', 'deldir', 'RColorBrewer', 'igraph'))
```

2. Install movr

a. From github

```R
library(devtools)
install_github("caesar0301/movr")
```

b. From source code

```bash
# Build C source
./configure

# Check package compliance
R CMD check .

# Install
echo "library(devtools); run_examples(); install()" | R --no-save
```

## Visualization

`movr` provides a suit of useful utilities to analyze human spatio-temporal mobility data.

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
