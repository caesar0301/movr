.. movr documentation master file, created by
   sphinx-quickstart on Wed Aug 31 15:42:36 2016.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

movr: Human Mobility Analysis in R
==================================

**Analyzing and Visualizing Human Mobility Data in R**

`movr` is an R package that provides comprehensive tools for analyzing and visualizing spatio-temporal human mobility data. It originates from research on human mobility patterns and offers general transformation, calculation, and visualization utilities for mobility analysis.

.. image:: https://www.r-pkg.org/badges/version/movr
   :target: https://cran.r-project.org/package=movr
   :alt: CRAN status

.. image:: https://github.com/caesar0301/movr/workflows/CRAN%20Release%20Check/badge.svg
   :target: https://github.com/caesar0301/movr/actions
   :alt: R-CMD-check

.. image:: https://img.shields.io/badge/License-MIT-yellow.svg
   :target: https://opensource.org/licenses/MIT
   :alt: License: MIT

.. image:: https://img.shields.io/badge/DOI-10.1016%2Fj.pmcj.2017.02.001-blue.svg
   :target: https://doi.org/10.1016/j.pmcj.2017.02.001
   :alt: DOI

Installation
-----------

From CRAN (Recommended):

.. code-block:: r

   install.packages("movr")

From GitHub (Development Version):

.. code-block:: r

   # Install devtools if you haven't already
   if (!requireNamespace("devtools", quietly = TRUE)) {
     install.packages("devtools")
   }

   # Install movr from GitHub
   devtools::install_github("caesar0301/movr")

Quick Start
----------

.. code-block:: r

   # Load the package
   library(movr)

   # Load example data
   data(movement)

   # Basic trajectory visualization
   plot_traj3d(movement, x = "lon", y = "lat", z = "timestamp")

   # Create a flow map
   flowmap_data <- flowmap(movement, from = "origin", to = "destination")
   plot_flowmap(flowmap_data)

Features
--------

* **3D Trajectory Visualization**: Interactive 3D plots of mobility trajectories
* **Flow Maps**: Visualize population movements and migration patterns
* **Spatial Analysis**: Voronoi tessellation, spatial correlation, and coverage analysis
* **Temporal Analysis**: Time-of-day patterns, session generation, and temporal entropy
* **Statistical Tools**: Radius of gyration, entropy measures, and predictability analysis
* **Data Quality**: Comprehensive data quality assessment and validation tools

Operating System Support
-----------------------

**`movr` only supports Linux and macOS systems.**

* ✅ **Linux**: Ubuntu, Debian, and other Linux distributions
* ✅ **macOS**: All macOS versions (tested on recent releases)
* ❌ **Windows**: Not supported natively
* 🔄 **Windows via WSL**: Supported through Windows Subsystem for Linux

**Note**: We have tested the package on Ubuntu and macOS systems. For Windows users, we recommend using `Windows Subsystem for Linux (WSL) <https://docs.microsoft.com/en-us/windows/wsl/>`_ with Ubuntu.

Contents:

.. toctree::
   :maxdepth: 2
   :caption: Documentation

   installation
   quickstart
   examples
   api
   contributing

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`

Citation
--------

If you use `movr` in your research, please cite:

.. code-block:: bibtex

   @article{CHEN2017464,
     author = {Xiaming Chen and Haiyang Wang and Siwei Qiang and Yongkun Wang and Yaohui Jin},
     title = {Discovering and modeling meta-structures in human behavior from city-scale cellular data},
     journal = {Pervasive and Mobile Computing},
     volume = {40},
     pages = {464--476},
     year = {2017},
     doi = {https://doi.org/10.1016/j.pmcj.2017.02.001},
     url = {https://www.sciencedirect.com/science/article/pii/S1574119217300743}
   }

