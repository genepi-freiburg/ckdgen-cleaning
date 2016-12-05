mkdir -p 05_gwas_single
for FN in `ls 05_gwas_combined/*.gwas`
do
	BN=`basename $FN`
	NOEXT=${BN%.*}
	OUT="05_gwas_single/${NOEXT}_chr%C%.gwas"
	echo "Split file: $FN"
	echo "Base name: $BN"
	echo "No extension: $NOEXT"
	echo "Output: $OUT"

	/shared/cleaning/scripts/split-file.pl -i $FN -o $OUT -c 'chr'
done


