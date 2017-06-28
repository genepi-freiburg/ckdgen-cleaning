EPACTS_IN="01_epacts_input"
GWAS_OUT="03_gwas_noinfo"
rm -rf $GWAS_OUT
mkdir -p $GWAS_OUT
for FN in `ls $EPACTS_IN/*.epacts.gz`
do
	BN=`basename $FN`
        BN=${BN%.*} # remove trailing .gz
        BN=${BN%.*} # remove trailing epacts
	echo "Processing: $BN"
	/shared/cleaning/scripts/epacts2gwas.pl -i $FN -o $GWAS_OUT/${BN}.gwas

	OUTFN="$GWAS_OUT/${BN}.gwas"
	echo "Sorting: $OUTFN"
	(head -n 1 $OUTFN && tail -n +2 $OUTFN | sort -k 2) > ${OUTFN}.sorted
	mv ${OUTFN}.sorted $OUTFN
done

md5sum $EPACTS_IN/*.gz | tee 01_epacts_input.md5.txt
