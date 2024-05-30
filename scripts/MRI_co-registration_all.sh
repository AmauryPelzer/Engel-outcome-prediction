#!/bin/bash

# Define the reference image path
REFERENCE="$FSLDIR/data/standard/MNI152_T1_1mm.nii.gz"

# Directory where your MRI datasets are stored
DATASET_DIR="../data/raw/resectMap_nifti_only_20240430"

# Check if FSLDIR is set
if [ -z "$FSLDIR" ]; then
    echo "Error: FSLDIR is not set. Please ensure FSL is properly installed and FSLDIR is exported."
    exit 1
fi

# Check if the dataset directory exists
if [ ! -d "$DATASET_DIR" ]; then
    echo "Error: Dataset directory '$DATASET_DIR' does not exist."
    exit 1
fi

echo "Starting registration process..."

# Loop through all subdirectories and files
find "$DATASET_DIR" -type f -name "*_T1w.nii*" | while read f; do
    # Extract directory and filename
    file_dir=$(dirname "$f")
    file_name=$(basename "$f")
    
    # Define output files
    out_image="$file_dir/${file_name%%.*}_registered.nii.gz"
    #out_matrix="$file_dir/${file_name%%.*}_transformation.mat"
    
    # Check if the output file already exists
    if [ -f "$out_image" ]; then
        echo "Skipping registration for $file_name: Output file already exists."
        continue  # Skip this iteration and move to the next file
    fi

    echo "Processing file: $file_name"
    
    # Run FLIRT
    flirt -in "$f" -ref "$REFERENCE" -out "$out_image" -cost corratio -dof 12 -interp trilinear #-omat "$out_matrix"
    
    if [ $? -eq 0 ]; then
        echo "Registration successful for $file_name"
    else
        echo "Registration failed for $file_name"
    fi
done

echo "Registration process completed."
