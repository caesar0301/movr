Quick Start Guide
=================

This guide will help you get started with `movr` quickly.

Loading the Package
------------------

First, load the `movr` package and example data:

.. code-block:: r

   library(movr)
   data(movement)

   # View the structure of the example data
   str(movement)
   head(movement)

Basic Trajectory Visualization
-----------------------------

Create a simple 3D trajectory plot:

.. code-block:: r

   # Basic 3D trajectory visualization
   plot_traj3d(movement, 
               x = "lon", y = "lat", z = "timestamp",
               color_by = "user_id",
               alpha = 0.7)

Flow Map Analysis
----------------

Create and visualize flow maps:

.. code-block:: r

   # Create flow map from mobility data
   flow_data <- flowmap(movement, 
                        from = "origin_cell", 
                        to = "destination_cell",
                        weight = "flow_count")

   # Visualize with custom styling
   plot_flowmap(flow_data,
                node_size = "population",
                edge_width = "flow_strength",
                color_scheme = "viridis")

Spatial Analysis
---------------

Calculate radius of gyration and spatial correlations:

.. code-block:: r

   # Calculate radius of gyration
   rog <- radius_of_gyration(movement, 
                            x = "lon", y = "lat", 
                            id = "user_id")

   # Spatial correlation analysis
   spatial_corr <- spatial.corr(movement, 
                               x = "lon", y = "lat",
                               time_window = "daily")

Temporal Analysis
----------------

Analyze time-of-day patterns and generate sessions:

.. code-block:: r

   # Time-of-day analysis
   tod_data <- hour2tod(movement$timestamp)

   # Generate mobility sessions
   sessions <- gen_sessions(movement, 
                           id = "user_id",
                           time_threshold = 3600)  # 1 hour

   # Calculate temporal entropy
   temp_entropy <- entropy.spacetime(movement,
                                    id = "user_id",
                                    time_bins = 24)

Data Quality Assessment
----------------------

Assess the quality of your mobility data:

.. code-block:: r

   # Comprehensive data quality check
   dq_result <- dq.traj(movement,
                        id = "user_id",
                        time = "timestamp",
                        x = "lon", y = "lat")

   # Point-level quality assessment
   point_quality <- dq.point(movement,
                            x = "lon", y = "lat",
                            time = "timestamp")

Advanced Visualizations
----------------------

Create more complex visualizations:

.. code-block:: r

   # Voronoi tessellation in 3D
   voronoi_result <- voronoi3d(movement, 
                              x = "lon", y = "lat", z = "timestamp")

   # Interactive 3D map visualizations
   map3d_result <- map3d(movement, 
                         x = "lon", y = "lat", z = "timestamp",
                         terrain = TRUE,
                         buildings = TRUE)

Next Steps
----------

Now that you've completed the quick start:

1. Explore the `examples` section for more detailed examples
2. Check the `api` section for complete function documentation
3. Read the `research` section to understand potential applications
4. Visit the `GitHub repository <https://github.com/caesar0301/movr>`_ for the latest updates

Getting Help
-----------

If you need help:

* Use `?function_name` for detailed function documentation
* Check the `vignettes` with `vignette(package = "movr")`
* Report issues on `GitHub <https://github.com/caesar0301/movr/issues>`_ 