#!/bin/bash
# Release Script for movr package
# This script performs comprehensive testing and builds the package for manual CRAN upload

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                  # Prepare package for manual CRAN upload"
    echo ""
    echo "This script performs comprehensive testing and builds the package for manual CRAN upload."
}

# Function to check environment and dependencies
check_environment() {
    print_status "Checking environment and dependencies..."
    
    # Check if we're in the right directory
    if [ ! -f "DESCRIPTION" ]; then
        print_error "DESCRIPTION file not found. Please run this script from the package root directory."
        exit 1
    fi
    
    # Check required tools
    for tool in cmake make R; do
        if ! command -v $tool >/dev/null 2>&1; then
            print_error "$tool not found"
            exit 1
        fi
    done
    
    # Check R dependencies
    R --slave -e "
required_packages <- c('devtools', 'roxygen2')
missing_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]
if (length(missing_packages) > 0) {
    cat('Missing packages:', paste(missing_packages, collapse = ', '), '\n')
    quit(status = 1)
}
"
    
    if [ $? -ne 0 ]; then
        print_error "Missing required R packages. Please install them first."
        exit 1
    fi
    
    print_success "Environment check completed"
}

# Function to build and test package
build_and_test() {
    print_status "Building and testing package..."
    
    # Run configure script
    if [ -f "configure" ]; then
        ./configure
    else
        print_error "configure script not found"
        exit 1
    fi
    
    # Check build results
    if [ ! -f "src/movr.so" ]; then
        print_error "movr.so not found in src directory"
        exit 1
    fi
    
    # Regenerate documents
    Rscript scripts/render_docs.R
    
    # Run CRAN release check
    if [ -f "scripts/check_cran.sh" ]; then
        ./scripts/check_cran.sh
        if [ $? -ne 0 ]; then
            print_error "CRAN release check failed! Please fix the issues before proceeding."
            exit 1
        fi
    else
        print_error "CRAN check script not found."
        exit 1
    fi
    
    # Build package for release
    R --slave -e "
if (requireNamespace('devtools', quietly = TRUE)) {
    build_result <- devtools::build()
    cat('Package built successfully:', basename(build_result), '\n')
} else {
    quit(status = 1)
}
"
    
    if [ $? -ne 0 ]; then
        print_error "Package build failed"
        exit 1
    fi
    
    print_success "Build and test completed"
}

# Function to prepare for manual CRAN upload
prepare_manual_cran_upload() {
    print_status "Preparing package for manual CRAN upload..."
    
    # Run spell check
    R --slave -e "options(repos = c(CRAN = 'https://cran.rstudio.com/')); library(devtools); spell_check()"
    if [ $? -ne 0 ]; then
        print_error "Spell check failed"
        exit 1
    fi
    
    # Get package file
    BUILD_FILE=$(ls movr_*.tar.gz | head -1)
    if [ ! -f "$BUILD_FILE" ]; then
        print_error "Package file not found!"
        exit 1
    fi
    
    print_success "Package file ready: $BUILD_FILE"
    print_status "Package size: $(du -h "$BUILD_FILE" | cut -f1)"
    
    echo ""
    print_status "=== Manual CRAN Upload Instructions ==="
    echo "1. Go to: https://cran.r-project.org/submit.html"
    echo "2. Fill in the submission form:"
    echo "   - Package name: movr"
    echo "   - Version: $(grep '^Version:' DESCRIPTION | cut -d: -f2 | tr -d ' ')"
    echo "   - Upload the package file: $BUILD_FILE"
    echo "   - Add any comments about changes"
    echo ""
    echo "3. Alternative submission methods:"
    echo "   - Email to: cran@r-project.org"
    echo "   - Subject: movr package submission"
    echo "   - Attach: $BUILD_FILE"
    echo ""
    echo "4. After submission:"
    echo "   - Monitor: https://cran.r-project.org/web/checks/check_results_movr.html"
    echo "   - Check email for CRAN feedback"
    echo ""
    
    print_success "Package is ready for manual CRAN upload!"
    print_status "Package file location: $(pwd)/$BUILD_FILE"
    
    # Copy package to desktop if requested
    read -p "Copy package to desktop for easy access? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cp "$BUILD_FILE" ~/Desktop/
        print_success "Package copied to desktop: ~/Desktop/$BUILD_FILE"
    fi
}

# Main release preparation function
run_release_preparation() {
    echo "=== movr Package Release Preparation ==="
    echo "Date: $(date)"
    echo "Platform: $(uname -s) $(uname -m)"
    echo "Working directory: $(pwd)"
    echo ""
    
    check_environment
    build_and_test
    prepare_manual_cran_upload
    
    echo ""
    print_success "Release preparation completed! Package is ready for manual CRAN upload."
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Run release preparation
run_release_preparation