#!/bin/bash
#SBATCH -p jic-training
#SBATCH -t 2-00:00
#SBATCH -c 4
#SBATCH --mem=50000
#SBATCH -o /jic/scratch/groups/Philippa-Borrill/Ismael/FastQC-raw-data/slurm/fastqc_REGALLO.%N.%j.out
#SBATCH -e /jic/scratch/groups/Philippa-Borrill/Ismael/FastQC-raw-data/slurm/fastqc_REGALLO.%N.%j.err
#SBATCH --mail-user=ismael.gutierrez-fernandez\@jic.ac.uk
#SBATCH --mail-type=END,FAIL

source package /nbi/software/production/bin/fastqc-0.11.8 # Load the fatsqc software from the HPC catalogue

cd /jic/scratch/groups/Philippa-Borrill/Ismael/raw-data/Samples_1-15_43-45/X204SC24112662-Z01-F001_01/X204SC24112662-Z01-F001_01/01.RawData # Go to the folder that contains all the sample folders/directories

pathDir=(R*) # Make an array with all the directories starting their name with: "C" (CIMMYT variety), "R" (Regallo), "G" (Gazul)

for dir in "${pathDir[@]}" # Run the loop in each directory that the array contains
do
# run the fastqc loop and save them in the specific folder
for f in "$dir/"*fq.gz;
do srun fastqc *.fq.gz -o /jic/scratch/groups/Philippa-Borrill/Ismael/FastQC-raw-data/REGALLO *.fastq.gz -t 4 $f;
done
done