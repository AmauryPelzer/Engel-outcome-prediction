#!/bin/bash

# Define the reference image path
REFERENCE="$FSLDIR/data/standard/MNI152_T1_2mm.nii.gz"
CONFIG="$FSLDIR/etc/flirtsch/T1_2_MNI152_2mm.cnf"

# Directory where your MRI datasets are stored
input_folder="reorient"
output_folder="fnirt"

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
    local base_name="${file_name%%.*}"
    local out_image="$output_folder/${base_name}_registered.nii.gz"
    local out_affine="$output_folder/${base_name}_affine.mat"
    local out_warp="$output_folder/${base_name}_warpfield.nii.gz"
    local out_jacobian="$output_folder/${base_name}_jacobian.nii.gz"

    if [ -f "$out_image" ]; then
        echo "Skipping registration for $file_name: Output file already exists."
        return
    fi

    echo "Processing file: $file_name"
    
    # Perform initial affine registration using FLIRT
    flirt -in "$f" -ref "$REFERENCE" -out "$out_image" -omat "$out_affine" -cost corratio -dof 12 -interp trilinear
    
    if [ $? -ne 0 ]; then
        echo "Affine registration failed for $file_name"
        return
    fi

    # Perform nonlinear registration using FNIRT
    fnirt --in="$f" --aff="$out_affine" --cout="$out_warp" --iout="$out_image" --jout="$out_jacobian" --config="$CONFIG" --ref="$REFERENCE"
    
    if [ $? -eq 0 ]; then
        echo "Registration successful for $file_name"
    else
        echo "Registration failed for $file_name"
    fi
}

export -f perform_registration
export REFERENCE
export CONFIG
export output_folder

# Find all MRI files and process them in parallel
find "$input_folder" -type f -name "*_T1w.nii*" | parallel perform_registration

echo "Registration process completed."
