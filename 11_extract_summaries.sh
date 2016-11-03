GWASCOMB_IN=05_gwas_combined
for FN in `ls -1 $GWASCOMB_IN`
do
	BN=`basename $FN`
	echo "Extract summaries for $BN"
	../../scripts/extract-summaries-for-file.sh $BN
done
