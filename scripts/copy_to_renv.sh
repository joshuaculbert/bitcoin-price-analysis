#!/bin/bash

# copy_to_renv.sh
# Copies R packages and their dependencies from a source library to a renv library

# Check for correct number of arguments
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <package_list> <source_dir> <target_dir>"
    echo "Example: $0 'curl xts zoo' /home/joshua/R/x86_64-pc-linux-gnu-library/4.5 /path/to/renv/library"
    exit 1
fi

# Inputs
PACKAGE_LIST="$1"  # Space-separated package names (e.g., "curl xts zoo")
SOURCE_DIR="$2"    # Source library (e.g., /home/joshua/R/x86_64-pc-linux-gnu-library/4.5)
TARGET_DIR="$3"    # Target renv library (e.g., /path/to/renv/library/linux-ubuntu-jammy/R-4.5/x86_64-pc-linux-gnu)

# Validate inputs
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory $SOURCE_DIR does not exist"
    exit 1
fi
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Target directory $TARGET_DIR does not exist"
    exit 1
fi

# Convert space-separated package list to R vector format
R_PKGS=$(echo "$PACKAGE_LIST" | sed "s/ /', '/g" | sed "s/^/c('/" | sed "s/$/')/")

# Generate dependency list using R with explicit CRAN mirror
DEPENDENCIES=$(R --vanilla --slave -e "
options(repos = c(CRAN = 'https://cloud.r-project.org'))
pkgs <- $R_PKGS
deps <- tools::package_dependencies(pkgs, recursive = TRUE, which = c('Depends', 'Imports', 'LinkingTo'))
base_pkgs <- rownames(installed.packages(priority = 'base'))
all_pkgs <- setdiff(unique(unlist(deps)), base_pkgs)
all_pkgs <- unique(c(pkgs, all_pkgs))
cat(all_pkgs, sep = '\n')
" 2>/dev/null)  # Suppress R startup and error messages

# Check if R command failed
if [ $? -ne 0 ]; then
    echo "Error: Failed to generate dependency list with R"
    exit 1
fi

# Check and copy packages
MISSING_PKGS=""
for pkg in $DEPENDENCIES $PACKAGE_LIST; do
    if [ -d "$SOURCE_DIR/$pkg" ]; then
        if [ ! -d "$TARGET_DIR/$pkg" ]; then
            cp -r "$SOURCE_DIR/$pkg" "$TARGET_DIR/"
            echo "Copied: $pkg"
        else
            echo "Already exists: $pkg"
        fi
    else
        echo "Missing in source: $pkg"
        MISSING_PKGS="$MISSING_PKGS $pkg"
    fi
done

# Report missing packages
if [ -n "$MISSING_PKGS" ]; then
    echo "Warning: The following packages are missing in $SOURCE_DIR and need to be installed:"
    echo "$MISSING_PKGS"
    echo "Run in R: install.packages(c($(echo $MISSING_PKGS | sed "s/ /', '/g" | sed "s/^/'/" | sed "s/$/'/")))"
fi

echo "Done. Run 'renv::snapshot()' in R to update renv.lock."