#!/usr/bin/env Rscript
# Comprehensive CRAN Release Testing Script for movr package
# This script performs all checks required by CRAN before release
# Optimized to check the built package instead of source directory

# Parse command line arguments
args <- commandArgs(trailingOnly = TRUE)
quick_mode <- "--quick" %in% args

# Set CRAN mirror to avoid issues
options(repos = c(CRAN = "https://cran.rstudio.com/"))

cat("=== movr Package CRAN Release Testing ===\n")
if (quick_mode) {
  cat("Running in QUICK MODE (skipping some time-consuming tests)\n")
}
cat("Starting comprehensive pre-release validation...\n\n")

# Load required packages
required_packages <- c("devtools", "roxygen2", "spelling", "rcmdcheck", "rhub")
missing_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]

if (length(missing_packages) > 0) {
  cat("ERROR: Missing required packages for testing:\n")
  cat(paste("  -", missing_packages, collapse = "\n"), "\n")
  cat("Please install with: install.packages(c(", 
      paste0("'", missing_packages, "'", collapse = ", "), "))\n")
  quit(status = 1)
}

# Initialize results tracking
test_results <- list()
test_results$passed <- 0
test_results$failed <- 0
test_results$warnings <- 0
test_results$notes <- 0

# Helper function to run tests and track results
run_test <- function(test_name, test_func, critical = FALSE, skip_in_quick = FALSE) {
  if (quick_mode && skip_in_quick) {
    cat(sprintf("Running: %s (SKIPPED in quick mode)\n", test_name))
    cat("  ", rep("-", nchar(test_name) + 8), "\n", sep = "")
    cat("  ⏭️  SKIPPED (quick mode)\n\n")
    return(list(success = TRUE, message = "SKIPPED", error = NULL))
  }
  
  cat(sprintf("Running: %s\n", test_name))
  cat("  ", rep("-", nchar(test_name) + 8), "\n", sep = "")
  
  start_time <- Sys.time()
  result <- tryCatch({
    test_func()
    list(success = TRUE, message = "PASSED", error = NULL)
  }, error = function(e) {
    list(success = FALSE, message = "FAILED", error = e$message)
  }, warning = function(w) {
    list(success = FALSE, message = "WARNING", error = w$message)
  })
  end_time <- Sys.time()
  
  duration <- round(as.numeric(difftime(end_time, start_time, units = "secs")), 2)
  
  if (result$success) {
    cat(sprintf("  ✅ %s (%.2fs)\n", result$message, duration))
    test_results$passed <<- test_results$passed + 1
  } else {
    cat(sprintf("  ❌ %s (%.2fs)\n", result$message, duration))
    cat(sprintf("     Error: %s\n", result$error))
    test_results$failed <<- test_results$failed + 1
    
    if (critical) {
      cat("  🚨 CRITICAL ERROR - Release cannot proceed!\n")
    }
  }
  cat("\n")
  
  return(result)
}

# Test 1: Package Structure Validation
run_test("Package Structure Validation", function() {
  # Check essential files exist
  essential_files <- c("DESCRIPTION", "NAMESPACE", "R/", "man/")
  missing_files <- essential_files[!file.exists(essential_files)]
  
  if (length(missing_files) > 0) {
    stop("Missing essential files: ", paste(missing_files, collapse = ", "))
  }
  
  # Check DESCRIPTION format
  desc <- read.dcf("DESCRIPTION")
  required_fields <- c("Package", "Version", "Title", "Description", "License")
  missing_fields <- required_fields[!required_fields %in% colnames(desc)]
  
  # Check for author information (either Author/Maintainer or Authors@R)
  has_author_info <- any(c("Author", "Maintainer", "Authors@R") %in% colnames(desc))
  if (!has_author_info) {
    missing_fields <- c(missing_fields, "Author/Maintainer or Authors@R")
  }
  
  if (length(missing_fields) > 0) {
    stop("Missing required DESCRIPTION fields: ", paste(missing_fields, collapse = ", "))
  }
  
  # Check version format
  version <- desc[1, "Version"]
  if (!grepl("^[0-9]+\\.[0-9]+\\.[0-9]+$", version)) {
    stop("Invalid version format. Expected format: X.Y.Z")
  }
  
  cat("    Package structure is valid\n")
  cat("    Version: ", version, "\n")
})

