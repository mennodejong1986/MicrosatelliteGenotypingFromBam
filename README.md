# MicrosatelliteGenotypingFromBam

With the advent of next generation sequencing, SNPs (single nucleotide polymorphisms) have replaced microsatellites as the mainstream genetic marker. These SNP data sets are typically generated by mapping short sequencing reads to a reference genome (which generates bam-files), by subsequently using the information in the bam-files to call genotypes (i.e., determine for each site whether it is most likely homozygous reference, heterozygous, or homozygous alternative), and by lastly selecting the sites where for the given subset of individuals two or more alleles (i.e., A,C,G,T) are present. 

However, instead of extracting SNP data from the information stored in bam-files, why not extract microsatellite data? Given the relatively high mutation rate and allelic richness of microsatellites, one could even argue that microsatellites are a more informative genetic marker than biallelic SNPs. While traditional microsatellite studies are based on a limited number of markers (typically less than 30), whole genome resequencing data potentially contains information for many thousands of microsatellites.   

If you use this pipeline for your own research, please cite:

*de Jong, M.J., et al. Range-wide whole-genome resequencing of the brown bear reveals drivers of intraspecies divergence. Commun Biol 6, 153 (2023). https://doi.org/10.1038/s42003-023-04514-w*

## Workflow overview

The pipeline presented here extracts microsatellite data from input bam-files. The prerequisite is that the short read data has been mapped against a reference genome which has not been masked for repetitive genomes. Furthermore, the sequencing data should at least be 10x (preferably 20x or more), and the read lengths preferably not shorter than 150 bp.

The procedure to produce a microsatellite data set from bam-files involves computer work only (not wet lab stuff), and consists of the following five steps:

1. microsatellite loci selection: detect and select a set of microsatellite loci in a reference genome
2. microsatellite data extraction: extract the selected microsatellite loci from all individual genomes
3. allele scoring: count for each microsatellite locus the number of reads supporting each allele  
4. genotype calling: convert count data into genotypes using a decision tree
5. data quality filtering: filter individuals and loci on levels of missing data  

Albeit entirely computer-based, in a way each step of this pipeline resembles steps in the traditional wet-lab protocol of a microsatellite study, namely: 1.) primer selection/design, 2.) target-specific DNA-amplification through PCR, 3.) allele scoring through capillary electrophoresis, 4.) genotype calling using a decision tree, and .5) data quality filtering.     

## Step 1. Select a set of microsatellite loci

Microsatellites in a reference genome can be detected using the software TRFfinder, by running the command:

*./trf409.linux64 mygenome.fa 2 7 7 80 10 50 6 -d -h &*

The -h flag is needed to surpress output files we do not need (which otherwise will overload your directory).

The output file will be named 'mygenome.fa.2.7.7.80.10.50.6.dat.' To select microsatellites tetranucleotide microsatellites with a repeat length of 7 to 9 units, and to store the information for these loci in BED-format, run the script 'FASTA_findmicrosats_TRFoutput2BED.sh'. (You may want to edit the script if you want to select loci with different period and/or repeat lengths.) 

## Step 2. Extract selected microsatellites from genomes 

In traditional microsatellite studies, PCR is used to selectively amplify the regions of interest, which effectively serves to extract the microsat loci out of the genome. In this bioinformatics pipeline we use a different approach to extract the microsats: namely, we downsample the bam-files by only keeping reads which overlap with the selected microsatellites. In other words: we discard all reads which do not overlap with a microsatellite region (which will be the vast majority). The small bam-files which are created by this step are much faster to process in the subsequent steps than if using the original bam-file containing all reads.

To downsample the BAM-files, edit and run the script 'BAM_microsats_select.sh'. This script expects to find the bed-file created in the previous step, as well as a txt.file listing all input bam-files.
The script will generate new bam-files with the same prefix as the original bam-files and with the suffix 'allmicrosats.bam'. The script will not edit the original bam-files.

## Step 3. Allele scoring

![alt text](https://github.com/mennodejong1986/MicrosatelliteGenotypingFromBam/blob/main/Microsatellite_genotyping_step3.png)
***Figure 1. Microsatellite scoring.*** *Reads with microsatellites*

## Step 4. Genotype calling

Distinguishing true signals from stutter alleles and null alleles.

![alt text](https://github.com/mennodejong1986/MicrosatelliteGenotypingFromBam/blob/main/Microsatellite_genotyping_step4.png)

## Step 5. Data filtering





