#/bin/bash

####################################################################
# SETUP DIRECTORIES
####################################################################

IN_DIR=01_data_unzipped
GWAS_PROCESSED_DIR=02_data_processed
GWAS_OUT_DIR=05_gwas_combined

rm -rf $GWAS_OUT_DIR $GWAS_PROCESSED_DIR
mkdir -p $GWAS_OUT_DIR $GWAS_PROCESSED_DIR

for FN in `ls $IN_DIR/*`
do

../../scripts/check-gwas-columns.sh $FN
if [ "$?" != "0" ]
then
	echo "STOP - please fix column names."
	exit 3
fi

BN=`basename ${FN}`

####################################################################
# GENERATE ADDITIONAL COLUMNS
####################################################################

echo "Transform: $BN (${IN_DIR} -> ${GWAS_PROCESSED_DIR})"

FIND_COL="/shared/cleaning/scripts/find-column-index.pl"
STUDY_CHR=`$FIND_COL chr $FN`
STUDY_POS=`$FIND_COL position $FN`
STUDY_ALL1=`$FIND_COL noncoded_all $FN`
STUDY_ALL2=`$FIND_COL coded_all $FN`
echo "Column indices (0-based): Chr = $STUDY_CHR, Pos = $STUDY_POS, All1 = $STUDY_ALL1, All2 = $STUDY_ALL2"
if [ "$STUDY_CHR" == "-1" ] || [ "$STUDY_POS" == "-1" ] || [ "$STUDY_ALL1" == "-1" ] || [ "$STUDY_ALL2" == "-1" ]
then
	echo "Required column not found. Please check input file: $FN"
	exit 3
fi

cat $FN | tr ' ' \\t | \
	awk  -v chrCol=$STUDY_CHR -v posCol=$STUDY_POS -v all1Col=$STUDY_ALL1 -v all2Col=$STUDY_ALL2 \
	'BEGIN { 
		OFS = "\t"; 
	} 
	{ 
		if (FNR > 1) {
			chr = $(chrCol+1);
			if (chr != "X") {
				chr = sprintf("%02d", chr)
			}
			pos = sprintf("%09d", $(posCol+1));
			$(posCol+1) = $(posCol+1)+0; # try to fix funny NEO input "chr1:45000000:D 1 4.5e+07 T"
			all1 = $(all1Col+1);
			all2 = $(all2Col+1);
			marker = "S";
			if (length(all1) > 1 || length(all2) > 1) {
				marker = "I";
			}
			print chr "_" pos, chr "_" pos "_" marker, $0;
		} else {
			print "CHR_POS", "MARKER", $0;
		}
	}' \
	> ${GWAS_PROCESSED_DIR}/$BN

echo "Sort file: $BN"
head -n  1 ${GWAS_PROCESSED_DIR}/$BN > ${GWAS_PROCESSED_DIR}/${BN}.sorted
tail -n +2 ${GWAS_PROCESSED_DIR}/$BN | sort -k 1 >> ${GWAS_PROCESSED_DIR}/${BN}.sorted
mv ${GWAS_PROCESSED_DIR}/${BN}.sorted ${GWAS_PROCESSED_DIR}/${BN}

####################################################################
# DETECT DUPLICATES
####################################################################

echo "Detect duplicates: $BN.duplicates ($GWAS_PROCESSED_DIR)"
cut -f 1 ${GWAS_PROCESSED_DIR}/$BN | uniq -d > ${GWAS_PROCESSED_DIR}/${BN}.duplicates
echo "Find uniques: $BN.unique ($GWAS_PROCESSED_DIR)"
cut -f 1 ${GWAS_PROCESSED_DIR}/$BN | uniq -u > ${GWAS_PROCESSED_DIR}/${BN}.unique
echo "Remove duplicates by join: $BN ($GWAS_PROCESSED_DIR -> $GWAS_OUT_DIR)"
join -1 1 -2 1 --header \
	-t $'\t' \
	${GWAS_PROCESSED_DIR}/$BN ${GWAS_PROCESSED_DIR}/${BN}.unique > ${GWAS_OUT_DIR}/$BN

wc -l $FN ${GWAS_PROCESSED_DIR}/$BN ${GWAS_PROCESSED_DIR}/${BN}.unique \
	${GWAS_PROCESSED_DIR}/${BN}.duplicates ${GWAS_OUT_DIR}/$BN | \
	grep -v "total"

	echo "bgzip and tabix"
        cat $GWAS_OUT_DIR/$BN | bgzip > ${GWAS_OUT_DIR}/${BN}.gz
        tabix -s 4 -b 5 -e 5 -S 1 -f ${GWAS_OUT_DIR}/${BN}.gz
done

md5sum $GWAS_OUT_DIR/* | tee 05_gwas_combined.md5.txt



