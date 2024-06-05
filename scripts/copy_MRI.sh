#!/bin/bash

# Set the path to your CSV file
CSV_FILE="../data/processed/MRI_file_path.csv"
HPC_USERNAME="apelzer"
HPC_HOST="m3.massive.org.au"
HPC_DEST_DIR="~/vn36_scratch/apelzer/engel_mri/raw"

# Read the CSV file line by line
echo "Starting the file copy process..."
tail -n +2 $CSV_FILE | while IFS=',' read -r ParticipantID surg_engel ScanPath
do
  # Remove carriage return character, the extra directory level from the ScanPath, and change \ to /
  CORRECTED_PATH=$(echo $ScanPath | tr -d '\r' | sed 's|\.\./||' | sed 's|\\|/|g')

  # Check if the ScanPath is not empty
  if [[ -n "$CORRECTED_PATH" ]]; then
    echo "Copying file for ParticipantID $ParticipantID: $CORRECTED_PATH"
    # Copy the file to the HPC
    #scp $CORRECTED_PATH ${HPC_USERNAME}@${HPC_HOST}:${HPC_DEST_DIR}
    cp $CORRECTED_PATH mri

    if [[ $? -eq 0 ]]; then
      echo "Successfully copied $CORRECTED_PATH to ${HPC_DEST_DIR}"
    else
      echo "Failed to copy $CORRECTED_PATH"
    fi
  else
    echo "No file path for ParticipantID $ParticipantID"
  fi
done
echo "File copy process completed."