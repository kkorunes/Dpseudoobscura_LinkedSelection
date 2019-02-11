#/usr/bin/perl -w
########################################################################
#  Step 1 in the pipeline to parse mpilup data to collect and compare 
#  the CDSs across lines. This script finds the positions of the 
#  CDSs from the FlyBase fasta (already separated by chromosome).
#
#  USAGE : perl ...pl CDSforChromosome.fasta LongestTranscriptList.txr
#  
########################################################################

use strict;
use Bio::SeqIO;

my $input = "$ARGV[0]";
my $longest = "$ARGV[1]";
my $id = $input;
if ($input =~ /(.*).fasta/){
	$id = $1;
}
 #Get list of longest isoformes, exclude loci not on this list
my %keep; 
open (LIST, $longest) or die "file not found:$!\n";
while (<LIST>){
	chomp();
	my $line = $_;
	my @names = split /\s+/, $line;
	my $geneID = "$names[0]";
	my $transcript = "$names[1]";
	$keep{$transcript} = $geneID;
}
close(LIST);

#collect data on positions
my $seqio = Bio::SeqIO->new(-file => $input, '-format' => 'Fasta');
while(my $seq = $seqio->next_seq) {
	my $name = $seq->id;	
	my $desc = $seq->desc; 
	my $seq = $seq->seq;
	my $chr;
	my $gene;
	my $trans;
	if ($desc =~ /parent=(.*?);/){
		my $parent = $1;
		my @split = split /,/, $parent;
		$gene = "$split[0]";
		$trans = "$split[1]";
	}
	#Check if this is the longest isoform
	if (!(exists $keep{$trans})){
		print "skipping $gene,$trans: not the longest isoform\n";
		next;
	}	

	if ($desc =~ /loc=(.*?):(.*?);.*/){
		my @bases; #build list of base positions
		$chr = $1;
       		my $location = $2;
		my $comp = 0; # 1 if true (complement)
		#if single base positions
		if ($location =~ /^\./){
			my $number = ($location =~ s/^\s+|\s+$//g);
			push(@bases, $number);
			if ($location =~ /complement/){
				$comp = 1;
			} 
		}
		#if sequence span (base positions separated by 2 dots)
		elsif ($location =~ /^(\d+)\.\.(\d+)/){
			my $start = $1;
			my $end = $2;
			for (my $i = $start; $i <= $end; $i++){
				push(@bases, $i);
			}
		}
		#if exact boundaries unknown (contains < or >)
		elsif (($location =~ /\>/)||($location =~ /\</)||($location =~ /\^/)){
			print "skipping, boundaries unknown for $location\n";
		}
		#if complement(location)
		elsif ($location =~ /complement/){
			$comp = 1;
			while ($location =~ /(\d+)\.\.(\d+)/g){ #this covers complement(join...)
				my $start = $1;
                		my $end = $2;
               			#print "loc = $location, start $start, end $end\n";
				for (my $i = $start; $i <= $end; $i++){
               				push(@bases, $i);
           			}
			}
		}			      
		#if join(location,location, ... location) 
		elsif ($location =~ /join/){
           		while ($location =~ /(\d+)\.\.(\d+)/g){
				my $start = $1;
				my $end = $2;	
				for (my $i = $start; $i <= $end; $i++){
					push(@bases, $i);
				}
			}
		}
		
		my @degenbases;
		my @codons = ($seq =~ m/.../g);
		my $codoncount = (scalar @codons);
		my $basecount = (scalar @bases);
		my @coords;
		print "$gene\t$trans\t$codoncount\t$basecount\n";	
		if ($comp == 0) {
			@coords = @bases;	
		} elsif ($comp == 1){
			@coords = reverse @bases;
		}

		for (my $i=1; $i<=$codoncount; $i++){
			my $codon = "$codons[$i-1]";
			my $thirdbase = ($i*3);
			my $degeneracy = check_degeneracy($codon);
			if ($degeneracy == 4){
				#print "$codon\n";
				my $coord = "$coords[$thirdbase-1]";
				#print "\t$codon\t$coord\n";
				push (@degenbases, $coord);		
			}	
		}
	
		#Print to appropriate output file:	
		my $output = "$chr"."_$gene"."_$trans"."_fourfoldsites.txt";
		open (OUT, ">$output") or die "unable to open:$!\n";
		foreach my $site (@degenbases){
			print OUT "$chr\t$site\n";
		}
		close(OUT);
	} else {
		print "warning: difficulty parsing $desc\n";
	}
}

exit;

###########################################################################################################
#SUBROUTINE
###########################################################################################################
#
sub check_degeneracy {
	my ($codon) = @_;
	chomp ($codon);
	my $degeneracy = 0;
	my %fourfold;
	foreach ("GGT","GGC","GGA","GGG","CGT","CGC","CGA","CGG","TCT","TCC","TCA","TCG","CCT","CCC","CCA","CCG","ACT","ACC","ACA","ACG","GCT","GCC","GCA","GCG","GTT","GTC","GTA","GTG","CTT","CTC","CTA","CTG") {
		$fourfold{$_} = 1;
	}
	if (exists $fourfold{$codon}){
		$degeneracy = 4;
	}
	return $degeneracy;
}

