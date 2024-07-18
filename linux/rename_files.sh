#!/bin/bash

# Check minimum required arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 <target_directory> <regex_pattern_to_match> [<substitution>]"
    exit 1
fi

TARGET_DIR=$1
REGEX=$2
SUBSTITUTION=${3:-}

# Find matching files and prepare for renaming
echo "Preparing to rename files in $TARGET_DIR..."
echo "Matching pattern: $REGEX"
echo "Substitution: '${SUBSTITUTION}'"
echo

# Using find to safely handle filenames with spaces and newlines
while IFS= read -r -d '' file; do
    filename=$(basename -- "$file")
    new_filename=$(echo "$filename" | perl -pe "s/$REGEX/$SUBSTITUTION/g")
    
    # Only process files that will be changed
    if [[ "$filename" != "$new_filename" ]]; then
        echo "$filename -> $new_filename"
        files_to_rename+=("$file")
        new_filenames+=("$TARGET_DIR/$new_filename")
    fi
done < <(find "$TARGET_DIR" -type f -print0)

if [ ${#files_to_rename[@]} -eq 0 ]; then
    echo "No files need renaming."
    exit 0
fi

echo
read -p "Proceed with renaming? (y/N) " confirm

if [[ $confirm =~ ^[Yy]$ ]]; then
    for ((i = 0; i < ${#files_to_rename[@]}; i++)); do
        mv -- "${files_to_rename[$i]}" "${new_filenames[$i]}"
        echo "Renamed: ${files_to_rename[$i]} -> ${new_filenames[$i]}"
    done
else
    echo "Renaming canceled."
fi
