#!/usr/bin/perl -w
##########################################################################################################
#  Contact: Katharine Korunes, kkorunes@gmail.com
#
#  Given the set of fourfold degenerate sites, calculate average fourfold degenerate site pi per gene
#  (properly accounting for missing sites and genotypes.)
#  USAGE: perl custompi_fourfold.pl genotypesVCFtoTable.vcf positionsfile output chr#
#
#########################################################################################################
use strict;

my $vcf = "$ARGV[0]";
my $inp = "$ARGV[1]";
my $out = "$ARGV[2]";
my $chr = "$ARGV[3]";

my $comps = 0;
my $diffs = 0;
my $sites = 0;

my %find;
open (IN, $inp) or die "file not found: $!\n";
while (<IN>){
	chomp();
	my $line = $_;
	my @fields = split /\s+/, $line;
	my $varChr = "$fields[0]";
	my $pos = "$fields[1]";
	my $save = "$chr".",$pos";
	$find{$save} = "$save";
}
close(IN);

#now parse this region from the variant file
open (VCF, $vcf) or die "file not found: $!\n";
while (<VCF>){
	chomp();
	my $line = $_;
	if (($line =~ /^chrom/)||($line =~ /^\s*$/ )){
	next;
	}
	my @fields = split /\s+/, $line;
	my $varChr = "$fields[0]";
	if ("$varChr" ne "$chr") {
		next;
	}
	my $pos = "$fields[1]";
	my $check = "$varChr".",$pos";

	if (exists $find{$check}){
		$sites++;
		my @dpse = @fields[5..33];
		#remove missing positions
		my @alleles;
		foreach my $check (@dpse){
			my @both = split /\//, $check;
			foreach my $one (@both){
				if ("$one" !~ /\./){
					push (@alleles, $one);
				}
			}
		}
		
		my $len = scalar(@alleles);
		for (my $i = 0; $i < ($len-1); $i++){
			for (my $n = ($i+1); $n < $len; $n++){
				my $a1 = "$alleles[$i]";
				my $a2 = "$alleles[$n]";
				if ("$a1" eq "$a2"){
					$comps++;
				}else{
					$diffs++;
					$comps++;
				}	
			}
		}
	} else {
		next;		
	}
}
close(VCF);

my $avgpi = 0;
if ($comps > 0){
	$avgpi = ($diffs/$comps);
	open (OUT, ">$out") or die "file not found: $!\n";
	print OUT "$avgpi\t$sites\n";
	close(OUT);
}
exit;
