#!/usr/bin/perl -w
#################################################################
#
# A step in the process to get fourfold degenerate site pi for each gene.
# uses the output from the previous step (running  
# vcftools --site-pi) and gets avg pi across
# all degenerate sites in each gene
#
# USAGE: perl processvcfoutput_getpi.pl vcfoutputdir/ chr#
#
# ##############################################################
use strict;

my $vcfdir = "$ARGV[0]";
my $chr = "$ARGV[1]";
my @piFiles = <$vcfdir/*.txt.sites.pi>;

#store tab-delimited: gene intron# avg_pi intron_length
my $output = "chr"."$ARGV[1]"."_fourfolddegeneratepi\.txt";
open (OUT, ">$output") or die "file not found $!";

my %genes;

my $geneID;
foreach my $pi_file (@piFiles){
	#count the number of positions
	my $position_count = 0;
	my $pi_sum = 0;
	my $chrname;
	if ($pi_file =~ m/\/chr(.*?)_FB(.*)_fourfoldsitepi/){
		$chrname = $1;
		my $id = $2;
		$geneID = "FB"."$id";
		#print "File: $pi_file\tGene: $geneID\n";
	} else {
		print "had trouble parsing names: $pi_file\n";
		next;
	}	
	open (PI, $pi_file) or die "file not found $!\n";
	while (<PI>){
		my $line = $_;
		if (($line =~ m/^CHROM/)||($line =~ /nan/)){
			#header, so skip
			next;
		} else {
			$position_count++;
			my @fields = split (/\s+/, $line);
			my $pi = $fields[2];
			#print "$pi\n";
			$pi_sum = ($pi_sum + $pi);
		}
	}
	close (PI);

	#see if there's already information stored for this gene
	if (exists $genes{$geneID}){
		print "Warning, found multiple files for $geneID\n";
	} else{
		my @piposition = ($chrname, $pi_sum, $position_count);
		$genes{$geneID} = \@piposition;
	}
}	
foreach my $key (keys %genes){
	my @totals = @{$genes{$key}};
	my $chrom = "$totals[0]";
	my $pi_total = "$totals[1]";
	my $position_total = "$totals[2]";
	#now get avg pi from all sites
	my $avg_pi;
	if ($pi_total == 0){
		$avg_pi = 0;
	} else {
		$avg_pi = ($pi_total/$position_total);
	}
	#output: chr gene avg_pi length
	print OUT "$chrom\t$key\t$avg_pi\t$position_total\n";
}
close OUT;

exit;
