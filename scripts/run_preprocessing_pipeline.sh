#!/bin/bash

#SBATCH --job-name=mri_preprocessing
#SBATCH --output=mri_preprocessing.out
#SBATCH --error=mri_preprocessing.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --account=vn36
#SBATCH --time=16:00:00

# Load necessary modules
module load fsl
module load parallel

# Navigate to your script directory
cd ../vn36_scratch/apelzer/engel_mri/

# Execute bash scripts one by one
bash run_reorient.sh
bash run_flirt_raw.sh
bash run_bet.sh
bash run_flirt_bet.sh

echo "All scripts have completed."