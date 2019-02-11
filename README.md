# Dpseudoobscura_LinkedSelection

#### Sequence alignment and variant calling scripts are contained subdirectory "Scripts_AlignmentAndSNPCalling":
This directory contains all scripts used for alignment, SNP calling, and hard filtering. All sequencing data were aligned to the reference genome of D. miranda using BWA-0.7.5a (Li & Durbin 2009). Variants were called and filtered used GATK v4 (McKenna et al. 2010; Van der Auwera et al. 2013) after using Picard to mark adapters and duplicates (http://broadinstitute.github.io/picard).

#### Scripts for partitioning loci according to fixed differences between species are contained subdirectory "Scripts_PartitionLoci":

#### Scripts for analyzing introns contained subdirectory "Scripts_IntronDiversity":
This directory contains all scripts used for selecting short introns from each gene and analyzing nucleotide diversity within these regions.

#### Scripts for calculating 4-fold degenerate site pi are contained subdirectory "Scripts_FourFoldSiteDiversity":
