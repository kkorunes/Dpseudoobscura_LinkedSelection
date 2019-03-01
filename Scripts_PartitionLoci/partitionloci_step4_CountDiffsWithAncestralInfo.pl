#!/usr/bin/perl -w
##########################################################################################################
#  A step in the pipeline to look through the variant data and find genes without fixed
#  differences.
#
#  This script using D.lowei as an outgroup to polarize ancestral vs dervied alleles. The output is a
#  tab-delimted file, where each entry is a gene. Column 1 contains the count of derived alleles in Dpse
#  and Column 2 contains the count of derived allels in Dmir.
#
#  USAGE: perl partitionloci_step4.pl chr##_fixeddifferences.txt chr##_genotypesVCFtoTable.txt chr##
#
#########################################################################################################
use strict;

my $genefile = "$ARGV[0]";
my $variants = "$ARGV[1]";
my $chr = "$ARGV[2]";
print "working on genes in $genefile\n";

my $output;
if ($genefile =~ /(.*?).txt/){
	my $name = $1;
	$output = "$name"."_Ancestors.txt";
}
open (OUT, ">$output") or die "unable to open $!\n";
print OUT "DerivedInDpse\tDerivedInDmir\tGeneID\n";

my %snps;
open(VCF, $variants) or die "unable to open:$!\n";
while (<VCF>){
	chomp();
	my $entry = $_;	
	if (($entry =~ /^chrom/) || ($entry =~ /^\s*$/)){
		next;
	}
	my @entries = split /\s+/, $entry;
	my $chrom = "$entries[0]";
	if ($chrom !~ /$chr/){
		next;
	}
	my $pos = "$entries[1]";
	my @dpses = @entries[5..33];
	my @dmirs = @entries[34..44];
	my $low = "$entries[45]";
	if (("$low" =~ /\./) || ("$low" =~ /\*/)){
		$low = "na";
	}

	my @sortedDpse = sort(@dpses);
	my @sortedDmir = sort(@dmirs);
	my @testDpse;
	my @testDmir;
	foreach my $check (@sortedDpse){
		if (("$check" !~ /\./) && ("$check" !~ /\*/)){
			push (@testDpse, $check);
		}
	}
	foreach my $checkDmir (@sortedDmir){
		if (("$checkDmir" !~ /\./) && ("$checkDmir" !~ /\*/)){
			push (@testDmir, $checkDmir);
		}
	}
	
	my $dpse = "na";
	my $dmir = "na";
	if ((scalar @testDpse > 0) && (scalar @testDmir > 0 )){
		$dpse = "$testDpse[0]";
		$dmir = "$testDmir[0]";
	}
	my @info = ($low, $dpse, $dmir);
	$snps{$pos} = \@info;
}
close(VCF);
		
open (GENES, $genefile) or die "file not found: $!\n";
while (<GENES>){
	chomp();
       	my $line = $_;
	my @fields = split /\s+/, $line;
	my $geneID = shift @fields;
	my $count = scalar(@fields);
	my $dpseDer = 0;
	my $dmirDer = 0;
	#parse the ancestral state from the VCF table
	my $missing = 0;
	if ($count > 0){
		foreach my $checkcoord (@fields){
			if (exists $snps{$checkcoord}){
				my @get = @{$snps{$checkcoord}};
				my $low = "$get[0]";
				my $dpse = "$get[1]";
				my $dmir = "$get[2]";
				#print "for $checkcoord, Dlow: $low, Dmir: $dmir, Dpse: $dpse\n";	
				if ("$low" =~ /na/){
					print "missing ancestor for $checkcoord\n";
					$missing++;
				} elsif ($dpse eq $low){
					$dmirDer++;
				} elsif ($dmir eq $low){
					$dpseDer++;
				} elsif (($dpse =~ /na/) || ($dmir =~ /na/)){
					print "missing information for $checkcoord\n";
					$missing++;
				} elsif (("$low" !~ "$dpse") && ("$low" !~ "$dmir")){
					print "neither species matches the ancestral allele at $checkcoord\n";
					$missing++;
				}
			}else {
				print "could not retreive position $checkcoord\n";
				$missing++;
			}
		}
	}
	if ($missing == 0){ 
		print OUT "$dpseDer\t$dmirDer\t$geneID\n";
	} else {
		print "not printing results from $line\n";
	}
}
close(GENES);
close(OUT);

