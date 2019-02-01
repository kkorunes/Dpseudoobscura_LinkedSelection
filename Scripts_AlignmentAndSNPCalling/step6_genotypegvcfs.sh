#!/bin/bash
#SBATCH --mem=100GB

cd /datacommons/noor2/klk37/BackgroundSelection/gvcfs
PATH=/datacommons/noor/klk37/java/jdk1.8.0_144/bin:$PATH
export PATH
#jointly genotype the haplotype caller gvcfs

java -jar /datacommons/noor2/klk37/BackgroundSelection/GATK-3.8-0/GenomeAnalysisTK.jar -T GenotypeGVCFs \
	-R /datacommons/noor2/klk37/BackgroundSelection/dpse-all-chromosome-r3.04.fasta \
	--variant Dmir_MA28_dedup_reads.g.vcf.gz \
	--variant Dmir_MAO101-4_dedup_reads.g.vcf.gz \
	--variant Dmir_MAO3-3_dedup_reads.g.vcf.gz \
	--variant Dmir_MAO3-4_dedup_reads.g.vcf.gz \
	--variant Dmir_MAO3-5_dedup_reads.g.vcf.gz \
	--variant Dmir_MAO3-6_dedup_reads.g.vcf.gz \
	--variant Dmir_ML14_dedup_reads.g.vcf.gz \
	--variant Dmir_ML16_dedup_reads.g.vcf.gz \
	--variant Dmir_ML6f_dedup_reads.g.vcf.gz \
	--variant Dmir_SP138_dedup_reads.g.vcf.gz \
	--variant Dmir_SP235_dedup_reads.g.vcf.gz \
	--variant Dpse_PP1134_dedup_reads.g.vcf.gz \
	--variant Dpse_PP1137_dedup_reads.g.vcf.gz \
	--variant Dpse_AFC12_dedup_reads.g.vcf.gz \
	--variant Dpse_FS18_dedup_reads.g.vcf.gz \
	--variant Dpse_MAT32_dedup_reads.g.vcf.gz \
	--variant Dpse_MATTL_dedup_reads.g.vcf.gz \
	--variant Dpse_MSH24_dedup_reads.g.vcf.gz \
	--variant Dpse_MSH9_dedup_reads.g.vcf.gz \
	--variant Dpse_S10-A47_dedup_reads.g.vcf.gz \
	--variant Dpse_S11-A14_dedup_reads.g.vcf.gz \
	--variant Dpse_S12-M27_dedup_reads.g.vcf.gz \
	--variant Dpse_S13-A48_dedup_reads.g.vcf.gz \
	--variant Dpse_S14-A49_dedup_reads.g.vcf.gz \
	--variant Dpse_S15-A57_dedup_reads.g.vcf.gz \
	--variant Dpse_S16-A30_dedup_reads.g.vcf.gz \
	--variant Dpse_S17-M20_dedup_reads.g.vcf.gz \
	--variant Dpse_S18-M15_dedup_reads.g.vcf.gz \
	--variant Dpse_S19-A24_dedup_reads.g.vcf.gz \
	--variant Dpse_S1-A56_dedup_reads.g.vcf.gz \
	--variant Dpse_S20-M13_dedup_reads.g.vcf.gz \
	--variant Dpse_S21-M6_dedup_reads.g.vcf.gz \
	--variant Dpse_S22-A6_dedup_reads.g.vcf.gz \
	--variant Dpse_S2-MV225_dedup_reads.g.vcf.gz \
	--variant Dpse_S3-M14_dedup_reads.g.vcf.gz \
	--variant Dpse_S4-A60_dedup_reads.g.vcf.gz \
	--variant Dpse_S5-M17_dedup_reads.g.vcf.gz \
	--variant Dpse_S6-A19_dedup_reads.g.vcf.gz \
	--variant Dpse_S7-Flag14_dedup_reads.g.vcf.gz \
	--variant Dpse_S9-A12_dedup_reads.g.vcf.gz \
	--variant lowei_renamedRG_dedup.g.vcf.gz \
	-allSites \
	-o genotyped.vcf
