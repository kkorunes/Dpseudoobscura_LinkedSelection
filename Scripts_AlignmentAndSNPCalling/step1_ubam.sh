#!/bin/bash
#SBATCH --mem=40GB
cd /datacommons/noor2/klk37/BackgroundSelection/FASTQ/

R1S=*_1.fastq.gz
for R1 in $R1S
do
	#name="$(echo ${R1} | awk -F'[_' '{print $1}')"
	name="$(echo ${R1} | grep -oP '.*(?=_1.fastq.gz)')"
	echo "working on $name"
	R2="$name"_2.fastq.gz	
	/datacommons/noor/klk37/java/jdk1.8.0_144/bin/java -Xmx8G -jar /datacommons/noor/klk37/picard.jar FastqToSam \
		F1=$R1 \
		F2=$R2 \
		O="$name"_unaligned_read_pairs.bam \
		RG=$name \
		SM=$name \
		TMP_DIR=`pwd`/tmp
done