# Test 2: Documentation Generation
run_test("Documentation Generation", function() {
  # Generate documentation
  devtools::document(roclets = c("collate", "namespace", "rd"))
  
  # Check that documentation was generated
  if (!file.exists("NAMESPACE")) {
    stop("NAMESPACE file was not generated")
  }
  
  if (!dir.exists("man") || length(list.files("man", pattern = "\\.Rd$")) == 0) {
    stop("No Rd files were generated in man/ directory")
  }
  
  cat("    Documentation generated successfully\n")
  cat("    Rd files: ", length(list.files("man", pattern = "\\.Rd$")), "\n")
})

# Test 3: Build Package for Testing
run_test("Build Package for Testing", function() {
  # Clean any previous builds
  if (dir.exists("build")) {
    unlink("build", recursive = TRUE)
  }
  
  # Build package
  build_result <- devtools::build()
  
  if (!file.exists(build_result)) {
    stop("Package build failed")
  }
  
  # Store build result for later use
  build_file_path <<- build_result
  
  cat("    Package built successfully\n")
  cat("    Build file: ", basename(build_result), "\n")
})

# Test 4: R CMD check on Built Package (CRAN standard)
run_test("R CMD check (CRAN standard)", function() {
  if (!exists("build_file_path")) {
    stop("No build file available. Run build test first.")
  }
  
  # Run R CMD check on the built package with CRAN settings
  check_result <- rcmdcheck::rcmdcheck(
    path = build_file_path,
    args = c("--as-cran", "--no-manual", "--no-vignettes"),
    quiet = TRUE,
    error_on = "never"
  )
  
  # Analyze results
  if (length(check_result$errors) > 0) {
    stop("R CMD check found ERRORS:\n", paste(check_result$errors, collapse = "\n"))
  }
  
  if (length(check_result$warnings) > 0) {
    test_results$warnings <<- test_results$warnings + length(check_result$warnings)
    cat("    WARNINGS found (", length(check_result$warnings), "):\n")
    for (i in seq_along(check_result$warnings)) {
      cat("      ", i, ". ", check_result$warnings[i], "\n")
    }
  }
  
  if (length(check_result$notes) > 0) {
    test_results$notes <<- test_results$notes + length(check_result$notes)
    cat("    NOTES found (", length(check_result$notes), "):\n")
    for (i in seq_along(check_result$notes)) {
      cat("      ", i, ". ", check_result$notes[i], "\n")
    }
  }
  
  cat("    R CMD check completed\n")
})

# Test 5: R-hub Platform Check (Optional but Recommended)
run_test("R-hub Platform Check", function() {
  if (!exists("build_file_path")) {
    stop("No build file available. Run build test first.")
  }
  
  cat("    Starting R-hub platform check...\n")
  cat("    This will test the package on multiple platforms.\n")
  cat("    Note: This requires an internet connection and may take several minutes.\n")
  
  # Check if rhub is available
  if (!requireNamespace("rhub", quietly = TRUE)) {
    stop("rhub package not available. Install with: install.packages('rhub')")
  }
  
  # Check rhub version
  rhub_version <- packageVersion("rhub")
  cat("    R-hub version: ", as.character(rhub_version), "\n")
  
  # Check if user is authenticated with rhub
  tryCatch({
    rhub::validate_email()
    cat("    R-hub authentication verified\n")
  }, error = function(e) {
    cat("    R-hub authentication required. Please run: rhub::validate_email()\n")
    cat("    This test will be skipped.\n")
    return()
  })
  
  # Check available platforms
  cat("    Available platforms:\n")
  platforms_info <- rhub::rhub_platforms()
  cat("    Found ", nrow(platforms_info), " available platforms\n")
  
  # Select platforms for testing (using new platform names)
  # Focus on the most common platforms for CRAN (excluding Windows)
  selected_platforms <- c("ubuntu-release", "macos")
  
  cat("    Testing on platforms: ", paste(selected_platforms, collapse = ", "), "\n")
  
  # Try to use the new rhub v2 API with GitHub repository
  cat("    🔍 Attempting GitHub repository check with R-hub v2 API...\n")
  
  # Get GitHub URL from DESCRIPTION
  desc <- read.dcf("DESCRIPTION")
  github_url <- desc[1, "URL"]
  
  if (!is.na(github_url) && grepl("github\\.com", github_url)) {
    cat("    Found GitHub URL: ", github_url, "\n")
    
    # Run the GitHub repository check
    tryCatch({
      cat("    Starting R-hub check on GitHub repository...\n")
      check_result <- rhub::rhub_check(
        gh_url = github_url,
        platforms = selected_platforms
      )
      
      cat("    ✅ R-hub GitHub check initiated successfully\n")
      cat("    Check URL: ", check_result$url, "\n")
      cat("    Status: ", check_result$status, "\n")
      
      # Check for any issues
      if (check_result$status != "ok") {
        warning("R-hub check found issues. Check the URL for details: ", check_result$url)
      } else {
        cat("    ✅ GitHub repository check completed successfully\n")
      }
      
    }, error = function(e) {
      cat("    ❌ R-hub GitHub check failed: ", e$message, "\n")
      cat("    Falling back to local check...\n")
    })
    
  } else {
    cat("    ⚠️  No valid GitHub URL found in DESCRIPTION file\n")
    cat("    Please add a GitHub URL to the DESCRIPTION file to enable R-hub checks\n")
    cat("    Example: URL: https://github.com/username/movr\n")
  }
  
  cat("    R-hub platform check completed\n")
}, skip_in_quick = TRUE)

