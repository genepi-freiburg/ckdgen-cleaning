INFILE=$1
COLS="coded_all noncoded_all chr beta AF_coded_all IQ n_total position Pvalue used_for_imp SE"
FIND_COL="/shared/cleaning/scripts/find-column-index.pl"

if [ ! -f "$INFILE" ]
then
	echo "Input file not found: $INFILE"
	exit 3
fi

ERRORFLAG=0
for COL in $COLS
do
	COLPOS=`$FIND_COL $COL $INFILE`
	if [ "$COLPOS" == "-1" ] && [ "$COL" != "used_for_imp" ]
	then
		echo "Required column NOT present: $COL"
		ERRORFLAG=1
	else
		if [ "$COLPOS" == "-1" ]
		then
			echo "OPTIONAL column NOT present: $COL"
		else
			echo "Column $COL found at 0-based index: $COLPOS"
		fi
	fi
done

if [ "$ERRORFLAG" == "1" ]
then
        echo "Required column(s) not found. Please check input file: $FN"
        exit 3
else
	echo "OK: All required columns are found."
fi

