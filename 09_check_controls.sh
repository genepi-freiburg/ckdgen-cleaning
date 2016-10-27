rm -f 09_check_snps.txt

for FN in `ls 05_gwas_combined/*.gwas`
do
	echo ""
	echo "================================================================"
        echo "$FN"
	echo "================================================================"
        ../../scripts/pull-positive-control.sh $FN $POP | tee -a 09_check_snps.txt

done

