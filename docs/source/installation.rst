Installation Guide
==================

This guide will help you install the `movr` package on your system.

System Requirements
------------------

* **R** >= 3.0.0
* **GNU CMake** (for building C extensions)
* **GLib** development libraries

Operating System Support
-----------------------

**`movr` supports Linux, macOS, and Windows systems.**

* ✅ **Linux**: Ubuntu, Debian, and other Linux distributions
* ✅ **macOS**: All macOS versions (tested on recent releases)
* ✅ **Windows**: Native Windows support (Windows 10/11)
* 🔄 **Windows via WSL**: Also supported through Windows Subsystem for Linux

Installation Methods
-------------------

From GitHub
~~~~~~~~~~~

To install the latest development version from GitHub:

.. code-block:: r

   # Install devtools if you haven't already
   if (!requireNamespace("devtools", quietly = TRUE)) {
     install.packages("devtools")
   }

   # Install movr from GitHub
   devtools::install_github("caesar0301/movr")

From Source
~~~~~~~~~~

To install from source code:

.. code-block:: bash

   # Clone the repository
   git clone https://github.com/caesar0301/movr.git
   cd movr

   # Build C source
   ./configure

   # Check package compliance (recommended)
   ./scripts/check_cran.sh --quick

   # Or run basic check
   R CMD build .
   R CMD check movr_*.tar.gz

   # Install
   R --no-save -e "library(devtools);install()"

Platform-Specific Instructions
-----------------------------

Ubuntu/Debian
~~~~~~~~~~~~

Install system dependencies:

.. code-block:: bash

   sudo apt-get update
   sudo apt-get install cmake build-essential libglib2.0-dev

macOS
~~~~~

Install system dependencies using Homebrew:

.. code-block:: bash

   brew install cmake glib

Windows
~~~~~~~

Windows builds are now natively supported! The required dependencies are automatically installed during package installation. If you encounter issues, you can manually install:

* **Rtools**: Download from `CRAN <https://cran.r-project.org/bin/windows/Rtools/>`_ 
* **Optional**: For advanced builds, install `MSYS2 <https://www.msys2.org/>`_ for additional Unix-like tools

Windows (via WSL)
~~~~~~~~~~~~~~~~~

Alternatively, you can use Windows Subsystem for Linux (WSL):

1. Install WSL with Ubuntu from Microsoft Store
2. Follow the Ubuntu/Debian installation instructions above

Troubleshooting
--------------

Common Issues
~~~~~~~~~~~~

**CMake not found**
   Make sure CMake is installed and available in your PATH.

**GLib not found**
   Install the GLib development libraries for your system.

**R not found**
   Ensure R is installed and R_HOME is set correctly.

**Build errors on Windows**
   Windows builds are supported natively. Ensure Rtools is installed. If issues persist, try using WSL as an alternative.

**Permission errors**
   Make sure you have write permissions to the R library directory.

Getting Help
-----------

If you encounter installation issues:

* Check the `GitHub Issues <https://github.com/caesar0301/movr/issues>`_ page
* Ensure your system meets the requirements
* Try installing from CRAN first, then from GitHub if needed
* Verify that all system dependencies are installed

Verification
-----------

After installation, verify that `movr` is working correctly:

.. code-block:: r

   library(movr)
   data(movement)
   head(movement)

This should load the package and display the first few rows of the example dataset. 