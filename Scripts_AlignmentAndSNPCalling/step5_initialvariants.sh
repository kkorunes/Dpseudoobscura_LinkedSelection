#!/bin/bash
#SBATCH --mem=100GB

cd /datacommons/noor2/klk37/BackgroundSelection/BAMS_forGATK
PATH=/datacommons/noor/klk37/java/jdk1.8.0_144/bin:$PATH
export PATH
#Create initial variant calls

#ulimit -c unlimited

FILES=*.bam
for BAM in $FILES
do 
	ID="$(echo ${BAM} | awk -F'[.]' '{print $1}')"
	echo "calling variants for $ID"
	OUT="$ID".g.vcf.gz
	echo "$OUT"
	java -jar /datacommons/noor2/klk37/BackgroundSelection/GATK-3.8-0/GenomeAnalysisTK.jar -T HaplotypeCaller \
		-R /datacommons/noor2/klk37/BackgroundSelection/dpse-all-chromosome-r3.04.fasta -I $BAM -o $OUT -ERC GVCF
done
