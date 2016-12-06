GWAS_IN_DIR=03_gwas_noinfo
INFO_IN_DIR=04_info_unique
GWAS_OUT_DIR=05_gwas_single
GWAS_JOIN_DIR=05_gwas_combined
PAIRS_FILE=pairs-file.txt

if [ ! -f "$PAIRS_FILE" ] ; then
	echo "Pairs file missing: $PAIRS_FILE"
fi

rm -rf $GWAS_OUT_DIR $GWAS_JOIN_DIR
mkdir -p $GWAS_OUT_DIR $GWAS_JOIN_DIR

for FN in `ls -1 $GWAS_IN_DIR`
do
        CHR=`echo $FN | sed 's/.*chr\([0-9][0-9]\?\).*/\1/i'`
	CHR=`echo $CHR | sed 's/.*chrX.*/X/i'`
	OUT=`basename $FN`

	echo "CHROMOSOME: $CHR"

	#####################################################################
	# DETERMINE INFO FILE TO USE ACCORDING TO "PAIRS" FILE
        #####################################################################

	rm -f /tmp/info.txt
	touch /tmp/info.txt
	INFO=""
	cat $PAIRS_FILE | while IFS='' read -r PAIR || [[ -n "$line" ]]
	do
		GWAS_PATTERN=$(echo $PAIR | cut -f1 -d" ")
		INFO_PATTERN=$(echo $PAIR | cut -f2 -d" ")
		if [[ $OUT == $GWAS_PATTERN ]]
		then
			if [ "$INFO" != "" ]
			then
				echo "Multiple patterns match filename: $FN"
				echo "Pattern 1: $INFO"
				echo "Pattern 2: $INFO_PATTERN"
				exit 9
			else
				echo "Pattern match for file $FN"
				echo "Pattern: $GWAS_PATTERN"
				echo "Resulting info file: $INFO_PATTERN"
				INFO="$INFO_PATTERN"
				echo $INFO > /tmp/info.txt #????
			fi
		fi
	done
	INFO=$(cat /tmp/info.txt)
	rm -f /tmp/info.txt
	if [ "$INFO" == "" ]
	then
		echo "INFO=$INFO"
		echo "No pattern matches filename: $FN"
		exit 9
	fi
	INFO=`echo $INFO | sed s/%CHR%/$CHR/`
	echo "Input:  $GWAS_IN_DIR/$OUT"
	echo "Info:   $INFO_IN_DIR/$INFO"
	echo "Output: $GWAS_OUT_DIR/$OUT"

        #####################################################################
        # JOIN
        #####################################################################

	# info: 1 chr_pos, 2 chr, 3 oevar_imp, 4 is_imputed
	# gwas quantitative: 2 chr_pos, imputed 17, oevap_imp 19
	# gwas binary: +4 cols (22 instead of 18)

	join --header -1 2 -2 1 \
		-t $'\t' \
		-o 1.1,1.2,1.3,1.4,1.5,1.6,1.7,1.8,1.9,1.10,1.11,1.12,1.13,1.14,1.15,1.16,2.4,1.18,2.3,1.20,1.21,1.22,1.23 \
		$GWAS_IN_DIR/$OUT $INFO_IN_DIR/$INFO > $GWAS_OUT_DIR/$OUT
done

echo "Joining files per chromosome"

for FN in `ls -1 $GWAS_OUT_DIR/*chr01*`
do
	BN=`basename $FN`
	STAR_NAME=`echo $BN | sed s/chr01/chr??/`
	echo "Star name:  $STAR_NAME"
	NOCHR_NAME=`echo $BN | sed s/chr01\.//`
	echo "NoChr name: $NOCHR_NAME"

	/shared/cleaning/scripts/concat-without-headers.sh $GWAS_OUT_DIR/$STAR_NAME $GWAS_JOIN_DIR/$NOCHR_NAME

	echo "bgzip and tabix: $BN"
	cat $GWAS_JOIN_DIR/$NOCHR_NAME | bgzip > ${GWAS_JOIN_DIR}/${NOCHR_NAME}.gz
	tabix -s 4 -b 5 -e 5 -S 1 -f ${GWAS_JOIN_DIR}/${NOCHR_NAME}.gz
done

for FN in `ls -1 $GWAS_OUT_DIR/*chrX*`
do
        BN=`basename $FN`
	echo "Move $BN"
	cp $GWAS_OUT_DIR/$BN $GWAS_JOIN_DIR/

        echo "bgzip and tabix: $BN"
        cat $GWAS_JOIN_DIR/$BN | bgzip > ${GWAS_JOIN_DIR}/${BN}.gz
        tabix -s 4 -b 5 -e 5 -S 1 -f ${GWAS_JOIN_DIR}/${BN}.gz
done

md5sum $GWAS_JOIN_DIR/*.gwas | tee 05_gwas_combined.md5.txt
