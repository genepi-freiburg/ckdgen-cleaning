POPS="AFR EAS EUR AMR SAS"
for POP in $POPS
do

KGP=/shared/cleaning/data/1KGP_Phase3_${POP}_frequencies.txt
echo "Process: $KGP"

FIND_COL="/shared/cleaning/scripts/find-column-index.pl"

KGP_CHR=`$FIND_COL 'CHROM' $KGP`
KGP_POS=`$FIND_COL POS $KGP`
KGP_ALL1=`$FIND_COL REF $KGP`
KGP_ALL2=`$FIND_COL ALT $KGP`
KGP_AF=`$FIND_COL ${POP}_AF $KGP`

echo "Column indices in KGP file"
echo "--------------------------"
echo "Chromosome column: $KGP_CHR"
echo "Position column: $KGP_POS"
echo "Allele 1 column: $KGP_ALL1"
echo "Allele 2 column: $KGP_ALL2"
echo "Frequency column '${POP}_AF': $KGP_AF"

if [ "$KGP_CHR" == "-1" ] || [ "$KGP_POS" == "-1" ] || [ "$KGP_ALL1" == "-1" ] || [ "$KGP_ALL2" == "-1" ] || [ "$KGP_AF" == "-1" ]
then
	echo "Column in KGP file not found - check indices and header."
	exit
fi

echo "Subset KGP file and create join index; pop: $POP"
cat $KGP  | \
	awk -v chr=$KGP_CHR -v pos=$KGP_POS -v all1=$KGP_ALL1 -v all2=$KGP_ALL2 -v freq=$KGP_AF -v pop=$POP \
	'{
                if (FNR > 1) {
			if ($(chr+1) == "X") {
				mychr = "X";
			} else {
				mychr = sprintf("%02d", $(chr+1));
			}
			mypos = sprintf("%09d", $(pos+1));
			myall1 = $(all1+1);
			myall2 = $(all2+1);
                        myfreq = $(freq+1);
			if (myall2 ~ /,/) {
				allele_count = split(myall2, myalls2, ",");
				split(myfreq, myfreqs, ",");
				for (i = 1; i <= allele_count; i++) {
					myall2a = myalls2[i];
					myfreq1 = myfreqs[i];
					maf1 = myfreq1 > 0.5 ? 1 - myfreq1 : myfreq1;
					if (maf1 > 0) {
		                	        print mychr "_" mypos "_" myall1 "_" myall2a "\t" myfreq1 "\t" maf1;
					}
				}
			} else {
	                        maf = myfreq > 0.5 ? 1 - myfreq : myfreq;
				if (maf > 0) {
		                        print mychr "_" mypos "_" myall1 "_" myall2 "\t" myfreq "\t" maf;
				}
			}
                } else {
                        print "KEY\tAF_coded_all_" pop "_KGP\tMAF_" pop "_KGP";
		}
	}' \
	> ${KGP}.frequencies


echo "Sort KGP file: $KGP"
cat ${KGP}.frequencies | head -n 1 > ${KGP}.frequencies.sorted
cat ${KGP}.frequencies | tail -n +2 | sort >> ${KGP}.frequencies.sorted

done
