STUDY=$1
POP=$2

echo "Study file: $STUDY"
echo "Population: $POP"

if [ "$STUDY" == "" ] || [ "$POP" == "" ]
then
	echo "Input parameters missing"
	echo "First parameter: Study results file"
	echo "Second parameter: Population (EUR, EAS, SAS, AFR, AMR)"
	exit
fi

if [ ! -f "$STUDY" ]
then
	echo "Study file not found: $STUDY"
	exit
fi

KGP=/shared/cleaning/data/1KGP_Phase3_${POP}_frequencies.txt.frequencies.sorted
GNUPLOT=gnuplot

if [ ! -f "$KGP" ]
then
	echo "1KGP frequencies file not found: $KGP"
	exit
fi

FIND_COL="/shared/cleaning/scripts/find-column-index.pl"

STUDY_CHR=`$FIND_COL chr $STUDY`
STUDY_POS=`$FIND_COL position $STUDY`
STUDY_ALL1=`$FIND_COL 'REF' $STUDY`
STUDY_ALL2=`$FIND_COL 'ALT' $STUDY`
STUDY_FREQ=`$FIND_COL AF_coded_all $STUDY`

if [ "$STUDY_ALL1" == "-1" ] || [ "$STUDY_ALL2" == "-1" ]
then
	STUDY_ALL1=`$FIND_COL noncoded_all $STUDY`
	STUDY_ALL2=`$FIND_COL coded_all $STUDY`
fi


echo "Column indices in STUDY file: $STUDY"
echo "-------------------------------------"
echo "Chromosome column: $STUDY_CHR"
echo "Position column: $STUDY_POS"
echo "Allele 1 column: $STUDY_ALL1"
echo "Allele 2 column: $STUDY_ALL2"
echo "Frequency column: $STUDY_FREQ"

if [ "$STUDY_CHR" == "-1" ] || [ "$STUDY_POS" == "-1" ] || [ "$STUDY_ALL1" == "-1" ] || [ "$STUDY_ALL2" == "-1" ] || [ "$STUDY_FREQ" == "-1" ]
then
        echo "Column in STUDY file not found - check indices and header."
        exit
fi

STUDY_FREQ_FILE="${STUDY}.frequencies"
echo
echo "Prepare study join file: $STUDY_FREQ_FILE"

cat $STUDY  | \
        awk -v chr=$STUDY_CHR -v pos=$STUDY_POS -v all1=$STUDY_ALL1 -v all2=$STUDY_ALL2 -v freq=$STUDY_FREQ \
        '{ 
		if (FNR > 1) {
			myfreq = $(freq+1);
			maf = myfreq;
			if (maf > 0.5) {
				maf = 1 - maf;
			}
			print sprintf("%02d", $(chr+1)) "_" sprintf("%09d", $(pos+1)) "_" $(all1+1) "_" $(all2+1) "\t" myfreq "\t" maf
		} else {
			print "KEY\tAF_coded_all_studay\tMAF_study"
		}
	}' \
        > ${STUDY_FREQ_FILE}

STUDY_FREQ_FILE_SORTED="${STUDY_FREQ_FILE}.sorted"
echo "Sort study join file to: $STUDY_FREQ_FILE_SORTED"
sort $STUDY_FREQ_FILE > $STUDY_FREQ_FILE_SORTED
mv -fv $STUDY_FREQ_FILE_SORTED $STUDY_FREQ_FILE

STUDY_JOIN_FILE="${STUDY_FREQ_FILE}.joined"
echo
echo "Join with KGP file: $KGP"
echo "Target: $STUDY_JOIN_FILE"

join $STUDY_FREQ_FILE $KGP > $STUDY_JOIN_FILE

wc -l $STUDY_FREQ_FILE
wc -l $KGP
wc -l $STUDY_JOIN_FILE

PLOT_FILE_AF="${STUDY_JOIN_FILE}-scatter-AF.png"
PLOT_FILE_MAF="${STUDY_JOIN_FILE}-scatter-MAF.png"
echo
echo "Perform scatter plot (AF): ${PLOT_FILE_AF}"
$GNUPLOT -e "infile='${STUDY_JOIN_FILE}';outfile='${PLOT_FILE_AF}'" /shared/cleaning/scripts/scatter-AF.plg 
echo "Perform scatter plot (MAF): ${PLOT_FILE_MAF}"
$GNUPLOT -e "infile='${STUDY_JOIN_FILE}';outfile='${PLOT_FILE_MAF}'" /shared/cleaning/scripts/scatter-MAF.plg 


echo 
echo "Cleanup"
rm -fv $STUDY_JOIN_FILE
rm -fv $STUDY_FREQ_FILE
