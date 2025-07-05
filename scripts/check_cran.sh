#!/bin/bash
# CRAN Release Check Wrapper Script for movr package
# This script provides an easy interface to run comprehensive CRAN release testing

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

# Function to check if R is available
check_r() {
    if ! command -v R &> /dev/null; then
        print_error "R is not installed or not in PATH"
        exit 1
    fi
    print_success "R found: $(R --version | head -1)"
}

# Function to install required R packages
install_required_packages() {
    print_status "Checking required R packages..."
    
    required_packages=("devtools" "roxygen2" "spelling" "goodpractice" "rcmdcheck" "rhub")
    missing_packages=()
    
    for pkg in "${required_packages[@]}"; do
        if ! R --slave -e "requireNamespace('$pkg', quietly = TRUE)" &> /dev/null; then
            missing_packages+=("$pkg")
        fi
    done
    
    if [ ${#missing_packages[@]} -gt 0 ]; then
        print_warning "Missing required packages: ${missing_packages[*]}"
        read -p "Install missing packages? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_status "Installing required packages..."
            R --slave -e "install.packages(c($(printf "'%s'," "${missing_packages[@]}" | sed 's/,$//')), repos = 'https://cran.rstudio.com/')"
            print_success "Required packages installed"
        else
            print_error "Cannot proceed without required packages"
            exit 1
        fi
    else
        print_success "All required packages are installed"
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -i, --install       Install required packages and exit"
    echo "  -q, --quick         Run quick check (skip some tests)"
    echo "  -v, --verbose       Run with verbose output"
    echo "  --no-spell          Skip spell checking"
    echo "  --no-goodpractice   Skip good practice checks"
    echo ""
    echo "Examples:"
    echo "  $0                  # Run full CRAN release check"
    echo "  $0 --quick          # Run quick check"
    echo "  $0 --install        # Install required packages"
    echo ""
    echo "This script performs comprehensive testing required for CRAN submission."
}

# Function to run quick check
run_quick_check() {
    print_status "Running quick CRAN check..."
    Rscript scripts/cran_release_check.R --quick
}

# Function to run full check
run_full_check() {
    print_status "Running full CRAN release check..."
    Rscript scripts/cran_release_check.R
}

# Parse command line arguments
QUICK_MODE=false
VERBOSE=false
INSTALL_ONLY=false
SKIP_SPELL=false
SKIP_GOODPRACTICE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -i|--install)
            INSTALL_ONLY=true
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
        --no-spell)
            SKIP_SPELL=true
            shift
            ;;
        --no-goodpractice)
            SKIP_GOODPRACTICE=true
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
    echo "=== movr Package CRAN Release Check ==="
    echo ""
    
    # Check if we're in the right directory
    if [ ! -f "DESCRIPTION" ]; then
        print_error "DESCRIPTION file not found. Please run this script from the package root directory."
        exit 1
    fi
    
    # Check R installation
    check_r
    
    # Install packages if requested
    if [ "$INSTALL_ONLY" = true ]; then
        install_required_packages
        print_success "Package installation completed"
        exit 0
    fi
    
    # Install required packages if needed
    install_required_packages
    
    # Run appropriate check
    if [ "$QUICK_MODE" = true ]; then
        run_quick_check
    else
        run_full_check
    fi
    
    echo ""
    print_success "CRAN release check completed!"
}

# Run main function
main "$@" 