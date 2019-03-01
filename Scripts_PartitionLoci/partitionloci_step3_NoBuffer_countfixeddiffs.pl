#!/usr/bin/perl -w
##########################################################################################################
#  Look through the variant data and identify fixed differences between species.
#
#  Thie version ("NoBuffer") screens the gene span, including UTRs but no additional 
#  upstream/downstream buffer. 
#
#  USAGE: perl partitionloci_step3.pl chr##_genespans-dpse-all-gene-3.04.txt chr##_genotypesVCFtoTable.vcf
#
#########################################################################################################
use strict;

my $genefile = "$ARGV[0]";
my $vcf = "$ARGV[1]";
my $total = 0;

print "working on genes in $genefile\n";
my %fixed = (); #gene names, each value will be an array of the fixed diff positions
my %missing = (); #keep track of missing positions for downstream filtering
my $chr;
if ($genefile =~ /chr(.*?)_dpse/){
	$chr = $1;
} else {
	print "could not recognize chromosome\n";
}
open (GENES, $genefile) or die "file not found: $!\n";
while (<GENES>){
	chomp();
       	my $line = $_;
	my @fields = split /\s+/, $line;
        my $id = "$fields[0]";
	my $start = "$fields[2]";
	my $end = "$fields[3]";
	my $upstream = $start;
	my $downstream = $end;
	@{$fixed{$id}} = (); 		
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
		if (($pos >= $upstream) && ($pos <= $downstream)){
			my @dpse = @fields[5..33];
			my @mir = @fields[34..44];
			my $low = "$fields[45]";
			#Is this site fixed between species? check if there's a fixed allele in both
			#If so, add position to %fixed
			my @sortedDpse = sort(@dpse);
			my @sortedDmir = sort(@mir);
			#remove missing positions
			my @testDpse;
			my @testDmir;
			foreach my $check (@sortedDpse){
				if ("$check" !~ /\./){
					push (@testDpse, $check);
				}
			}
			foreach my $check (@sortedDmir){
				if ("$check" !~ /\./){
					push (@testDmir, $check);
				}
			}
			if ((scalar @testDpse > 0) && (scalar @testDmir > 0) && ($testDpse[0] eq $testDpse[-1]) && ($testDmir[0] eq $testDmir[-1])){
				#both have a fixed allele
				if ($testDpse[0] ne $testDmir[0]) {
					#this is a fixed difference	
					#print "FOUND ONE:\n$line\n\n";
					push(@{$fixed{$id}}, $pos);
				}
			}
			#count missing positions for downstream filtering
			my $missingDpse = 0;
			my $missingDmir = 0;
			my $missingLow = 0;
			my $key = "$chr"."$pos";
			foreach my $d (@dpse){
				if ("$d" =~ /\./){
					$missingDpse++;
				}
			}
			foreach my $m (@mir){
				if ("$m" =~ /\./){
					$missingDmir++;
				}
			}
			if ("$low" =~ /\./){
				$missingLow++;
			}
			my @count = ($missingDpse,$missingDmir,$missingLow);
			$missing{$key}=\@count;
		} else {
			next;		
		}
	}
	close(VCF);
	$total++;
	print "processed $total genes so far...\n";
}
close (GENES);
#write gene names and fixed diffs to output
my $out = "chr".$chr."_fixeddifferences_NoBuffer.txt";
open (OUT, ">$out") or die "file not found: $!\n";
foreach my $id (keys %fixed){
	print OUT "$id\t@{$fixed{$id}}\n";
}
close(OUT);
#write the counts of missing values to a file:	
my $out2 = "chr".$chr."_missingData_NoBuffer.txt";
open (OUT2, ">$out2") or die "file not found: $!\n";
foreach my $key (keys %missing){
	print OUT2 "$key\t@{$missing{$key}}\n";
}
close(OUT2);
print "Output files written\n";


exit;
