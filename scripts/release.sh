#!/bin/bash
# Enhanced Release Script for movr package
# This script performs comprehensive testing and builds the package for CRAN release

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

echo "=== movr Package Release Process ==="
echo ""

# Step 1: Build native code
print_status "Building native code..."
./configure
print_success "Native code build completed"

# Step 2: Regenerate documents with enhanced NAMESPACE generation
print_status "Regenerating documents with enhanced NAMESPACE generation..."
Rscript scripts/render_docs.R
print_success "Documentation generation completed"

# Step 3: Run comprehensive CRAN release check
print_status "Running comprehensive CRAN release check..."
if [ -f "scripts/check_cran.sh" ]; then
    ./scripts/check_cran.sh
    if [ $? -ne 0 ]; then
        print_error "CRAN release check failed! Please fix the issues before proceeding."
        exit 1
    fi
    print_success "CRAN release check passed"
else
    print_warning "CRAN check script not found, running basic R CMD check on built package..."
    # Build package first
    R CMD build .
    BUILD_FILE=$(ls movr_*.tar.gz | head -1)
    if [ -f "$BUILD_FILE" ]; then
        R CMD check "$BUILD_FILE" --no-manual --no-vignettes
        print_success "Basic package check completed on built package"
    else
        print_error "Package build failed!"
        exit 1
    fi
fi

# Step 4: Build package
print_status "Building package..."
R CMD build .
print_success "Package build completed"

# Step 5: Final verification
print_status "Performing final verification..."
BUILD_FILE=$(ls movr_*.tar.gz | head -1)
if [ -f "$BUILD_FILE" ]; then
    print_success "Package file created: $BUILD_FILE"
    FILE_SIZE=$(du -h "$BUILD_FILE" | cut -f1)
    print_status "Package size: $FILE_SIZE"
else
    print_error "Package build file not found!"
    exit 1
fi

# Step 6: CRAN release preparation
print_status "Preparing for CRAN release..."
print_warning "Before submitting to CRAN, please ensure:"
echo "  □ NEWS.md is updated with changes"
echo "  □ All tests pass"
echo "  □ Documentation is complete"
echo "  □ No critical warnings remain"
echo ""

read -p "Proceed with CRAN release? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Initiating CRAN release..."
    R --no-save -e "library(devtools);spell_check();release()"
    print_success "CRAN release initiated"
else
    print_status "Release cancelled. Package is ready for manual submission."
    print_status "Package file: $BUILD_FILE"
fi

echo ""
print_success "Release process completed!"