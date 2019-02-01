#!/bin/bash
#SBATCH --mem=100GB
#SBATCH -p noor
cd /datacommons/noor2/klk37/BackgroundSelection/gvcfs
PATH=/datacommons/noor/klk37/java/jdk1.8.0_144/bin:$PATH
export PATH

java -jar /datacommons/noor2/klk37/BackgroundSelection/GATK-3.8-0/GenomeAnalysisTK.jar -T VariantsToTable \
	-R /datacommons/noor2/klk37/BackgroundSelection/dpse-all-chromosome-r3.04.fasta \
	-V genotyped_filtered_markedNoCall.vcf \
	-F CHROM -F POS -F REF -F ALT -GF GT -F FILTER \
	-o genotyped_filtered_markedNoCall_VCFtotable.txt \
	--showFiltered
