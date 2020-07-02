#!/usr/bin/perl -w
#################################################################
# Contact: Katharine Korunes, kkorunes@gmail.com
#
# A step in the process to get fourfold degenerate site pi for each gene.
# uses the output from the previous step to collect avg pi across each gene
#
# USAGE: perl processoutput_getpi.pl chr_outputdir/
#
# ##############################################################
use strict;

my $vcfdir = "$ARGV[0]";
my @piFiles = <$vcfdir/*pi.txt>;

#store tab-delimited: chr, gene, avg_pi, positions_counted
my $output = "FOURFOLD"."$ARGV[0]"."fourfoldpi\.txt";
open (OUT, ">$output") or die "file not found $!";

my %genes;

my $geneID;
my $chrname;
foreach my $pi_file (@piFiles){
	if ($pi_file =~ m/\/chr(.*)_FB(.*)_fourfoldsitepi/){
		$chrname = $1;
		my $id = $2;
		my @names = split /,/, $id;
		$geneID = "$chrname"."-FB"."$names[0]";
	} else {
		print "had trouble parsing names: $pi_file\n";
		next;
	}	
	open (PI, $pi_file) or die "file not found $!\n";
	my $pi = 0;
	my $sites = 0;
	while (<PI>){
		my $line = $_;
		my @fields = split (/\s+/, $line);
		$pi = $fields[0];
		$sites = "$fields[1]";
	}
	close (PI);

	#see if there's already data stored for this gene
	if (exists $genes{$geneID}){
		#add this data to the already stored data
		my @savedinfo = @{$genes{$geneID}};
		my $newsave = "$pi".",$sites";
		push(@savedinfo, $newsave);
		$genes{$geneID} = \@savedinfo;
		#print "@savedinfo\n";
	} else{
		my $save = "$pi".",$sites";
		my @piposition = ($save);
		$genes{$geneID} = \@piposition;
		#print "$save; @piposition\n";
	}
}	
foreach my $key (keys %genes){
	my @totals = @{$genes{$key}};

	my @nameparts = split /-/, $key;
	my $chr = "$nameparts[0]";
	my $gene = "$nameparts[1]";
	print "chr$chr, gene $gene, totals: @totals\n";
	
	my $position_total = 0;
	my @pis;
	my @sites;
	#now get avg_pi (weighting by # of sites)
	foreach my $in (@totals){
		my @vals = split (/,/, $in);
		my $pi = "$vals[0]";
		my $site = "$vals[1]";
		push(@pis, $pi);
		push(@sites, $site);
		$position_total = ($position_total + $site);
	} 

	my $avgpi = 0;
	my $len = scalar(@pis);
	for (my $i = 0; $i < $len; $i++){
		my $thispi = "$pis[$i]";
		my $thissite = "$sites[$i]";
		my $weight = ($thispi*($thissite/$position_total));
		$avgpi = $avgpi+$weight;	
	}
	#output: chr gene avg_pi length
	print OUT "$chr\t$gene\t$avgpi\t$position_total\n";
}
close OUT;

exit;
