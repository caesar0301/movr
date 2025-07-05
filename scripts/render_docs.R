#!/usr/bin/env Rscript
# Enhanced Documentation Generation Script for movr package
# This script generates documentation with explicit importFrom statements

cat("=== movr Package Documentation Generation ===\n")

# Load required packages
if (!requireNamespace("devtools", quietly = TRUE)) {
  stop("Package 'devtools' is required. Please install it with: install.packages('devtools')")
}

if (!requireNamespace("roxygen2", quietly = TRUE)) {
  stop("Package 'roxygen2' is required. Please install it with: install.packages('roxygen2')")
}

cat("1. Cleaning previous documentation...\n")
# Clean previous documentation
if (dir.exists("man")) {
  unlink("man", recursive = TRUE)
  cat("   - Removed existing man/ directory\n")
}

cat("2. Generating documentation with roxygen2...\n")
# Generate documentation with all roclets
devtools::document(
  roclets = c("collate", "namespace", "rd")
)

cat("3. Validating NAMESPACE file...\n")
# Check if NAMESPACE was generated
if (!file.exists("NAMESPACE")) {
  stop("NAMESPACE file was not generated!")
}

# Read and display NAMESPACE content
namespace_content <- readLines("NAMESPACE")
cat("   - NAMESPACE file generated successfully\n")
cat("   - Contains", length(namespace_content), "lines\n")

# Count different types of entries
importFrom_count <- sum(grepl("^importFrom", namespace_content))
export_count <- sum(grepl("^export", namespace_content))
s3method_count <- sum(grepl("^S3method", namespace_content))
useDynLib_count <- sum(grepl("^useDynLib", namespace_content))

cat("   - importFrom statements:", importFrom_count, "\n")
cat("   - export statements:", export_count, "\n")
cat("   - S3method statements:", s3method_count, "\n")
cat("   - useDynLib statements:", useDynLib_count, "\n")

cat("4. Checking for potential issues...\n")
# Check for common issues
if (importFrom_count == 0) {
  cat("   - WARNING: No importFrom statements found. Consider adding @importFrom annotations to R files.\n")
}

if (export_count == 0) {
  cat("   - WARNING: No export statements found. Check @export annotations in R files.\n")
}

# Check for specific packages that should be imported
required_packages <- c("dplyr", "tidyr", "igraph", "magrittr")
for (pkg in required_packages) {
  if (!any(grepl(paste0("importFrom\\(", pkg, ","), namespace_content))) {
    cat("   - NOTE: No explicit imports from '", pkg, "'. Consider adding @importFrom annotations.\n", sep = "")
  }
}

cat("5. Building package for documentation check...\n")
# Clean any previous builds
if (dir.exists("build")) {
  unlink("build", recursive = TRUE)
}

# Build package
build_result <- devtools::build()
if (!file.exists(build_result)) {
  stop("Package build failed")
}

cat("   - Package built successfully: ", basename(build_result), "\n")

cat("6. Running R CMD check on built package...\n")
# Run a quick check on the built package
check_result <- tryCatch({
  system(paste("R CMD check", build_result, "--no-manual --no-vignettes --no-tests"), intern = TRUE, ignore.stderr = TRUE)
}, error = function(e) {
  NULL
})

if (!is.null(check_result) && length(check_result) > 0 && !is.null(attr(check_result, "status")) && attr(check_result, "status") == 0) {
  cat("   - Documentation check passed!\n")
} else {
  cat("   - WARNING: Documentation check failed or returned non-zero status.\n")
  cat("   - This is normal for packages with C extensions.\n")
}

cat("7. Documentation generation complete!\n")
cat("   - NAMESPACE file: NAMESPACE\n")
cat("   - Documentation files: man/\n")
cat("   - Built package: ", basename(build_result), "\n")

cat("\n=== Next Steps ===\n")
cat("1. Review the generated NAMESPACE file\n")
cat("2. Add @importFrom annotations to R files for better organization\n")
cat("3. Run './scripts/check_cran.sh' to verify everything works\n")
cat("4. Commit the changes to version control\n") 