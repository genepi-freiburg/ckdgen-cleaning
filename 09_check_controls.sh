rm -f 09_check_snps.txt

for FN in `ls 05_gwas_combined/*.gwas`
do
	echo "" | tee -a 09_check_snps.txt
	echo "================================================================" | tee -a 09_check_snps.txt
        echo "$FN" | tee -a 09_check_snps.txt
	echo "================================================================" | tee -a 09_check_snps.txt
        ../../scripts/pull-positive-control.sh $FN $POP | tee -a 09_check_snps.txt

done