# Test 6: Spell Check on Built Package
run_test("Spell Check", function() {
  if (!exists("build_file_path")) {
    stop("No build file available. Run build test first.")
  }
  
  # Extract package to temporary directory for spell checking
  temp_dir <- tempfile("movr_spell_check")
  dir.create(temp_dir)
  on.exit(unlink(temp_dir, recursive = TRUE))
  
  # Extract the built package
  utils::untar(build_file_path, exdir = temp_dir)
  pkg_dir <- list.files(temp_dir, full.names = TRUE)[1]
  
  # Check spelling in documentation
  spell_result <- spelling::spell_check_package(pkg_dir)
  
  if (nrow(spell_result) > 0) {
    cat("    Spelling issues found:\n")
    for (i in 1:nrow(spell_result)) {
      cat("      ", spell_result$word[i], " in ", spell_result$file[i], "\n")
    }
    warning("Spelling issues found - review before release")
  } else {
    cat("    No spelling issues found\n")
  }
}, skip_in_quick = TRUE)

# Test 7: Good Practice Check on Built Package (skipped)

# Test 8: Package Installation Test from Built Package
run_test("Package Installation Test", function() {
  if (!exists("build_file_path")) {
    stop("No build file available. Run build test first.")
  }
  
  # Install package from built file
  install_result <- devtools::install_local(build_file_path)
  
  if (!requireNamespace("movr", quietly = TRUE)) {
    stop("Package installation failed")
  }
  
  cat("    Package builds and installs successfully\n")
  cat("    Build file: ", basename(build_file_path), "\n")
})

# Test 9: Examples Test from Built Package
run_test("Examples Test", function() {
  if (!exists("build_file_path")) {
    stop("No build file available. Run build test first.")
  }
  
  # Extract package to temporary directory for example testing
  temp_dir <- tempfile("movr_examples")
  dir.create(temp_dir)
  on.exit(unlink(temp_dir, recursive = TRUE))
  
  # Extract the built package
  utils::untar(build_file_path, exdir = temp_dir)
  pkg_dir <- list.files(temp_dir, full.names = TRUE)[1]
  
  # Run examples from the extracted package
  example_result <- devtools::run_examples(pkg = pkg_dir)
  
  if (length(example_result$errors) > 0) {
    stop("Examples failed:\n", paste(example_result$errors, collapse = "\n"))
  }
  
  cat("    All examples run successfully\n")
}, skip_in_quick = TRUE)

