#!/usr/bin/perl -w
#######################################################################################
# Contact: Katharine Korunes, kkorunes@gmail.com
#
# Match pi for each gene to the recombination rate for that gene
#
# USAGE: perl klk_matchToRecombRates.pl pifile RecRateFile All_gene_span_coord/chr*.txt
#
# #######################################################################################
use strict;

my $indata = "$ARGV[0]";
my $recdata = "$ARGV[1]";
my $starts = "$ARGV[2]";

#store tab-delimited: chr gene avg_pi length recombrate startPosition
my $output = "Recombrates_$indata";
open (OUT, ">$output") or die "file not found $!";
print OUT "CHR\tGENE\tAVG_PI\tPOSITIONS_COUNTED\tREC_RATE\tGENE_START\n";

my %recRates;
my $lastend = 0;
my $lastrec = 0;
open (STARTS, $starts) or die "unable to open $starts\n";
while (<STARTS>){
	chomp();
	my $line = $_;
	my @startfields = split /\s+/, $line;
	my $gene = "$startfields[0]";
	my $startchr = "$startfields[1]";
	my $genestart = "$startfields[2]";

	open (REC, $recdata) or die "file not found $!\n";
	while (<REC>){
		chomp();
		my $line = $_;
		my @recfields = split (/\s+/, $line);
		my $recchr = "$recfields[0]";
		my $start = "$recfields[1]";
		my $end = "$recfields[2]";
		my $rate = "$recfields[3]";	
		if ($recchr eq $startchr){
			if (($genestart >= $start) && ($genestart <= $end)){
				if (exists $recRates{$gene}){
					print "WARNING: multiple entries for $gene\n";
				} else {
					my @save = ($genestart, $rate);
					$recRates{$gene}=[@save];
				}
				last;
			}
			if (($genestart > $lastend) && ($genestart < $start)){
				my $avg = (($rate + $lastrec)/2);
				if (exists $recRates{$gene}){
					print "WARNING: multiple entries for $gene\n";
				} else {
					my @save = ($genestart, $avg);
					$recRates{$gene}=[@save];
				}
			}	
			$lastend = $end;
			$lastrec = $rate;
		}
	}
	close(REC);
}
close (STARTS);
	

open (IN, $indata) or die "file not found $!";
while (<IN>){
	chomp();
	my $line = $_;
	my @fields = split (/\s+/, $line);
	my $pichr = "$fields[0]";
	my $geneName = "$fields[1]";
	my $inPi = "$fields[2]";	
	my $inLen = "$fields[3]";
	my $recRate;
	my $start;
	if (exists ($recRates{$geneName})){
		my @saved = @{$recRates{$geneName}};
		$start = "$saved[0]";
		$recRate = "$saved[1]";
	} else {
		print "missing rec data for $geneName\n";
		$start = "NA";
		$recRate = "NA";
		next;		
	}
	print OUT "$pichr\t$geneName\t$inPi\t$inLen\t$recRate\t$start\n";
}
close (IN);

close OUT;

exit;
