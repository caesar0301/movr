#!/bin/bash
# Unified Release Script for movr package
# This script performs comprehensive testing and builds the package for CRAN release
# Supports both dry-run (testing only) and real release modes

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
    echo "  -d, --dry-run       Test build and validate for CRAN release (default)"
    echo "  -r, --release       Perform actual CRAN release"
    echo "  -i, --interactive   Enable interactive mode for CRAN submission"
    echo "  -q, --quick         Run quick checks (skip some time-consuming tests)"
    echo "  -v, --verbose       Run with verbose output"
    echo ""
    echo "Examples:"
    echo "  $0                  # Run dry-run (test build and validate)"
    echo "  $0 --dry-run        # Same as above"
    echo "  $0 --release        # Perform actual CRAN release"
    echo "  $0 --release --interactive  # Perform CRAN release with interactive submission"
    echo "  $0 --quick          # Run quick dry-run"
    echo ""
    echo "This script performs comprehensive testing and builds the package for CRAN release."
}

# Function to check required tools
check_required_tools() {
    print_status "Checking required tools..."
    
    for tool in cmake make R; do
        if command -v $tool >/dev/null 2>&1; then
            print_success "$tool found: $(which $tool)"
            if [ "$tool" = "R" ]; then
                echo "  R version: $(R --version | head -1)"
                echo "  R_HOME: $R_HOME"
            fi
        else
            print_error "$tool not found"
            exit 1
        fi
    done
}

# Function to check R package dependencies
check_r_dependencies() {
    print_status "Checking R dependencies..."
    
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
    
    if [ $? -ne 0 ]; then
        print_error "Missing required R packages. Please install them first."
        exit 1
    fi
}

# Function to test configure script
test_configure() {
    print_status "Testing configure script..."
    
    if [ -f "configure" ]; then
        echo "Running configure script..."
        ./configure
        print_success "Configure script completed"
    else
        print_error "configure script not found"
        exit 1
    fi
}

# Function to check build results
check_build_results() {
    print_status "Checking build results..."
    
    if [ -f "src/movr.so" ]; then
        print_success "movr.so found in src directory"
        ls -la src/movr.so
    else
        print_error "movr.so not found in src directory"
        echo "Contents of src directory:"
        ls -la src/
        exit 1
    fi
}

# Function to test R package build
test_r_package_build() {
    print_status "Testing R package build..."
    
    R --slave -e "
if (requireNamespace('devtools', quietly = TRUE)) {
    cat('Building R package...\n')
    build_result <- devtools::build()
    cat('Package built successfully:', basename(build_result), '\n')
} else {
    cat('devtools not available, skipping R package build test\n')
    quit(status = 1)
}
"
    
    if [ $? -ne 0 ]; then
        print_error "R package build failed"
        exit 1
    fi
}

# Function to run build test (from test_build.sh)
run_build_test() {
    echo "=== movr Package Build Test ==="
    echo "Date: $(date)"
    echo "Platform: $(uname -s) $(uname -m)"
    echo "Working directory: $(pwd)"
    
    # Check if we're in the right directory
    if [ ! -f "DESCRIPTION" ]; then
        print_error "DESCRIPTION file not found. Please run this script from the package root directory."
        exit 1
    fi
    
    check_required_tools
    check_r_dependencies
    test_configure
    check_build_results
    test_r_package_build
    
    print_success "Build test completed successfully"
}

# Function to regenerate documents
regenerate_documents() {
    print_status "Regenerating documents with enhanced NAMESPACE generation..."
    Rscript scripts/render_docs.R
    print_success "Documentation generation completed"
}

# Function to run CRAN release check
run_cran_check() {
    print_status "Running comprehensive CRAN release check..."
    
    if [ -f "scripts/check_cran.sh" ]; then
        if [ "$QUICK_MODE" = true ]; then
            ./scripts/check_cran.sh --quick
        else
            ./scripts/check_cran.sh
        fi
        
        if [ $? -ne 0 ]; then
            print_error "CRAN release check failed! Please fix the issues before proceeding."
            exit 1
        fi
        print_success "CRAN release check passed"
    else
        print_error "CRAN check script not found."
        exit 1
    fi
}

# Function to build package for release
build_package_for_release() {
    print_status "Building package for release..."
    
    R --slave -e "
if (requireNamespace('devtools', quietly = TRUE)) {
    cat('Building package with devtools...\n')
    build_result <- devtools::build()
    cat('Package built successfully:', basename(build_result), '\n')
} else {
    cat('devtools not available\n')
    quit(status = 1)
}
"
    
    if [ $? -ne 0 ]; then
        print_error "Package build failed"
        exit 1
    fi
}