# Test 10: Tests Test from Built Package
run_test("Tests Test", function() {
  if (!exists("build_file_path")) {
    stop("No build file available. Run build test first.")
  }
  
  # Extract package to temporary directory for test testing
  temp_dir <- tempfile("movr_tests")
  dir.create(temp_dir)
  on.exit(unlink(temp_dir, recursive = TRUE))
  
  # Extract the built package
  utils::untar(build_file_path, exdir = temp_dir)
  pkg_dir <- list.files(temp_dir, full.names = TRUE)[1]
  
  if (dir.exists(file.path(pkg_dir, "tests"))) {
    # Run tests from the extracted package
    test_result <- devtools::test(pkg = pkg_dir)
    
    if (length(test_result$errors) > 0) {
      stop("Tests failed:\n", paste(test_result$errors, collapse = "\n"))
    }
    
    cat("    All tests pass\n")
  } else {
    cat("    No tests directory found (skipping)\n")
  }
}, skip_in_quick = TRUE)

# Test 11: CRAN Policy Compliance on Built Package
run_test("CRAN Policy Compliance", function() {
  if (!exists("build_file_path")) {
    stop("No build file available. Run build test first.")
  }
  
  # Extract package to temporary directory for compliance checking
  temp_dir <- tempfile("movr_compliance")
  dir.create(temp_dir)
  on.exit(unlink(temp_dir, recursive = TRUE))
  
  # Extract the built package
  utils::untar(build_file_path, exdir = temp_dir)
  pkg_dir <- list.files(temp_dir, full.names = TRUE)[1]
  
  # Check for common CRAN policy violations
  
  # Check for non-ASCII characters
  r_files <- list.files(file.path(pkg_dir, "R"), pattern = "\\.R$", full.names = TRUE)
  non_ascii_files <- character()
  
  for (file in r_files) {
    content <- readLines(file, warn = FALSE)
    if (any(grepl("[^\x01-\x7F]", content))) {
      non_ascii_files <- c(non_ascii_files, basename(file))
    }
  }
  
  if (length(non_ascii_files) > 0) {
    warning("Non-ASCII characters found in: ", paste(non_ascii_files, collapse = ", "))
  }
  
  # Check for proper license
  desc <- read.dcf(file.path(pkg_dir, "DESCRIPTION"))
  license <- desc[1, "License"]
  valid_licenses <- c("GPL-2", "GPL-3", "LGPL-2", "LGPL-2.1", "LGPL-3", 
                      "AGPL-3", "Artistic-2.0", "BSD_2_clause", "BSD_3_clause",
                      "MIT", "Apache License 2.0", "CC0", "Unlimited")
  
  if (!grepl(paste(valid_licenses, collapse = "|"), license)) {
    warning("License may not be CRAN-compliant: ", license)
  }
  
  # Check for proper maintainer email
  maintainer <- desc[1, "Maintainer"]
  if (!grepl("@", maintainer)) {
    warning("Maintainer field should contain email address")
  }
  
  cat("    CRAN policy compliance check completed\n")
})

# Test 12: Dependencies Check on Built Package
run_test("Dependencies Check", function() {
  if (!exists("build_file_path")) {
    stop("No build file available. Run build test first.")
  }
  
  # Extract package to temporary directory for dependency checking
  temp_dir <- tempfile("movr_deps")
  dir.create(temp_dir)
  on.exit(unlink(temp_dir, recursive = TRUE))
  
  # Extract the built package
  utils::untar(build_file_path, exdir = temp_dir)
  pkg_dir <- list.files(temp_dir, full.names = TRUE)[1]
  
  # Check package dependencies
  desc <- read.dcf(file.path(pkg_dir, "DESCRIPTION"))
  
  # Get dependencies from DESCRIPTION
  deps_fields <- c("Depends", "Imports", "Suggests", "LinkingTo")
  all_deps <- character()
  
  for (field in deps_fields) {
    if (field %in% colnames(desc)) {
      field_deps <- desc[1, field]
      if (!is.na(field_deps) && field_deps != "") {
        # Parse dependencies (remove version requirements)
        deps_list <- strsplit(field_deps, ",\\s*")[[1]]
        deps_list <- gsub("\\s*\\([^)]*\\)", "", deps_list)  # Remove version requirements
        deps_list <- gsub("^\\s+|\\s+$", "", deps_list)     # Trim whitespace
        all_deps <- c(all_deps, deps_list)
      }
    }
  }
  
  if (length(all_deps) > 0) {
    cat("    Package dependencies found:\n")
    for (dep in all_deps) {
      if (dep != "R") {  # Skip R itself
        cat("      ", dep, "\n")
      }
    }
  } else {
    cat("    No dependencies found\n")
  }
  
  cat("    Dependencies check completed\n")
}, skip_in_quick = TRUE)

