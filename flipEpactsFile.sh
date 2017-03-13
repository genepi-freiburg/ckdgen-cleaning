INFN=$1
OUTFN=$2

if [ "$#" != "2" ]
then
	echo "Usge: $0 <infn> <outfn>"
	exit 3
fi

if [ ! -f "$INFN" ]
then
	echo "Input file does not exist: $INFN"
	exit 3
fi

if [ -f "$OUTFN" ]
then
	echo "Output file exists (please remove): $OUTFN"
	exit 3
fi

if [[ "$OUTFN" != *.gz ]]
then
	echo "Output file name must end with .gz: $OUTFN"
	exit 3
fi

FINDCOL="/shared/cleaning/scripts/find-column-index.pl"

BETA_COL=`$FINDCOL BETA $INFN`
AC_COL=`$FINDCOL AC $INFN`
NS_COL=`$FINDCOL NS $INFN`

echo "Beta col: $BETA_COL, AC col: $AC_COL, NS col: $NS_COL"

if [[ "$BETA_COL" == "-1" ]] || [[ "$AC_COL" == "-1" ]] || [[ "$NS_COL" == "-1" ]]
then
	echo "Required column not found."
	exit 3
fi

CAT="cat"
GZIP=""

if [[ "$INFN" == *.gz ]]
then
	CAT="zcat"
	echo "Process gzipped input."
fi


$CAT $INFN | awk -v betaCol=$BETA_COL -v acCol=$AC_COL -v nsCol=$NS_COL \
	'BEGIN { FS="\t"; OFS="\t"; } { if (FNR > 1) {
		ns = $(nsCol+1);
		$(betaCol+1) = -$(betaCol+1);
		afCoded = $(acCol+1)/ns/2;
		afCoded = 1 - afCoded;
		$(acCol+1) = afCoded * ns * 2;
		print;
	} else { print }}' \
	 | gzip > $OUTFN
