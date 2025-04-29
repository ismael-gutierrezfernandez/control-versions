#!/usr/bin/perl -w

# script obtained from Philippa.borrill, modified by Arunkumar Ramesh, modified by Ismael Gutierrez-Fernandez
#
# Aim of script is to run kallisto on RNA-seq for multiple samples to a common reference to calculate expression levels

#### paths and references:
my $path = '/jic/scratch/groups/Philippa-Borrill/References/tetraploid_references/Chinese_Spring_without_D';
my $ref = "$path/IWGSC_v1.1_ALL_20170706_transcripts_noD.fasta";
my $index = "$path/IWGSC_v1.1_ALL_20170706_transcripts_noD.fasta_index";

#############################

# NB make index by kallisto index  -i IWGSC_v1.1_ALL_20170706_transcripts_index IWGSC_v1.1_ALL_20170706_transcripts.fasta

my $read_path_triticum = "/jic/scratch/groups/Philippa-Borrill/Ismael/data-trimmed/fastp-trim/REGALLO";
my $output_dir = "/jic/scratch/groups/Philippa-Borrill/Ismael/pseudoalignment-kallisto/REGALLO_CS_reference/REGALLO_LWD";

### lists of samples (text file containing directory/subdirectory with .fastq to map e.g. each line should look like: ERP004505/ERR392073/ in these subdirectories are the fastq.gz - text file must be in $output_dir):
my $input_for_kallisto = "/jic/scratch/groups/Philippa-Borrill/Ismael/pseudoalignment-kallisto/REGALLO_CS_reference/REGALLO_LWD/kallisto_input_REGALLO_LWD.txt";


#############################

#open the input file and go through the lines one by one so go to each directories where the fastq.gz should be located
chdir("$read_path_triticum") or die "couldn't move to input directory";

open (INPUT_FILE, "$input_for_kallisto") || die "couldn't open the input file $input_for_kallisto!";
		    while (my $line = <INPUT_FILE>) {
			chomp $line;
my @array = split(/\t/,$line);
#print "\nmy line was: $line\n";

#print "\nmy array: @array\n";
#print "\narray element 1: @array[0]\n";

my $sample = $array[0]; # The input file has 1 + n (sample_files.fastq) columns. The first column is the name of the sample for the output files and correspond for the array[0]
my $pair_1_R1 = $array[1]; # Each array from [1] to [n] correspond for a sequence file that is related to that sample. The best is to write them as subdirectory/file_name.fastq.gz in the input file
my $pair_1_R2 = $array[2];
my $pair_2_R1 = $array[3];
my $pair_2_R2 = $array[4];
my $pair_3_R1 = $array[5];
my $pair_3_R2 = $array[6];


chdir("$read_path_triticum") or die "couldn't move to specific read directory";


my $SLURM_header = <<"SLURM";
#!/bin/bash
#
# SLURM batch script to launch parallel hisat2 tasks
#
#SBATCH -p jic-training
#SBATCH -t 0-05:00
#SBATCH -c 8
#SBATCH --mem=30000
#SBATCH -o /jic/scratch/groups/Philippa-Borrill/Ismael/pseudoalignment-kallisto/REGALLO_CS_reference/REGALLO_LWD/slurm/%x.%N.%j.out
#SBATCH -e /jic/scratch/groups/Philippa-Borrill/Ismael/pseudoalignment-kallisto/REGALLO_CS_reference/REGALLO_LWD/slurm/%x.%N.%j.err
#SBATCH --mail-user=ismael.gutierrez-fernandez\@jic.ac.uk
#SBATCH --mail-type=END,FAIL


SLURM

 my $tmp_file = "$output_dir/tmp/kallisto.$sample"; # Do not forget create the tmp folder in where the output of kallisto will be saved


  open (SLURM, ">$tmp_file") or die "Couldn't open temp file\n";
  $SLURM_header = $SLURM_header;
  print SLURM "$SLURM_header\n\n";
  print SLURM "\ncd $read_path_triticum\n";


  print SLURM "set -e\n";

	print SLURM "source package /nbi/software/testing/bin/kallisto-0.46.1\n"; # Load the packages, do not touch
	print SLURM "source package aeee87c4-1923-4732-aca2-f2aff23580cc\n";

	print SLURM "kallisto quant -i $index -o $output_dir/$sample -t 8 --pseudobam $pair_1_R1 $pair_1_R2 $pair_2_R1 $pair_2_R2 $pair_3_R1 $pair_3_R2 \n"; # --pseudobam is followed by each array pdefines above
	print SLURM "samtools sort -T $output_dir/$sample/$sample".".bam -O bam -o $output_dir/$sample".".sorted.bam -@ 8 $output_dir/$sample/pseudoalignments.bam\n";
  print SLURM "samtools index $output_dir/$sample".".sorted.bam $output_dir/$sample".".sorted.bai\n";
  print SLURM "rm $output_dir/$sample/pseudoalignments.bam\n";

	close SLURM;
  system("sbatch $tmp_file");
 # unlink $tmp_file;

}

	    close(INPUT_FILE);
