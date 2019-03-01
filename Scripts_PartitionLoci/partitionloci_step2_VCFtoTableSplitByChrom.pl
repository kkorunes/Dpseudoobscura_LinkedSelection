#!/usr/bin/perl -w
########################################################################
## This script splits variant information by chromosome.
#  The variant data must be a VCF reformatted to a tab-delimited file
#  using GATK's VariantsToTable.
#
## USAGE: perl partitionloci_step2_parsebychrom.pl VCFtotable.txt
########################################################################
use strict;

my $input = "$ARGV[0]";
my $id = $input;
if ($input =~ /(.*).txt/){
	$id = $1;
}
my $out2 = "chr2_$id.txt";
my $out4 = "chr4_$id.txt";
my $outXL = "chrXL_$id.txt";
my $outXR = "chrXR_$id.txt";
my $outOther = "chrOther_$id.txt";


open (IN, $input) or die "file not found: $!\n";
my $header = <IN>;
#$header = chomp($header);
print "Header: $header\n";

open (OUT2, ">$out2");
open (OUT4, ">$out4");
open (OUTXL, ">$outXL");
open (OUTXR, ">$outXR");
open (OUTOTHER, ">$outOther");
print OUT2 "$header\n";
print OUT4 "$header\n";
print OUTXL "$header\n";
print OUTXR "$header\n";
print OUTOTHER "$header\n";

while(<IN>) {
	chomp();
	my $line = $_;
	my @fields = split /\s+/, $line;
	my $chr = "$fields[0]";
	#Print to appropriate output file:
	if ($chr eq 2){
		print OUT2 "$line\n";
	}
	elsif ($chr =~ /4/){
                print OUT4 "$line\n";
	}
	elsif ($chr =~ /XL/){
                print OUTXL "$line\n";
	}
	elsif ($chr =~ /XR/){
                print OUTXR "$line\n";
	}
	else{
		print OUTOTHER "$line\n";
	}
}

close(IN);
close(OUT2);
close(OUT4);
close(OUTXL);
close(OUTXR);
close(OUTOTHER);
print "Done splitting file by chromosomes\n";

exit;
