#!/bin/bash

# Set the path to your text file
TXT_FILE="../data/raw/presurg_mri_filenames.txt"
OUTPUT_FILE="../data/raw/presurg_mri"
SEARCH_DIR="../data/raw/resectMap_nifti_only_20240430"
NOT_FOUND_FILE="../data/raw/files_not_found.txt"
HPC_USERNAME="apelzer"
HPC_HOST="m3.massive.org.au"
HPC_DEST_DIR="~/vn36_scratch/apelzer/engel_mri/raw"

# Clear the not found file at the start of the script
> "$NOT_FOUND_FILE"

# Read the text file line by line
echo "Starting the file copy process..."
while IFS= read -r FILENAME
do
  # Remove carriage return character and leading/trailing whitespaces
  CLEANED_FILENAME=$(echo $FILENAME | tr -d '\r' | xargs)

  # Check if the filename is not empty
  if [[ -n "$CLEANED_FILENAME" ]]; then
    echo "Finding and copying file: $CLEANED_FILENAME"
    
    # Find the file by name in the specified search directory and its subdirectories
    FILE_PATH=$(find "$SEARCH_DIR" -type f -name "$CLEANED_FILENAME")
    
    # Debugging information to see where the script is looking
    echo "Searching for $CLEANED_FILENAME in $SEARCH_DIR"
    
    # Check if the file exists
    if [[ -f "$FILE_PATH" ]]; then
      # Copy the file to the destination directory
      #scp "$FILE_PATH" ${HPC_USERNAME}@${HPC_HOST}:${HPC_DEST_DIR}
      cp "$FILE_PATH" "$OUTPUT_FILE"
      
      if [[ $? -eq 0 ]]; then
        echo "Successfully copied $FILE_PATH"
      else
        echo "Failed to copy $FILE_PATH"
      fi
    else
      echo "File not found: $CLEANED_FILENAME"
      # Log the not found file
      echo "$CLEANED_FILENAME" >> "$NOT_FOUND_FILE"
    fi
  else
    echo "Empty filename encountered, skipping..."
  fi
done < "$TXT_FILE"
echo "File copy process completed."