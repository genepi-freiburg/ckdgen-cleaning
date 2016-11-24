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
if (!exists $opts{'i'} or !exists $opts{'o'}) {
    print "Usage: $0 -i input_file -o output_file [-c chromosome_number]\nConverts EPACTS output file to a .gwas file.\n";
    exit;
}

if ($opts{'i'} !~ /\.epacts$/ && $opts{'i'} !~ /\.epacts\.gz$/) {
    die "Input file must end with .epacts or .epacts.gz!\n";
}

if ($opts{'o'} !~ /\.gwas$/) {
    die "Output file must end with .gwas!\n";
}

my $chr = "NA";
if (exists $opts{'c'}) {
    $chr = $opts{'c'};
} else {
    if ($opts{'i'} =~ /chr(\d+)/i) {
	$chr = $1;
	if ($chr =~ /0(\d)/) {
		$chr = $1;
	}
	print "Auto-detected chromosome $chr.\n";
    } elsif ($opts{'i'} =~ /chrX/) {
	$chr = "X";
	print "Auto-detected chromosome X.\n";
    }
}

if ($opts{'i'} =~ /\.gz$/) {
	print "Process gzipped input.\n";
	open(INPUT, "-|", "gunzip -c " . $opts{'i'}) or die "Input file not found!\n";
} else {
	open(INPUT, $opts{'i'}) or die "Input file not found!\n";
}
open(OUTPUT, ">" . $opts{'o'}) or die "Cannot open output file for writing!\n";

my $i = 0;
my @header;
my $skipped = 0, my $included = 0, my $errors = 0;

my $markerCol = -1, my $chrCol = -1, my $posCol = -1;
my $betaCol = -1, my $seCol = -1, my $pvalCol = -1;
my $mafCol = -1, my $nsCol = -1, my $acCol = -1, my $callrateCol = -1;
my $mafCasesCol = -1, my $mafControlsCol = -1;

