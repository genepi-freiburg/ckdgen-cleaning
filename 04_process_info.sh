#/bin/bash

####################################################################
# SETUP DIRECTORIES
####################################################################

INFO_IN_DIR=02_info_unzipped
INFO_OUT_DIR=04_info_modified
INFO_UNIQUE_DIR=04_info_unique
DUPLICATES_DIR=04_info_duplicates

rm -rf $INFO_OUT_DIR $DUPLICATES_DIR $INFO_UNIQUE_DIR
mkdir -p $INFO_OUT_DIR $DUPLICATES_DIR $INFO_UNIQUE_DIR

for FN in `ls $INFO_IN_DIR/*`
do
BN=`basename ${FN}`

####################################################################
# GENERATE ADDITIONAL COLUMNS, TRANSFORM IMPUTE FLAG, SORT BY CHRPOS
####################################################################

echo "Transform/sort: $BN (${INFO_IN_DIR} -> ${INFO_OUT_DIR})"

FIND_COL="/shared/cleaning/scripts/find-column-index.pl"

SNP_COL=`$FIND_COL SNP $FN`
RSQ_COL=`$FIND_COL Rsq $FN`
IMP_COL=`$FIND_COL Genotyped $FN`

echo "Column indices (0-based): SNP = $SNP_COL, Rsq = $RSQ_COL, Genotyped = $IMP_COL"
if [ "$SNP_COL" == "-1" ] || [ "$RSQ_COL" == "-1" ] 
then
	echo "Required column not found. Please check input file: $FN"
	exit 3
fi

if [ "$IMP_COL" == "-1" ]
then
	echo "WARNING: No 'is_imputed' column - assuming NA"
fi

# out: chr, chr_pos, rsq, is_imputed
echo -e "CHR\tCHR_POS\toevar_imp\tIS_IMPUTED" \
	> ${INFO_OUT_DIR}/$BN

cat $FN | \
	awk  -v snpCol=$SNP_COL -v rsqCol=$RSQ_COL -v impCol=$IMP_COL 'BEGIN { 
		OFS = "\t"; 
	} 
	{ 
		if (FNR > 1) {
			impflag = "NA";
			if (impCol > -1) {
				impflag = $(impCol+1); 
				if (impflag == "Imputed") {
					 impflag = "1";
				} else if (impflag == "-") {
					impflag = "NA";
				} else {
					impflag = "0";
				}
			}

			rsq = $(rsqCol+1);
			if (rsq == "-") {
				rsq = "NA";
			}

                        split($(snpCol+1), chrpos, ":");
			if (chrpos[1] != "X") {
	                        chr = sprintf("%02d", chrpos[1]);
			} else {
				chr = "X";
			}
                        pos = sprintf("%09d", chrpos[2]);

			print chr, chr "_" pos, rsq, impflag
		}
	}' \
	| sort -k 2 >> ${INFO_OUT_DIR}/$BN

####################################################################
# DETECT DUPLICATES
####################################################################

echo "Detect duplicates: $BN.duplicates ($INFO_OUT_DIR -> $DUPLICATES_DIR)"
cut -f 2 ${INFO_OUT_DIR}/$BN | uniq -d > ${DUPLICATES_DIR}/${BN}.duplicates
echo "Find uniques: $BN.unique ($INFO_OUT_DIR -> $DUPLICATES_DIR)"
cut -f 2 ${INFO_OUT_DIR}/$BN | uniq -u > ${DUPLICATES_DIR}/${BN}.unique
echo "Remove duplicates by join: $BN ($INFO_OUT_DIR -> ${INFO_UNIQUE_DIR})"
join -1 2 -2 1 \
	-t $'\t' \
	${INFO_OUT_DIR}/$BN ${DUPLICATES_DIR}/${BN}.unique > ${INFO_UNIQUE_DIR}/$BN

wc -l $FN ${INFO_OUT_DIR}/$BN ${DUPLICATES_DIR}/${BN}.unique \
	${DUPLICATES_DIR}/${BN}.duplicates ${INFO_UNIQUE_DIR}/$BN | \
	grep -v "total"

done


echo "Rename chromosomes to include leading zero"
/shared/cleaning/scripts/rename-chromosomes.sh $INFO_UNIQUE_DIR/*

wc -l $INFO_UNIQUE_DIR/*.info | grep -v "total"