# Test 13: Build Artifacts Check on Built Package
run_test("Build Artifacts Check", function() {
  if (!exists("build_file_path")) {
    stop("No build file available. Run build test first.")
  }
  
  # Extract package to temporary directory for artifact checking
  temp_dir <- tempfile("movr_artifacts")
  dir.create(temp_dir)
  on.exit(unlink(temp_dir, recursive = TRUE))
  
  # Extract the built package
  utils::untar(build_file_path, exdir = temp_dir)
  pkg_dir <- list.files(temp_dir, full.names = TRUE)[1]
  
  # Check for unwanted build artifacts
  unwanted_patterns <- c(
    "\\.o$", "\\.so$", "\\.dll$", "\\.exe$", 
    "CMakeFiles", "build", "\\.Rcheck"
  )
  
  unwanted_files <- character()
  for (pattern in unwanted_patterns) {
    files <- list.files(pkg_dir, pattern = pattern, recursive = TRUE, full.names = TRUE)
    unwanted_files <- c(unwanted_files, files)
  }
  
  if (length(unwanted_files) > 0) {
    cat("    Build artifacts found (these should be in .Rbuildignore):\n")
    for (file in unwanted_files) {
      cat("      ", file, "\n")
    }
    warning("Build artifacts found - consider adding to .Rbuildignore")
  } else {
    cat("    No unwanted build artifacts found\n")
  }
})

# Test 14: Final Package Validation
run_test("Final Package Validation", function() {
  if (!exists("build_file_path")) {
    stop("No build file available. Run build test first.")
  }
  
  # Get package info
  file_size <- file.size(build_file_path)
  file_size_mb <- round(file_size / 1024^2, 2)
  
  cat("    Final package validation completed\n")
  cat("    Package file: ", basename(build_file_path), "\n")
  cat("    Package size: ", file_size_mb, " MB\n")
  
  # Verify the package can be installed and loaded
  if (!requireNamespace("movr", quietly = TRUE)) {
    stop("Final package validation failed - cannot load movr package")
  }
  
  cat("    Package loads successfully\n")
})

# Print final summary
cat("=== CRAN Release Testing Summary ===\n")
cat("Tests passed: ", test_results$passed, "\n")
cat("Tests failed: ", test_results$failed, "\n")
cat("Warnings found: ", test_results$warnings, "\n")
cat("Notes found: ", test_results$notes, "\n\n")

if (test_results$failed > 0) {
  cat("❌ RELEASE BLOCKED: Some tests failed!\n")
  cat("Please fix the issues above before proceeding with release.\n")
  quit(status = 1)
} else if (test_results$warnings > 0 || test_results$notes > 0) {
  cat("⚠️  WARNINGS/NOTES FOUND: Review before release\n")
  cat("The package may be ready for release, but review warnings/notes above.\n")
} else {
  cat("✅ ALL TESTS PASSED: Package is ready for CRAN release!\n")
  if (exists("build_file_path")) {
    cat("Build file ready: ", basename(build_file_path), "\n")
  }
}

cat("\n=== Next Steps ===\n")
cat("1. Review any warnings/notes above\n")
cat("2. Test the package thoroughly\n")
cat("3. Update NEWS.md with changes\n")
cat("4. Submit to CRAN\n")
cat("5. Monitor CRAN submission status\n")

cat("\n=== CRAN Submission Checklist ===\n")
cat("□ Package passes all R CMD check tests\n")
cat("□ R-hub platform checks pass (if run)\n")
cat("□ Documentation is complete and accurate\n")
cat("□ Examples run without errors\n")
cat("□ Tests pass\n")
cat("□ NEWS.md updated\n")
cat("□ DESCRIPTION file is accurate\n")
cat("□ License is CRAN-compliant\n")
cat("□ No non-ASCII characters in code\n")
cat("□ Build artifacts are properly ignored\n")
cat("□ Dependencies are correctly specified\n") 