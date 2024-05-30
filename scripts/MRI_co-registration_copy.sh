#!/bin/bash

# Define the reference image path
REFERENCE="$FSLDIR/data/standard/MNI152_T1_1mm.nii.gz"

# CSV file containing the paths
CSV_FILE="data/processed/MRI_file_path.csv"

# Check if FSLDIR is set
if [ -z "$FSLDIR" ]; then
    echo "Error: FSLDIR is not set. Please ensure FSL is properly installed and FSLDIR is exported."
    exit 1
fi

# Check if the CSV file exists
if [ ! -f "$CSV_FILE" ]; then
    echo "Error: CSV file '$CSV_FILE' does not exist."
    exit 1
fi

echo "Starting registration process..."

# Read the CSV file line by line
while IFS=, read -r ParticipantID surg_engel ScanPath; do
    # Skip the header
    if [[ "$ParticipantID" == "ParticipantID" ]]; then
        continue
    fi

    # Skip rows with empty ScanPath
    if [[ -z "$ScanPath" ]]; then
        echo "Skipping $ParticipantID: No ScanPath provided."
        continue
    fi

    # Adjust the ScanPath to remove the unnecessary "../" and replace backslashes with forward slashes
    corrected_path=$(echo "$ScanPath" | sed 's@^\.\./\.\.@@' | tr '\\' '/')



    # Extract directory and filename
    file_dir=$(dirname "$corrected_path")
    file_name=$(basename "$corrected_path")

    # Define output files
    out_image="$file_dir/${file_name%%.*}_registered.nii.gz"

    # Check if the output file already exists
    if [ -f "$out_image" ]; then
        echo "Skipping registration for $file_name: Output file already exists."
        continue  # Skip this iteration and move to the next file
    fi

    echo "Processing file: $file_name"

    # Run FLIRT
    flirt -in "$corrected_path" -ref "$REFERENCE" -out "$out_image" -cost corratio -dof 12 -interp trilinear

    if [ $? -eq 0 ]; then
        echo "Registration successful for $file_name"
    else
        echo "Registration failed for $file_name"
    fi
done < "$CSV_FILE"

echo "Registration process completed."
