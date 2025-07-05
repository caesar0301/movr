#!/bin/bash

# Test script for movr package build system
# This script tests the build process and provides debugging information

set -e  # Exit on any error

echo "=== movr Package Build Test ==="
echo "Date: $(date)"
echo "Platform: $(uname -s) $(uname -m)"
echo "Working directory: $(pwd)"

# Check if we're in the right directory
if [ ! -f "DESCRIPTION" ]; then
    echo "Error: DESCRIPTION file not found. Please run this script from the package root directory."
    exit 1
fi

# Check required tools
echo ""
echo "=== Checking Required Tools ==="
for tool in cmake make R; do
    if command -v $tool >/dev/null 2>&1; then
        echo "✓ $tool found: $(which $tool)"
        if [ "$tool" = "R" ]; then
            echo "  R version: $(R --version | head -1)"
            echo "  R_HOME: $R_HOME"
        fi
    else
        echo "✗ $tool not found"
        exit 1
    fi
done

# Check R package dependencies
echo ""
echo "=== Checking R Dependencies ==="
R --slave -e "
required_packages <- c('devtools', 'roxygen2')
missing_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]
if (length(missing_packages) > 0) {
    cat('Missing packages:', paste(missing_packages, collapse = ', '), '\n')
    quit(status = 1)
} else {
    cat('All required R packages are available\n')
}
"

# Test configure script
echo ""
echo "=== Testing Configure Script ==="
if [ -f "configure" ]; then
    echo "Running configure script..."
    ./configure
    echo "Configure script completed"
else
    echo "Error: configure script not found"
    exit 1
fi

# Check if library was built
echo ""
echo "=== Checking Build Results ==="
if [ -f "src/movr.so" ]; then
    echo "✓ movr.so found in src directory"
    ls -la src/movr.so
else
    echo "✗ movr.so not found in src directory"
    echo "Contents of src directory:"
    ls -la src/
    exit 1
fi

# Test R package build
echo ""
echo "=== Testing R Package Build ==="
R --slave -e "
if (requireNamespace('devtools', quietly = TRUE)) {
    cat('Building R package...\n')
    build_result <- devtools::build()
    cat('Package built successfully:', basename(build_result), '\n')
} else {
    cat('devtools not available, skipping R package build test\n')
}
"

echo ""
echo "=== Build Test Completed Successfully ===" 