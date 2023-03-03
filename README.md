# MicrosatelliteGenotypingFromBam
Pipeline to extract microsatellite genotype data from short read sequencing data.

With the advent of next generation sequencing, SNPs (single nucleotide polymorphisms) have replaced microsatellites as the mainstream genetic marker. SNP data is typically generated in a three step procedure, consisting of:
1. fastq to bam:  mapping short read sequences (100-150bp length) against a reference genome
2. bam to gvcf:   genotype calling, by calculating the genotype likelihoods of the three possible genotypes (i.e., homozygous reference, heterozygous, homozygous alternative) given the data (i.e., reads which mapped to the position), and by selecting the genotype which the highest likelihood
3. gvcf to vcf:   snp filtering, by selecting only sites which are biallelic (i.e., removing monomorphic sites, multi-allelic sites and indels)

However, instead of extracting SNP data from the information stored in bam-files, why not extract microsatellite data? Given the relatively high mutation rate and allelic richness of microsatellites, one could even argue that microsatellites are a more informative genetic marker than biallelic SNPs.
The pipeline presented here extracts microsatellite data from an input file of bam-files. The prerequisite is that the short read data has been mapped against a reference genome which has not been masked for repetitive genomes. Furthermore, the sequencing data should at least be 10x (preferably higher), and the read lengths preferably not shorter than 150 bp.



