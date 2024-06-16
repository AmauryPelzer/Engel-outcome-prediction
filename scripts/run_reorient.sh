#!/bin/bash

# Define the input and output folders
input_folder="raw"
output_folder="reorient"

# Create the output folder if it doesn't exist
mkdir -p "$output_folder"

# Function to reorient an MRI
reorient_mri() {
  local input_file=$1
  local output_file="$2"
  fslreorient2std "$input_file" "$output_file"
}

# Get the total number of files to process
total_files=$(find "$input_folder" -type f | wc -l)
processed_files=0

# Function to display the progress bar
show_progress() {
  local progress=$(($processed_files * 100 / $total_files))
  local done=$((progress * 4 / 10))
  local left=$((40 - done))
  local fill=$(printf "%${done}s")
  local empty=$(printf "%${left}s")

  printf "\rProgress : [${fill// /#}${empty// /-}] ${progress}%%"
}

# Loop through all MRI files in the input folder and process them sequentially
for input_file in "$input_folder"/*; do
  if [ -f "$input_file" ]; then
    output_file="${output_folder}/$(basename ${input_file%.*}).nii.gz"
    if [ ! -f "$output_file" ]; then
      reorient_mri "$input_file" "$output_file"
      ((processed_files++))
      show_progress
    else
      echo "File already exists: $output_file"
    fi
  fi
done

echo -e "\nReorientation complete."