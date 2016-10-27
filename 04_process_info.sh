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

echo -e "SNP\tCHR_POS\tMARKER\tREF\tALT\tALT_Frq\tMAF\toevar_imp\tIS_IMPUTED" \
	> ${INFO_OUT_DIR}/$BN

cat $FN | \
	awk 'BEGIN { 
		OFS = "\t"; 
	} 
	{ 
		if (FNR > 1) {
			impflag = $8; 
			if ($8 == "Imputed") {
				 impflag = "1";
			} else if ($8 == "-") {
				impflag = "NA";
			} else {
				impflag = "0";
			}

			rsq = $6;
			if (rsq == "-") {
				rsq = "NA";
			}

                        split($1, chrpos, ":");
                        chr = sprintf("%02d", chrpos[1]);
                        pos = sprintf("%09d", chrpos[2]);

			is_indel = length($2) > 1 || length($3) > 1;
			indel_mark = is_indel ? "I" : "S";

			print $1, chr "_" pos, chr "_" pos "_" indel_mark, 
				$2, $3, $4, $5, rsq, impflag
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
