STUDY=$1

FIND_COL="/shared/cleaning/scripts/find-column-index.pl"

STUDY_CHR=`$FIND_COL chr $STUDY`
STUDY_POS=`$FIND_COL position $STUDY`
STUDY_ALL1=`$FIND_COL 'REF' $STUDY`
STUDY_ALL2=`$FIND_COL 'ALT' $STUDY`
STUDY_FREQ=`$FIND_COL AF_coded_all $STUDY`
STUDY_PVAL=`$FIND_COL pvalue $STUDY`
STUDY_BETA=`$FIND_COL beta $STUDY`

if [ "$STUDY_ALL1" == "-1" ] || [ "$STUDY_ALL2" == "-1" ]
then
	STUDY_ALL1=`$FIND_COL noncoded_all $STUDY`
	STUDY_ALL2=`$FIND_COL coded_all $STUDY`
fi


echo "Column indices in STUDY file"
echo "----------------------------"
echo "Study: $STUDY"
echo "Chromosome column: $STUDY_CHR"
echo "Position column: $STUDY_POS"
echo "Allele 1 column: $STUDY_ALL1"
echo "Allele 2 column: $STUDY_ALL2"
echo "Frequency column: $STUDY_FREQ"
echo "p-value column: $STUDY_PVAL"
echo "Beta column: $STUDY_BETA"

if [ "$STUDY_CHR" == "-1" ] || [ "$STUDY_POS" == "-1" ] || [ "$STUDY_ALL1" == "-1" ] || [ "$STUDY_ALL2" == "-1" ] || [ "$STUDY_FREQ" == "-1" ] || [ "$STUDY_PVAL" == "-1" ] || [ "$STUDY_BETA" == "-1" ]
then
        echo "Column in STUDY file not found - check indices and header."
        exit
fi

cat $STUDY  | \
        awk -v chr=$STUDY_CHR -v pos=$STUDY_POS -v all1=$STUDY_ALL1 -v all2=$STUDY_ALL2 -v freq=$STUDY_FREQ -v beta=$STUDY_BETA -v pval=$STUDY_PVAL \
        'BEGIN { OFS="\t" }
	{ 
		if ($(chr+1) == "16" && $(pos+1) == "20364588") { 
			print "chr	position	noncoded_all	coded_all	AF_coded_all	beta	pvalue";
			print $(chr+1), $(pos+1), $(all1+1), $(all2+1), $(freq+1), $(beta+1), $(pval+1) 
		} 
	}' > /tmp/umod.txt

echo 
echo "UMOD extraction result"
echo "----------------------"
cat /tmp/umod.txt

echo
echo "Interpretation"
echo "--------------"
LINES=`wc -l /tmp/umod.txt | cut -f 1 -d ' '`
if [ "$LINES" == "2" ]
then
	echo "UMOD SNP found"
else
	echo "Got $LINES lines for UMOD SNP - expected 2 (incl. header)"
	exit
fi


cat /tmp/umod.txt | awk '{ 
	if ($1 == "16") {
		if ($3 != "A") { 
			print "Error: Expect non-coded allele to be A." 
		} else { 
			print "OK: Non-coded allele is A." 
		}
		if ($4 != "G") {
			print "Error: Expect coded allele to be G (data on plus strand? flip?)."
		} else {
			print "OK: Coded allele is G."
		}
		if ($5 < 0.1 || $5 > 0.3) {
			print "Error: Expect AF_coded_all to be in 0.1-0.3, but got: " $5
		} else {
			print "OK: AF_coded allele in range 0.1-0.3: " $5
		}
		if ($6 > 0) {
			print "Info: Beta positive: " $6 "; check trait: not ok for CKD (UMOD minor allele should decrease CKD risk), ok for GFR (UMOD minor allele increases GFR), not ok for creatinine (UMOD minor allele should decrease creatinine)"
		} else {
			print "Info: Beta negative: " $6 "; check trait: ok for CKD (UMOD minor allele decreases CKD risk), not ok for GFR (UMOD minor allele should increase GFR), ok for creatinine (UMOD minor allele decreases creatinine)"
		}
		if ($7 > 0.05) {
			print "Error: Expect p-value below 0.05, got: " $7
		} else {
			print "OK: Got p-value below 0.05: " $7
		}
	} 
}'