# Function to perform final verification
final_verification() {
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
}

# Function to run spell check
run_spell_check() {
    print_status "Running spell check..."
    R --slave -e "options(repos = c(CRAN = 'https://cran.rstudio.com/')); library(devtools); spell_check()"
    if [ $? -eq 0 ]; then
        print_success "Spell check completed"
    else
        print_error "Spell check failed"
        exit 1
    fi
}

# Function to perform CRAN release
perform_cran_release() {
    print_status "Preparing for CRAN release..."
    print_warning "Before submitting to CRAN, please ensure:"
    echo "  □ NEWS.md is updated with changes"
    echo "  □ All tests pass"
    echo "  □ Documentation is complete"
    echo "  □ No critical warnings remain"
    echo ""
    
    # Run spell check first
    run_spell_check
    
    read -p "Proceed with CRAN release? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Initiating CRAN release..."
        
        if [ "$INTERACTIVE_MODE" = true ]; then
            print_status "Starting interactive CRAN submission process..."
            print_status "Launching interactive R session for CRAN submission..."
            print_warning "You will be prompted to answer questions in the R session."
            print_status "Type 'q()' to exit R when done."
            echo ""
            R --no-save --interactive -e "
options(repos = c(CRAN = 'https://cran.rstudio.com/'))
library(devtools)
cat('\\n=== CRAN Release Process ===\\n')
cat('Package ready for submission. Running release()...\\n')
release()
"
            print_success "CRAN release process completed"
        else
            print_warning "Interactive mode not enabled. Use --interactive flag for automatic CRAN submission."
            print_status "For non-interactive environments, you can manually submit the package to CRAN."
            print_status "Package file: $(ls movr_*.tar.gz | head -1)"
            print_status "CRAN submission URL: https://cran.r-project.org/submit.html"
            print_success "Release preparation completed - ready for manual submission"
        fi
    else
        print_status "Release cancelled. Package is ready for manual submission."
        BUILD_FILE=$(ls movr_*.tar.gz | head -1)
        print_status "Package file: $BUILD_FILE"
    fi
}

# Function to run dry-run mode
run_dry_run() {
    echo "=== movr Package Release Dry-Run ==="
    echo "Date: $(date)"
    echo "Platform: $(uname -s) $(uname -m)"
    echo "Working directory: $(pwd)"
    echo ""
    
    # Check if we're in the right directory
    if [ ! -f "DESCRIPTION" ]; then
        print_error "DESCRIPTION file not found. Please run this script from the package root directory."
        exit 1
    fi
    
    # Step 1: Run build test (from test_build.sh)
    run_build_test
    
    # Step 2: Regenerate documents
    regenerate_documents
    
    # Step 3: Run CRAN release check
    run_cran_check
    
    # Step 4: Build package
    build_package_for_release
    
    # Step 5: Final verification
    final_verification
    
    echo ""
    print_success "Dry-run completed successfully!"
    print_status "Package is ready for release. Use --release flag to perform actual CRAN submission."
}

# Function to run real release mode
run_real_release() {
    echo "=== movr Package Release ==="
    echo "Date: $(date)"
    echo "Platform: $(uname -s) $(uname -m)"
    echo "Working directory: $(pwd)"
    echo ""
    
    # # Check if we're in the right directory
    # if [ ! -f "DESCRIPTION" ]; then
    #     print_error "DESCRIPTION file not found. Please run this script from the package root directory."
    #     exit 1
    # fi
    
    # # Step 1: Run build test (from test_build.sh)
    # run_build_test
    
    # # Step 2: Regenerate documents
    # regenerate_documents
    
    # # Step 3: Run CRAN release check
    # run_cran_check
    
    # Step 4: Build package
    build_package_for_release
    
    # Step 5: Final verification
    final_verification
    
    # Step 6: Perform CRAN release
    perform_cran_release
    
    echo ""
    print_success "Release process completed!"
}

# Parse command line arguments
DRY_RUN=true  # Default to dry-run mode
QUICK_MODE=false
VERBOSE=false
INTERACTIVE_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -r|--release)
            DRY_RUN=false
            shift
            ;;
        -q|--quick)
            QUICK_MODE=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -i|--interactive)
            INTERACTIVE_MODE=true
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Main execution
main() {
    if [ "$DRY_RUN" = true ]; then
        run_dry_run
    else
        run_real_release
    fi
}

# Run main function
main "$@"