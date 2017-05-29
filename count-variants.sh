#/bin/bash
FN=$1
BN=`basename $FN`
echo -n "$BN	"
CHR_COL=`/shared/cleaning/scripts/find-column-index.pl chr $FN`
cHR_COL=$((CHR_COL + 1))
for LINE in `zcat $FN | awk -v chrCol=$CHR_COL '{ if (FNR > 1) { print $(chrCol+1) } }' | uniq -c`
do
	#COUNT=`echo $LINE | cut -f1 -d'	'`
	#CHR=`echo $LINE | cut -f 2`
	#COUNT=`echo $LINE | awk '{print $1}'`
	echo -n "$LINE	"
done
echo ""
