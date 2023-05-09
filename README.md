# MicrosatelliteGenotypingFromBam

With the advent of next generation sequencing, SNPs (single nucleotide polymorphisms) have replaced microsatellites as the mainstream genetic marker. These SNP data sets are typically generated in a three step procedure:
1. fastq to bam:  mapping short read sequences (100-150bp length) against a reference genome
2. bam to gvcf:   genotype calling, by calculating the genotype likelihoods of the three possible genotypes (i.e., homozygous reference, heterozygous, homozygous alternative) given the data (i.e., reads which mapped to the position), and by selecting the genotype which the highest likelihood
3. gvcf to vcf:   snp filtering, by selecting only sites which are biallelic (i.e., removing monomorphic sites, multi-allelic sites and indels)

However, instead of extracting SNP data from the information stored in bam-files, why not extract microsatellite data? Given the relatively high mutation rate and allelic richness of microsatellites, one could even argue that microsatellites are a more informative genetic marker than biallelic SNPs. While traditional microsatellite studies were based on a limited number of markers (typically less than 25), whole genome resequencing data potentially contains information for many thousands of microsatellites.   

## Workflow overview

The pipeline presented here extracts microsatellite data from an input file of bam-files. The prerequisite is that the short read data has been mapped against a reference genome which has not been masked for repetitive genomes. Furthermore, the sequencing data should at least be 10x (preferably higher), and the read lengths preferably not shorter than 150 bp.

The procedure to produce a microsatellite data set from bam-files involves computer work only (not wet lab stuff), and consists of the following four steps:
0. microsatellite loci selection: detect and select a set of microsatellite loci in a reference genome
1. microsatellite data extraction: extract the selected microsatellite loci from all individual genomes
2. allele scoring: count for each microsatellite locus the number of reads supporting each allele  
3. genotype calling: convert count data into genotypes using a decision tree

Albeit entirely computer-based, in a way each step of this pipeline resembles steps in the traditional wet-lab protocol of a microsatellite study, namely primer design (preparatory step), target-specific DNA-amplification through PCR, allele scoring through capillary electrophoresis and finally genotype calling using a decision tree (e.g., distinguishing true signals from stutter alleles and null alleles). Do not worry if you are not familiar with this procedures - this is just for comparison and irrelevant information for running this pipeline.     

## Step 1. Select a set of microsatellite loci

Microsatellites in a reference genome can be detected using the software TRFfinder, by running the command:

./trf409.linux64 mygenome.fa -h

Add -h flag to surpress output files we do not need.

The ... script subsequently selects loci which the desired repeat length. 

## Step 2. Extract selected microsatellites from genomes 

In traditional microsatellite studies, PCR serves to selectively amplify the regions of interest, namely the microsat loci.  
Downsampling bam-files by only keeping reads which overlap with the selected microsatellites.

## Step 3. Allele scoring

![alt text](https://github.com/mennodejong1986/MicrosatelliteGenotypingFromBam/blob/main/Microsatellite_genotyping_step3.png)
***Figure 1. Microsatellite scoring.*** *Reads with microsatellites*

## Step 4. Genotype calling

![alt text](https://github.com/mennodejong1986/MicrosatelliteGenotypingFromBam/blob/main/Microsatellite_genotyping_step4.png)







