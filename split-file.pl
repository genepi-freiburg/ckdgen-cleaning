#!/usr/bin/perl -w
use strict;
use Getopt::Std;

sub findOptionalCol {
    my $colName = shift;
    my @header = @_;
    for (my $i = 0; $i <= $#header; $i++) {
        if ($header[$i] eq $colName) {
            return $i;
        }
    }
    return -1;
}

sub findImportantCol {
    my $colName = shift;
    my @header = @_;
    my $idx = findOptionalCol($colName, @header);
    if ($idx < 0) {
       print "Required column '$colName' missing from input file.\n";
       exit;
    }
    return $idx;
}

my %opts;
getopt('ioc', \%opts);
if (!exists $opts{'i'} or !exists $opts{'o'} or !exists $opts{'c'}) {
    print "Usage: $0 -i input_file -o output_file_pattern -c col_name\n";
    print "Splits the input file by values of the -c column.\n";
    print "The input must contain a header, be tab delimited and be sorted by the split column.\n";
    print "Both input and output files may be compressed, the suffix .gz is detected.\n";
    print "Output filenames are built by replacing %C% with the concrete column value.\n";
    exit;
}

if ($opts{'i'} =~ /\.gz$/) {
	print "Process gzipped input.\n";
	open(INPUT, "-|", "gunzip -c " . $opts{'i'}) or die "Input file not found!\n";
} else {
	open(INPUT, $opts{'i'}) or die "Input file not found!\n";
}

my $zipOutput = $opts{'o'} =~ /\.gz$/;
if ($zipOutput) {
	print "Write gzipped output.\n";
} else {
	print "Write uncompressed output.\n";
}

my $outPattern = $opts{'o'};
if (!($outPattern =~ /%C%/)) {
	die "Output file pattern does not contain %C%.\n";
}

my $i = 0;
my $j = 0;

my $firstLine = <INPUT>;
chomp($firstLine);
my @header = split(/\t/, $firstLine);

my $lastSplitColValue = "";
my $splitColIndex = findImportantCol($opts{'c'}, @header);
print "Found split column '$opts{'c'}' at column index $splitColIndex.\n";

while (<INPUT>) {
    # read line
    my $line = $_;
    chomp($line);
    $i++;
    my @data = split(/\t/, $line);

    # determine file
    my $splitColValue = $data[$splitColIndex];
    if ($splitColValue ne $lastSplitColValue) {
        $lastSplitColValue = $splitColValue;
	close(OUTPUT);
	my $outFileName = $outPattern;
	$outFileName =~ s/%C%/$splitColValue/g;
	if ($zipOutput) {
            open(OUTPUT, "| gzip -c > " . $outFileName) or die "Cannot open output file for writing!\n";
    	    print "Write compressed output to: $outFileName\n";
	} else {
	    open(OUTPUT, ">" . $outFileName) or die "Cannot open output file for writing!\n";
	    print "Write uncompressed output to: $outFileName\n";
	}
	print OUTPUT $firstLine . "\n";
	$j++;
    }

    print OUTPUT $line . "\n";
}

close OUTPUT;
close INPUT;

print "Wrote $i lines (excluding headers) in $j files.\n";

