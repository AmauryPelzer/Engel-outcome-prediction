#!/bin/bash

# Define the reference image path
REFERENCE="$FSLDIR/data/standard/MNI152_T1_1mm.nii.gz"

# Path to the CSV file, adjusted as per your update
CSV_PATH="../data/processed/MRI_file_path.csv"

# Get the absolute path of the CSV file
CSV_ABS_PATH=$(readlink -f "$CSV_PATH")

# Base directory is the root of your project, not just where the CSV is
# Assuming the script runs from a subdirectory in the project root
PROJECT_ROOT="/mnt/c/Users/amaur/The University of Melbourne/Engel-outcome-prediction"

# Start message
echo "Starting MRI registration process..."

# Read each line from the CSV starting from the second line (skipping the header)
tail -n +2 "$CSV_PATH" | while IFS=, read -r id engel path; do
    # Check if the path is not empty
    if [[ -n "$path" ]]; then
        # Convert Windows paths to Unix paths by replacing backslashes with slashes
        unix_path="${path//\\//}"

        # Remove the first two '../' from the path if they exist
        corrected_path="${unix_path#../../}"

        # Construct the full path using the PROJECT_ROOT
        full_path="$PROJECT_ROOT/$corrected_path"
        
        # Define output files
        file_dir=$(dirname "$full_path")
        file_name=$(basename "$full_path")
        out_image="$file_dir/${file_name%%.*}_registered.nii.gz"
        out_matrix="$file_dir/${file_name%%.*}_transformation.mat"
        
        # Print current processing file
        echo "Processing $file_name..."
        
        # Run FLIRT, ensuring all paths are quoted to handle spaces
        flirt -in "$full_path" -ref "$REFERENCE" -out "$out_image" -omat "$out_matrix" -cost corratio -dof 12 -interp trilinear
        
        # Check if FLIRT was successful and the output file was created
        if [[ -f "$out_image" ]]; then
            echo "Registration successful for $file_name"
        else
            echo "Error in registration for $file_name"
        fi
    else
        echo "No path provided for participant $id - skipping"
    fi
done

echo "MRI registration process completed."
