#!/bin/bash
# Wrapper script to run the documentation generation
# This script calls the main documentation script from the scripts folder

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Run the documentation generation script from the scripts folder
exec Rscript "$SCRIPT_DIR/render_docs.R" "$@" 