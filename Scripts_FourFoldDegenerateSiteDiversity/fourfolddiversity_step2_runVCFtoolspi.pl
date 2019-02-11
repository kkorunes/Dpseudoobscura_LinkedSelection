#!/usr/bin/perl -w
###################################################################################################
#
# A step in the process to get pi at four-fold degenerate sites for each gene.
# Runs vcftools --site-pi to get pi for the SNP positions
#
# USAGE: perl fourfolddiversity_step4_runVCFtoolspi.pl chr#_fourfold_coordinates/
#
# #################################################################################################
use strict;

my $dir = "$ARGV[0]";
my @positionsFiles = <$dir/*.txt>;

my $chr;
my $gene;
my $transcript;
foreach my $positions (@positionsFiles){
	if ($positions =~ m/\/(.*?)_FB(.*)_(.*)_fourfoldsites.txt/){
		$chr = $1;
		$gene = "FB"."$2";
		$transcript = $3;
	#	print "$chr,$gene,$transcript\n";
	#	print "$positions\n";
	} else {
		print "warning, couldn't identify chromosome for: $positions\n";
		next;
	}

	#use vcftools to get pi per site
	my $runscript = "$gene"."_$transcript".".sh";
	my $output = "chr"."$chr"."_$gene"."_fourfoldsitepi.txt";
	open (RUN, ">$runscript") or die "file not found $!";
	print RUN "#!/bin/bash\n";
	print RUN "#SBATCH --mem=20GB\n";
	print RUN "cd /datacommons/noor2/klk37/BackgroundSelection/four-fold-degenerate-diversity_DPSE\n";
	print RUN "/opt/apps/rhel7/vcftools-0.1.17/bin/vcftools --vcf /datacommons/noor2/klk37/BackgroundSelection/intron_nucleotide_diversity_DPSE/genotyped_RemovedFilteredSites_DPSEONLY.recode.vcf --site-pi --positions $positions --out $output\n";
	close (RUN);
	system("sbatch $runscript"); 
}


exit;
