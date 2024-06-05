#!/bin/bash

# Define the reference image path
REFERENCE="$FSLDIR/data/standard/MNI152_T1_2mm.nii.gz"

# Directory where your MRI datasets are stored
input_folder="bet"
output_folder="flirt_bet"

# Create the output folder if it doesn't exist
mkdir -p "$output_folder"

# Check if FSLDIR is set
if [ -z "$FSLDIR" ]; then
    echo "Error: FSLDIR is not set. Please ensure FSL is properly installed and FSLDIR is exported."
    exit 1
fi

# Check if the dataset directory exists
if [ ! -d "$input_folder" ]; then
    echo "Error: input directory '$input_folder' does not exist."
    exit 1
fi

echo "Starting registration process..."

# Function to perform registration
perform_registration() {
    local f="$1"
    local file_name=$(basename "$f")
    local out_image="$output_folder/${file_name%%.*}_registered.nii.gz"
    # local out_matrix="$output_folder/${file_name%%.*}_transformation.mat"

    if [ -f "$out_image" ]; then
        echo "Skipping registration for $file_name: Output file already exists."
        return
    fi

    echo "Processing file: $file_name"
    flirt -in "$f" -ref "$REFERENCE" -out "$out_image" -cost corratio -dof 12 -interp trilinear # -omat "$out_matrix"

    if [ $? -eq 0 ]; then
        echo "Registration successful for $file_name"
    else
        echo "Registration failed for $file_name"
    fi
}

export -f perform_registration
export REFERENCE
export output_folder

# Find all MRI files and process them in parallel
find "$input_folder" -type f -name "*_T1w.nii*" | parallel perform_registration

echo "Registration process completed."
