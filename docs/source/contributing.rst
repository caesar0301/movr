Contributing to movr
===================

Thank you for your interest in contributing to `movr`! This guide will help you get started with contributing to the project.

Getting Started
--------------

**Prerequisites**
   * R >= 3.0.0
   * GNU CMake
   * GLib development libraries
   * Git

**Fork and Clone**
   Fork the repository on GitHub and clone your fork:

   .. code-block:: bash

      git clone https://github.com/YOUR_USERNAME/movr.git
      cd movr

**Install Dependencies**
   Install the required system dependencies:

   **Ubuntu/Debian:**
   .. code-block:: bash

      sudo apt-get install cmake build-essential libglib2.0-dev

   **macOS:**
   .. code-block:: bash

      brew install cmake glib

Development Setup
----------------

**Install Development Dependencies**
   Install R development packages:

   .. code-block:: r

      install.packages(c("devtools", "roxygen2", "testthat", "knitr"))

**Build the Package**
   Build the package from source:

   .. code-block:: bash

      # Build C source
      ./configure

      # Install the package
      R --no-save -e "library(devtools);install()"

**Run Tests**
   Run the test suite:

   .. code-block:: r

      library(testthat)
      test_package("movr")

Code Style
----------

**R Code Style**
   Follow the R style guide:
   * Use meaningful variable names
   * Add comments for complex logic
   * Use consistent indentation (2 spaces)
   * Follow R naming conventions

**C Code Style**
   For C extensions:
   * Use meaningful function and variable names
   * Add comments for complex algorithms
   * Follow C99 standard
   * Use consistent indentation

**Documentation**
   * Update function documentation using roxygen2
   * Add examples to function documentation
   * Update README.md for user-facing changes
   * Update this documentation for developer-facing changes

Making Changes
--------------

**Create a Branch**
   Create a feature branch for your changes:

   .. code-block:: bash

      git checkout -b feature/your-feature-name

**Make Your Changes**
   * Write your code
   * Add tests for new functionality
   * Update documentation
   * Ensure all tests pass

**Test Your Changes**
   Run the full test suite:

   .. code-block:: bash

      ./scripts/check_cran.sh --quick

   Or run individual checks:

   .. code-block:: bash

      R CMD build .
      R CMD check movr_*.tar.gz

**Commit Your Changes**
   Use descriptive commit messages:

   .. code-block:: bash

      git add .
      git commit -m "Add new function for spatial analysis"
      git push origin feature/your-feature-name

**Create a Pull Request**
   * Go to the GitHub repository
   * Click "New Pull Request"
   * Select your feature branch
   * Fill out the pull request template
   * Submit the pull request

Pull Request Guidelines
----------------------

**Before Submitting**
   * Ensure all tests pass
   * Update documentation
   * Add examples for new functions
   * Check that the package builds successfully
   * Verify OS compatibility (Linux and macOS only)

**Pull Request Template**
   Include the following information:

   * Description of changes
   * Related issue number (if applicable)
   * Type of change (bug fix, feature, documentation)
   * Testing performed
   * OS tested on

**Review Process**
   * All pull requests require review
   * Address reviewer comments
   * Ensure CI/CD checks pass
   * Maintain backward compatibility

Testing
-------

**Writing Tests**
   Add tests for new functionality:

   .. code-block:: r

      test_that("new_function works correctly", {
        # Test setup
        data <- create_test_data()
        
        # Test function
        result <- new_function(data)
        
        # Assertions
        expect_equal(length(result), 10)
        expect_true(all(result > 0))
      })

**Running Tests**
   Run tests during development:

   .. code-block:: r

      library(testthat)
      test_file("tests/testthat/test-your-function.R")

**Test Coverage**
   Aim for high test coverage for new functions.

Documentation
-------------

**Function Documentation**
   Use roxygen2 for function documentation:

   .. code-block:: r

      #' Title of the function
      #'
      #' @param x Description of parameter x
      #' @param y Description of parameter y
      #' @return Description of return value
      #' @examples
      #' # Example usage
      #' result <- my_function(x, y)
      #' @export
      my_function <- function(x, y) {
        # Function implementation
      }

**Package Documentation**
   Update package documentation:

   .. code-block:: r

      #' @title Package Title
      #' @description Package description
      #' @docType package
      #' @name movr
      NULL

**Vignettes**
   Create vignettes for complex functionality:

   .. code-block:: r

      #' @title Vignette Title
      #' @author Your Name
      #' @description Description of the vignette
      #' @keywords internal
      NULL

Release Process
--------------

**Version Bumping**
   Update version numbers in:
   * `DESCRIPTION` file
   * `docs/source/conf.py`
   * `README.md` (if needed)

**Release Checklist**
   * All tests pass
   * Documentation is updated
   * Examples work correctly
   * Package builds successfully
   * OS compatibility verified
   * CRAN requirements met

**CRAN Submission**
   Before submitting to CRAN:
   * Run `R CMD check --as-cran`
   * Fix all warnings and errors
   * Test on multiple R versions
   * Verify all dependencies are available

Getting Help
-----------

**Questions and Issues**
   * Check existing issues on GitHub
   * Search the documentation
   * Ask questions in GitHub issues
   * Contact the maintainers

**Development Resources**
   * `R Development Guide <https://cran.r-project.org/doc/manuals/r-release/R-exts.html>`_
   * `R Package Development <https://r-pkgs.org/>`_
   * `testthat Documentation <https://testthat.r-lib.org/>`_
   * `roxygen2 Documentation <https://roxygen2.r-lib.org/>`_

**Community Guidelines**
   * Be respectful and inclusive
   * Provide constructive feedback
   * Help others learn and contribute
   * Follow the project's code of conduct

Thank you for contributing to `movr`! 