while (<INPUT>) {
    # read line
    my $line = $_;
    chomp($line);

    # print header
    $i++;
    if ($i == 2 && $markerCol > -1) {
	print OUTPUT "SNP\tCHR_POS\tMARKER\tchr\tposition\tcoded_all\tnoncoded_all\tstrand_genome\t";
	print OUTPUT "beta\tSE\tpval\tAF_coded_all\tMAF\tHWE_pval\tcallrate\tn_total\t";
	print OUTPUT "imputed\tused_for_imp\toevar_imp";
        if ($mafCasesCol > -1 && $mafControlsCol > -1) {
            # binary traits
            print OUTPUT "\tcases_hwe\tcontrols_hwe\t";
    	    print OUTPUT "cases_maf\tcontrols_maf\n";
            print "Detected binary trait.\n";
	} else {
            # quantitative traits
            print "Detected quantitative trait.\n";
	    print OUTPUT "\n";
	}
    }

# 0       1      2        3                       4      5       6               7        8      9        10      11         12  13        14          15
#CHROM  BEGIN   END     MARKER_ID                NS      AC      CALLRATE        MAF     PVALUE  BETA    SEBETA  CHISQ   NS.CASE NS.CTRL AF.CASE        AF.CTRL
#1       13380   13380   1:13380_C/G_1:13380     5034    0.025   1       2.4831e-06      NA      NA      NA      NA      1778    3256    1.1249e-06      3.2248e-06

#CHROM	BEG	END	MARKER_ID		NS	AC	CALLRATE	GENOCNT	MAF	STAT	PVALUE	BETA	SEBETA	R2


    # skip comments / header in input
    if ($line =~ /^#/) {
	# process header, find fields, skip comments
	if ($markerCol == -1) {
            my @header = split(/\t/, $line);
            $markerCol = findImportantCol("MARKER_ID", @header);
            $nsCol = findImportantCol("NS", @header);
            $chrCol = findImportantCol("#CHROM", @header);
            $posCol = findOptionalCol("BEGIN", @header);
            if ($posCol == -1) {
                $posCol = findImportantCol("BEG", @header);
            }
            $betaCol = findImportantCol("BETA", @header);
            $seCol = findImportantCol("SEBETA", @header);
            $pvalCol = findImportantCol("PVALUE", @header);
            $mafCol = findImportantCol("MAF", @header);
            $nsCol = findImportantCol("NS", @header);
            $acCol = findImportantCol("AC", @header);
            $callrateCol = findImportantCol("CALLRATE", @header);
            $mafCasesCol = findOptionalCol("AF.CASE", @header);
            $mafControlsCol = findOptionalCol("AF.CTRL", @header);
	    print "Found column indices: marker=$markerCol, pval=$pvalCol, beta=$betaCol, se=$seCol, ";
	    print "ns=$nsCol, ac=$acCol, maf=$mafCol, chr=$chrCol, pos=$posCol, callrate=$callrateCol, mafCases=$mafCasesCol, mafControls=$mafControlsCol\n";
	}
        next;
    }

    # split fields
    my @data = split(/\t/, $line);

    # marker name and alleles
    my $marker = $data[$markerCol];
    my $coded = $2, my $noncoded = $1;
    if ($marker !~ /^[^_]+\_([A-Z0-9\<\>:]+)\/([A-Z0-9\<\>:\-]+)\_.*$/) {
        if ($marker !~ /^[^_]+\_([A-Z0-9\<\>:]+)\/([A-Z0-9\<\>:\-]+)$/) {
          print "ERROR: Marker name not parseable: $marker -> skip line\n";
          $errors++;
          next;
        } else {
	  $coded = $2;
	  $noncoded = $1;
	}
    } else {
        $coded = $2;
        $noncoded = $1;
    }

    # chromosome number
    my $outchr;
    if ($chr ne "NA") {
	$outchr = $chr;
        if ($chr ne "X") {
            if ($data[$chrCol] != $chr) {
                print "ERROR: Chromosome in line does not match passed chromosome and/or file name. Skip line.\n";
                $errors++;
                next;
           }
	}
    } else {
	$outchr = $data[$chrCol];
    }

    # strand, beta/se/pval
    my $beta = $data[$betaCol];
    my $se = $data[$seCol];
    my $pval = $data[$pvalCol];
    if ($beta eq "NA" || $se eq "NA" || $pval eq "NA") {
        $skipped++;
        next;
    }

    my $nSamples = $data[$nsCol];
    my $altAllCount = $data[$acCol];

    # START OUTPUT
    $included++;

    # marker, chromosome number and position
    #my $myMarker = sprintf("%02d", $outchr) . "_" . sprintf("%09d", $data[$posCol]) . "_" . $noncoded . "_" . $coded;
    #my $myMarker = sprintf("%02d", $outchr) . "_" . sprintf("%09d", $data[$posCol]) . "_" . $noncoded . "_" . $coded;
    my $snpIndel = "S";
    if (length($coded) > 1 || length($noncoded) > 1) {
      $snpIndel = "I";
    }

    print OUTPUT $marker . "\t";
    #print OUTPUT $myMarker . "\t";

    my $chrFormatted = $outchr;
    if ($outchr ne "X") {
      $chrFormatted = sprintf("%02d", $outchr);
    }

    print OUTPUT $chrFormatted . "_" . sprintf("%09d", $data[$posCol]) . "\t";
    print OUTPUT $chrFormatted . "_" . sprintf("%09d", $data[$posCol]) . "_" . $snpIndel . "\t";
    print OUTPUT $outchr . "\t"; # CHR
    #print OUTPUT $chrFormatted . "\t"; # CHR
    print OUTPUT $data[$posCol] . "\t"; # POS

    # alleles
    print OUTPUT $coded . "\t" . $noncoded . "\t"; # coded/non_coded

    # strand, beta/se/pval
    print OUTPUT "+\t" . $beta . "\t" . $se . "\t" . $pval . "\t";

    # AF_coded_all
    print OUTPUT sprintf("%.5f", $altAllCount/$nSamples/2) . "\t"; # AFcoded
    print OUTPUT $data[$mafCol] . "\t"; # MAF

    # HWE
    print OUTPUT "NA\t";

    # callrate
    print OUTPUT $data[$callrateCol] . "\t";

    # n_total
    print OUTPUT $nSamples . "\t";

    # imputation
    print OUTPUT "NA\tNA\tNA";

    # HWE cases/controls

    # MAF cases/controls
    if ($mafCasesCol > -1 && $mafControlsCol > -1) {
        print OUTPUT "\tNA\tNA\t";
        print OUTPUT $data[$mafCasesCol] . "\t" . $data[$mafControlsCol] . "\n";
    } else {
        print OUTPUT "\n";
    }
}

close OUTPUT;
close INPUT;

print "Output file " . $opts{'o'} . " finished.\n";
print "Included $included SNPs, skipped $skipped SNPs, $errors errors, processed $i lines (with header).\n";

