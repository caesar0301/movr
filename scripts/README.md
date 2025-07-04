# Scripts Directory

This directory contains all helper scripts for the movr package development, testing, and release process.

## 📁 Scripts Overview

### Core Scripts

#### `cran_release_check.R`
**Purpose**: Comprehensive R-based testing engine for CRAN release validation
- **12 test categories** covering all CRAN requirements
- **Detailed validation** with timing and reporting
- **CRAN policy compliance** checks
- **Automated issue detection** and reporting

**Usage**:
```bash
Rscript scripts/cran_release_check.R
```

#### `check_cran.sh`
**Purpose**: User-friendly wrapper for comprehensive CRAN release testing
- **Automatic dependency installation** for required R packages
- **Colored output** for better readability
- **Multiple check modes** (full/quick)
- **Interactive error handling** and help system

**Usage**:
```bash
./scripts/check_cran.sh
./scripts/check_cran.sh --quick
./scripts/check_cran.sh --install
```

#### `release.sh`
**Purpose**: Complete release workflow with integrated testing
- **Native code building** and documentation generation
- **Comprehensive CRAN testing** before release
- **Package building** and final verification
- **CRAN submission preparation**

**Usage**:
```bash
./scripts/release.sh
```

#### `render_docs.R`
**Purpose**: Automated documentation generation with validation
- **Enhanced NAMESPACE generation** with explicit imports
- **Automatic backup** and cleanup
- **Validation and quality assurance**
- **Error handling** for C extensions

**Usage**:
```bash
Rscript scripts/render_docs.R
```

## 🚀 Quick Access from Root Directory

For convenience, wrapper scripts are available in the root directory:

- `./release` - Run the complete release process
- `./check-cran` - Run CRAN release checks
- `./render-docs` - Generate documentation

## 📋 Script Dependencies

### Required R Packages
The scripts automatically manage these dependencies:
- `devtools` - Package development tools
- `roxygen2` - Documentation generation
- `spelling` - Spell checking
- `goodpractice` - Code quality assessment
- `rcmdcheck` - R CMD check wrapper

### System Requirements
- **R** (version 4.0.0 or higher)
- **Bash** shell environment
- **CMake** (for native code building)

## 🔧 Script Configuration

### Environment Variables
- `R_LIBS_USER` - Custom R library path (optional)
- `R_ENVIRON` - R environment configuration (optional)

### Command Line Options
Each script supports various command line options. Use `--help` to see available options:
```bash
./scripts/check_cran.sh --help
./scripts/release.sh --help
```

## 📊 Test Categories

The `cran_release_check.R` script performs 12 comprehensive test categories:

1. **Package Structure Validation** - Essential files, DESCRIPTION format
2. **Documentation Generation** - Roxygen2, NAMESPACE, Rd files
3. **R CMD check (CRAN Standard)** - Full CRAN validation
4. **Spell Check** - Documentation spelling validation
5. **Good Practice Check** - Coding standards and best practices
6. **Package Installation Test** - Build and install verification
7. **Examples Test** - Documentation examples execution
8. **Tests Test** - Unit test execution
9. **CRAN Policy Compliance** - Non-ASCII, license, maintainer
10. **Dependencies Check** - Package dependency analysis
11. **Build Artifacts Check** - Unwanted file detection
12. **Final Package Build** - Clean build and optimization

## 🎯 Usage Workflows

### Development Workflow
```bash
# 1. Make changes to R code
# 2. Regenerate documentation
./render-docs

# 3. Run quick check
./check-cran --quick

# 4. Fix any issues found
# 5. Repeat until clean
```

### Pre-Release Workflow
```bash
# 1. Run full CRAN check
./check-cran

# 2. Review warnings and notes
# 3. Fix critical issues
# 4. Update NEWS.md
# 5. Increment version number
```

### Release Workflow
```bash
# 1. Complete release process
./release

# 2. Review final package
# 3. Submit to CRAN
# 4. Monitor submission status
```

## 🔍 Troubleshooting

### Common Issues

#### Script Not Found
```bash
# Ensure scripts are executable
chmod +x scripts/*.sh scripts/*.R

# Check script paths
ls -la scripts/
```

#### Permission Denied
```bash
# Fix permissions
chmod +x scripts/*.sh
chmod +x release check-cran render-docs
```

#### R Package Dependencies
```bash
# Install required packages
./check-cran --install
```

### Error Resolution
1. **Check script permissions** - Ensure scripts are executable
2. **Verify R installation** - Ensure R is in PATH
3. **Install dependencies** - Use `--install` option
4. **Check working directory** - Run from package root
5. **Review error messages** - Check script output for details

## 📚 Related Documentation

- `../CRAN_RELEASE_GUIDE.md` - Comprehensive CRAN release guide
- `../ENHANCED_BUILD_SYSTEM_SUMMARY.md` - System overview
- `../DOCUMENTATION.md` - Documentation generation guide

## 🤝 Contributing

When adding new scripts:
1. **Place in scripts directory** - Keep root directory clean
2. **Update this README** - Document new scripts
3. **Add wrapper script** - If needed for root access
4. **Test thoroughly** - Ensure scripts work correctly
5. **Update documentation** - Keep guides current

---

**🎉 These scripts provide a comprehensive, automated testing and release system for the movr package!** 