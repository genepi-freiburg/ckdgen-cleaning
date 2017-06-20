#!/bin/bash
STUDY=$1
echo "Process $STUDY"
if [ ! -f "$STUDY" ]
then
	echo "File not found. Give study file as first argument."
	exit 3
fi

NEW_NTOTAL=$2
if [ "$NEW_NTOTAL" == "" ]
then
	echo "Please give new n(total) as second argument."
	exit 3
fi

FIND_COL=/shared/cleaning/scripts/find-column-index.pl
COL=`$FIND_COL n_total $STUDY`
echo "Found n_total at 0-based column $COL"

echo "Keep backup"
mv -v $STUDY ${STUDY}.bak

echo "Set n_total to: $NEW_NTOTAL"
zcat ${STUDY}.bak | awk -v nTotalCol=$COL -v nTotal=$NEW_NTOTAL 'BEGIN { OFS="\t" } {
	if (FNR <= 1) { print }
	else {
		$(nTotalCol+1) = nTotal;
		print;
	} }' | bgzip > $STUDY

echo "Create tabix index"
rm -v ${STUDY}.tbi
OUT_CHR=`$FIND_COL chr $STUDY`
OUT_POS=`$FIND_COL position $STUDY`
OUT_MARKER=`$FIND_COL CHR_POS $STUDY`
echo "Found columns: chr=$OUT_CHR, pos=$OUT_POS, marker=$OUT_MARKER"
tabix -s $((OUT_CHR+1)) -b $((OUT_POS+1)) -e $((OUT_POS+1)) -S $((OUT_MARKER+1)) -f $STUDY

echo "Done"
