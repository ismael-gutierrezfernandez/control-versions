#!/bin/bash
#SBATCH -p jic-training
#SBATCH -t 2-00:00
#SBATCH -c 4
#SBATCH --mem=50000
#SBATCH -o fastqc.%N.%j.out
#SBATCH -e fastqc.%N.%j.err
#SBATCH --mail-user=ismael.gutierrez-fernandez\@jic.ac.uk
#SBATCH --mail-type=END,FAIL

source package /nbi/software/production/bin/fastqc-0.11.8 # Load the fatsqc software from the HPC catalogue

cd /jic/scratch/groups/Philippa-Borrill/raw_data/example_RNA_seq/fastq # Go to the folder that contains all the sample folders/directories

pathDir=(Sample*) # Make an array with all the directories starting his name with "Sample"

for dir in "${pathDir[@]}" # Run the loop in each directory that the array contains
do
# run the fastqc loop and save them in the specific folder
for f in "$dir/"*fastq.gz;
do srun fastqc *.fastq.gz -o /hpc-home/zik25cof/rna-training/fastqc_training *.fastq.gz -t 4 $f;
done
done