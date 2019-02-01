#!/bin/bash
#SBATCH --mem=100GB
#SBATCH -p noor
cd /datacommons/noor2/klk37/BackgroundSelection/gvcfs
PATH=/datacommons/noor/klk37/java/jdk1.8.0_144/bin:$PATH
export PATH

#java -jar /datacommons/noor2/klk37/BackgroundSelection/GATK-3.8-0/GenomeAnalysisTK.jar -T  SelectVariants \
#	-R /datacommons/noor2/klk37/BackgroundSelection/dpse-all-chromosome-r3.04.fasta \
#	-V genotyped.vcf \
#	--selectTypeToInclude SNP \
#	-o genotyped_SNPS.vcf

#We need all sites, so do not select SNPS only. Keep everything, but set filtered variants to no call (./.) for VariantsToTable
java -jar /datacommons/noor2/klk37/BackgroundSelection/GATK-3.8-0/GenomeAnalysisTK.jar -T VariantFiltration \
	-R /datacommons/noor2/klk37/BackgroundSelection/dpse-all-chromosome-r3.04.fasta \
	-V genotyped.vcf \
	-o genotyped_filtered.vcf \
	--filterExpression "QD < 2.0 || FS > 60.0 || SOR > 3.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0" \
	--filterName "hardfilter"

java -jar /datacommons/noor2/klk37/BackgroundSelection/GATK-3.8-0/GenomeAnalysisTK.jar -T VariantFiltration \
	-R /datacommons/noor2/klk37/BackgroundSelection/dpse-all-chromosome-r3.04.fasta \
	-V genotyped_filtered.vcf \
	-o genotyped_filtered_markedNoCall.vcf \
	--setFilteredGtToNocall
