HRC=/shared/cleaning/data/HRC.r1-1.GRCh37.wgs.mac5.sites.tab

FIND_COL="/shared/cleaning/scripts/find-column-index.pl"

HRC_CHR=`$FIND_COL '#CHROM' $HRC`
HRC_POS=`$FIND_COL POS $HRC`
HRC_ALL1=`$FIND_COL REF $HRC`
HRC_ALL2=`$FIND_COL ALT $HRC`
HRC_AF=`$FIND_COL AF $HRC`

echo "Column indices in HRC file"
echo "--------------------------"
echo "Chromosome column: $HRC_CHR"
echo "Position column: $HRC_POS"
echo "Allele 1 column: $HRC_ALL1"
echo "Allele 2 column: $HRC_ALL2"
echo "Frequency column: $HRC_AF"

if [ "$HRC_CHR" == "-1" ] || [ "$HRC_POS" == "-1" ] || [ "$HRC_ALL1" == "-1" ] || [ "$HRC_ALL2" == "-1" ] || [ "$HRC_AF" == "-1" ]
then
	echo "Column in HRC file not found - check indices and header."
	exit
fi

echo "Subset HRC file and create join index"
cat $HRC  | \
	awk -v chr=$HRC_CHR -v pos=$HRC_POS -v all1=$HRC_ALL1 -v all2=$HRC_ALL2 -v freq=$HRC_AF \
	'{
                if (FNR > 1) {
                        myfreq = $(freq+1);
                        maf = myfreq;
                        if (maf > 0.5) {
                                maf = 1 - maf;
                        }
                        print sprintf("%02d", $(chr+1)) "_" sprintf("%09d", $(pos+1)) "_" $(all1+1) "_" $(all2+1) "\t" myfreq "\t" maf
                } else {
                        print "KEY\tAF_coded_all_HRC\tMAF_HRC"
		}
	}' \
	> ${HRC}.frequencies


echo "Sort HRC file"
sort ${HRC}.frequencies > ${HRC}.frequencies.sorted
