#!/usr/bin/perl -w

# ismael.gutierrez-fernandez@jci.ac.uk
# Script to run trimnomatic for multiple samples

## Firstly we indicate the path and direcftory where the files are sotored and where the output will be saved
my $read_path_triticum = "/jic/scratch/groups/Philippa-Borrill/Ismael/raw-data/Samples_16-42"; # Define the directory with the files
my $output_dir = "/jic/scratch/groups/Philippa-Borrill/Ismael/data-trimmed/HT41"; # Define the directory where trimmed files were will be stored (output)

## Secondly we specified the input of the samples. Previously, we need to make a .txt file with all the samples (see examples):
my $input_list_dir = "/jic/scratch/groups/Philippa-Borrill/Ismael/data-trimmed/inputs"; # Path for the folder where the list of samples is stored
my $input_for_trim = "/jic/scratch/groups/Philippa-Borrill/Ismael/data-trimmed/inputs/trimm_input_HT41_read2.txt"; # Path for the list.txt of samples itself
my $adapter_dir = "/jic/scratch/groups/Philippa-Borrill/scripts/adapter-files-for-trimmomatic"; # Path for the adapter files to run the trimnomatic

###############################################

## Now, the array of the files needs to be built.
# Open the input file (.txt), previousy defined, and go through the lines one by one so go to each directory where the fastq.gz should be located
chdir("$input_list_dir") or die "coulnd't open the input directory"; # Move to the input directory defined above

open (INPUT_FILE, "$input_for_trim") || die "couldn't open the input file $input_for_trim!"; # Open the input list (.txt) with the sample list
		    while (my $line = <INPUT_FILE>) {
			chomp $line;
my @array = split(/\t/,$line);
#print "\nmy line was: $line\n";

#print "\nmy array: @array\n";
#print "\narray element 1: @array[0]\n";

my $sample = $array[0];
my $f1 = $array[1];
my $f2 = $array[2];

chdir("$read_path_triticum") or die "could'nt move to specific read directory $read_path_triticum"; # Here we return to the folder were the raw files are stored

my $SLURM_header = <<"SLURM"; # Define the SLURM job and the submission information
#!/bin/bash
#
# SLURM batch script to launch parallel trimnomatic tasks
#
#SBATCH -p jic-training
#SBATCH -t 2-00:00
#SBATCH -c 4
#SBATCH --mem=120000
#SBATCH -o /jic/scratch/groups/Philippa-Borrill/Ismael/data-trimmed/slurm/%x.%N.%j.out
#SBATCH -e /jic/scratch/groups/Philippa-Borrill/Ismael/data-trimmed/slurm/%x.%N.%j.err
#SBATCH --mail-user=ismael.gutierrez-fernandez\@jic.ac.uk
#SBATCH --mail-type=END,FAIL
SLURM

 my $tmp_file = "$output_dir/tmp/trim.$sample"; # Previously, a folder with the name "tmp" needs to be created inside the output folder


  open (SLURM, ">$tmp_file") or die "Couldn't open temp file\n";
  $SLURM_header = $SLURM_header;
  print SLURM "$SLURM_header\n\n";
  print SLURM "\ncd $read_path_triticum\n";

  print SLURM "set -e\n";

  print SLURM "source package 50fcf79b-73a3-4f94-9553-5ed917823423\n";

	### Do not need to change this bit! ###
	print SLURM "trimmomatic PE -phred33 -threads 4 $f1 $f2 $output_dir/$sample/$sample"."_1.read2.paired.fq.gz $output_dir/$sample/$sample"."_1.read2.unpaired.fq.gz $output_dir/$sample/$sample"."_2.read2.paired.fq.gz $output_dir/$sample/$sample"."_2.read2.unpaired.fq.gz ILLUMINACLIP:$adapter_dir/TruSeq3-PE.fa:2:30:10 LEADING:3 SLIDINGWINDOW:4:15 MINLEN:80\n";

	close SLURM;
	system("sbatch $tmp_file");
# Unlink $tmp_file;
}

			close(INPUT_FILE);