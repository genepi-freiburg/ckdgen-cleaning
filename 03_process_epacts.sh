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
done
