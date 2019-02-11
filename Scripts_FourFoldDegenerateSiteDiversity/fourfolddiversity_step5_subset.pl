#!/usr/bin/perl -w
#####################################################################################
#
# Get a subset (using a list of names)
#
# USAGE: perl introndiversity_step7.pl chrX_pi_vs_recombrate nameslist.txt
#
# ###################################################################################
use strict;

my $all = "$ARGV[0]";
my $list = "$ARGV[1]";
my $out;
if ($list =~ /(.*).txt/){
	my $filename = $1;	
	$out = "$filename"."_4foldpiAndRecRates.txt";
}
open (OUT, ">$out") or die "file not found: $!\n";

my @gather = ();
my $found = 0;
open (LIST, $list) or die "file not found: $!\n";
while (my $name = <LIST>){
	$name =~ s/\A\s+//s;
	$name =~ s/\s+\Z//s;
	#my @info = split /\s+/, $line;
	#my $name = "$info[0]";
	push @gather, ( $name );
	#print "$name\n";
	my $matched = 0;
	open (ALL, $all) or die "file not found:$!\n";
	while (<ALL>){
		chomp();
		my $line = $_;
		my @fields = split /\s+/, $line;
		my $gene = "$fields[1]";	
		#chomp($gene);
		#print "$gene\n";
		if ($gene =~ /$name/){
			$found++;
			$matched++;
			#print "Found one\n";
			print OUT "$line\n";
		}else {
			#print "$name"."-notequalto-$gene\n";
		}
	}
	close(ALL);
	if($matched == 0){
		print "no match for $name\n";
	}
}
close(LIST);

print "found $found\n";

close(OUT);

exit;
