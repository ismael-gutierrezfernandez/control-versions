#!/bin/bash
#SBATCH -p jic-training
#SBATCH -t 2-00:00
#SBATCH -c 4
#SBATCH --mem=50000
#SBATCH -o /jic/scratch/groups/Philippa-Borrill/Ismael/data-trimmed/HT41/FastQC-trimmed/slurm/fastqc-trimm-HT41.%N.%j.out
#SBATCH -e /jic/scratch/groups/Philippa-Borrill/Ismael/FastQC-raw-data/slurm/fastqc-trimm-HT41.%N.%j.err
#SBATCH --mail-user=ismael.gutierrez-fernandez\@jic.ac.uk
#SBATCH --mail-type=END,FAIL

source package /nbi/software/production/bin/fastqc-0.11.8 # Load the fatsqc software from the HPC catalogue

cd /jic/scratch/groups/Philippa-Borrill/Ismael/data-trimmed/HT41 # Go to the folder that contains all the sample folders/directories

pathDir=(HT41*) # Make an array with all the directories starting their name with: "HT41" (CIMMYT variety), "REG" (Regallo), "GAZ" (Gazul)

for dir in "${pathDir[@]}" # Run the loop in each directory that the array contains
do
# run the fastqc loop and save them in the specific folder
for f in "$dir/"*fq.gz;
do srun fastqc *.fq.gz -o /jic/scratch/groups/Philippa-Borrill/Ismael/data-trimmed/HT41/FastQC-trimmed *.fastq.gz -t 4 $f;
done
done