#!/bin/bash

# Define the input and output folders
input_folder="reorient"
output_folder="bet"
f_parameter=0.5
g_parameter=0

# Create the output folder if it doesn't exist
mkdir -p "$output_folder"

# Function to extract the brain from an MRI
extract_brain() {
  local input_file=$1
  local output_file="${output_folder}/$(basename $input_file)"
  bet "$input_file" "$output_file" -f "$f_parameter" -g "$g_parameter"
  echo "Created: $output_file"
}

# Export the function and variables for use by parallel
export -f extract_brain
export output_folder
export f_parameter
export g_parameter

# Find all files in the input folder and process them in parallel
find "$input_folder" -type f | parallel -j $(nproc) extract_brain

echo -e "\nReorientation complete."