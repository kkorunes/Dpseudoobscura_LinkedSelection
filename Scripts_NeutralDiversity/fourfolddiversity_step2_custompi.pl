#!/usr/bin/perl -w
##############################################################################################
# Contact: Katharine Korunes, kkorunes@gmail.com
#
# A step in the process to get fourfold pi for each gene. Wrapper to parallelize running 
# custompi_fourfold.pl over all the genes.
#
# USAGE: perl fourfolddiversity_step4_runVCFtoolspi.pl chr_fourfoldcoords/
#
# ############################################################################################
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
	print RUN "#SBATCH -p scavenger\n";
	print RUN "cd /datacommons/noor2/klk37/BackgroundSelection/June2020_fourfold_diversity_custompi\n";
	print RUN "perl custompi_fourfold.pl ../genotyped_filtered_markedNoCall_VCFtotable.txt $positions $output $chr\n";
	close (RUN);
	system("sbatch $runscript"); 
}
exit;
