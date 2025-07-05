API Reference
=============

This section provides links to the complete API documentation for all functions in the `movr` package.

Function Categories
------------------

Visualization Functions
~~~~~~~~~~~~~~~~~~~~~~

* :func:`plot_traj3d` - 3D trajectory visualization
* :func:`plot_flowmap` - Flow map visualization
* :func:`plot_traj_graph` - Trajectory graph visualization
* :func:`plot_traj3d` - 3D trajectory plots
* :func:`plot.heatmap` - Heatmap visualization

Flow Analysis
~~~~~~~~~~~~

* :func:`flowmap` - Create flow maps from mobility data
* :func:`flowmap2` - Alternative flow map creation
* :func:`flow.stat` - Flow statistics

Spatial Analysis
~~~~~~~~~~~~~~~

* :func:`radius_of_gyration` - Calculate radius of gyration
* :func:`spatial.corr` - Spatial correlation analysis
* :func:`point.coverage` - Point coverage analysis
* :func:`people.occurrence` - People occurrence analysis
* :func:`voronoi3d` - 3D Voronoi tessellation
* :func:`voronoi2polygons` - 2D Voronoi tessellation

Temporal Analysis
~~~~~~~~~~~~~~~~

* :func:`hour2tod` - Time-of-day analysis
* :func:`hour2tow` - Time-of-week analysis
* :func:`hour2date` - Hour to date conversion
* :func:`gen_sessions` - Generate mobility sessions
* :func:`entropy.spacetime` - Spatio-temporal entropy
* :func:`entropy.space` - Spatial entropy
* :func:`entropy.rand` - Random entropy

Data Quality
~~~~~~~~~~~

* :func:`dq.traj` - Trajectory data quality assessment
* :func:`dq.traj2` - Alternative trajectory quality check
* :func:`dq.point` - Point-level quality assessment
* :func:`dq.point2` - Alternative point quality check
* :func:`dq.iovan` - Iovan distance quality check

Statistical Analysis
~~~~~~~~~~~~~~~~~~~

* :func:`fit.power.law` - Fit power law distribution
* :func:`fit.truncated.power.law` - Fit truncated power law
* :func:`fit.polyexp` - Fit polyexponential distribution
* :func:`RMSE` - Root Mean Square Error calculation

Coordinate Transformations
~~~~~~~~~~~~~~~~~~~~~~~~~

* :func:`cart2geo` - Cartesian to geographic coordinates
* :func:`geo2cart` - Geographic to Cartesian coordinates
* :func:`cart2geo.radian` - Cartesian to geographic (radians)
* :func:`geo2cart.radian` - Geographic to Cartesian (radians)
* :func:`deg2rad` - Degrees to radians
* :func:`rad2deg` - Radians to degrees
* :func:`lonlat2xy` - Longitude/latitude to x/y coordinates
* :func:`stcoords` - Spatio-temporal coordinates

Utility Functions
~~~~~~~~~~~~~~~~

* :func:`gcd` - Great circle distance
* :func:`euc.dist` - Euclidean distance
* :func:`pairwise.dist` - Pairwise distances
* :func:`midpoint` - Calculate midpoint
* :func:`in.area` - Check if points are in area
* :func:`rot90` - Rotate matrix 90 degrees
* :func:`rep_each` - Repeat each element
* :func:`melt_time` - Melt time data
* :func:`cal_place_dwelling` - Calculate place dwelling
* :func:`traj3d.close` - Close 3D trajectory
* :func:`standardize` - Standardize data
* :func:`standardize_st` - Spatio-temporal standardization

Sequence Analysis
~~~~~~~~~~~~~~~~

* :func:`seq_approximate` - Approximate sequence
* :func:`seq_collapsed` - Collapse sequence
* :func:`seq_distinct` - Distinct sequence
* :func:`seq_dist` - Sequence distance

Binning Functions
~~~~~~~~~~~~~~~~

* :func:`vbin` - Vector binning
* :func:`vbin.range` - Vector binning with range
* :func:`vbin.grid` - Grid-based binning
* :func:`heatmap.levels` - Heatmap levels

Plotting Utilities
~~~~~~~~~~~~~~~~~

* :func:`minor.ticks.axis` - Minor tick marks for axes
* :func:`Rcolors` - R color palettes

Getting Help
-----------

To get detailed help for any function:

.. code-block:: r

   # Get help for a specific function
   ?plot_traj3d
   ?flowmap
   ?radius_of_gyration

   # Search for functions
   ??trajectory
   ??flow
   ??spatial

   # View all functions in the package
   ls("package:movr")

   # View package information
   packageVersion("movr")
   sessionInfo()

Function Arguments
-----------------

Most functions in `movr` follow consistent parameter naming:

* `x`, `y` - Spatial coordinates (longitude, latitude)
* `z` - Temporal coordinate (timestamp)
* `id` - Individual identifier
* `time` - Time column name
* `from`, `to` - Origin and destination for flow analysis
* `weight` - Weight column for flow analysis

Data Format
-----------

The `movr` package expects mobility data in the following format:

.. code-block:: r

   # Example data structure
   movement <- data.frame(
     user_id = c("user1", "user1", "user2", "user2"),
     timestamp = c("2023-01-01 10:00:00", "2023-01-01 11:00:00", 
                   "2023-01-01 10:30:00", "2023-01-01 11:30:00"),
     lon = c(-74.006, -74.007, -73.985, -73.986),
     lat = c(40.712, 40.713, 40.758, 40.759)
   )

Required columns:
* `user_id` - Unique identifier for each individual
* `timestamp` - Time of the location record
* `lon` - Longitude coordinate
* `lat` - Latitude coordinate

Optional columns:
* `origin_cell`, `destination_cell` - For flow analysis
* `flow_count`, `population` - For weighted analysis
* Any additional metadata columns

For more detailed information about each function, use the R help system:

.. code-block:: r

   help(package = "movr") 