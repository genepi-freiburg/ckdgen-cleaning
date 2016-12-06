GWASCOMB_IN=05_gwas_combined

OUTFILE=11_summaries.txt

echo "File Name	Trait	Stratum	FileCreationDate	MD5Checksum	Assigned Analyst	File Checking Date	FileOK?	Analyst Comments	N total	N cases (binary)	N rows	Beta_MEDIAN	Beta_MEAN	Beta_SD	Beta_Q1	Beta_Q3	Beta_Comments	SE_MEDIAN	SE_MEAN	SE_SD	SE_Q1	SE_Q3	SE_Comments	PVAL_N	PVAL_MEAN	PVAL_SD	PVAL_MIN	PVAL_MAX	PVAL_Comments	AF_coded_all_MEDIAN	AF_coded_all_MEAN	AF_coded_all_SD	AF_coded_all_Q1	AF_coded_all_Q3	AF_coded_all_Comments	IQ_MEDIAN	IQ_MEAN	IQ_SD	IQ_Q1	IQ_Q3	IQ_Comments	lambda unfiltered	lambda rsq >0.3, MAF >0.01	position plot ok?	AF plot ok?" > $OUTFILE

for FN in `ls -1 $GWASCOMB_IN/*.gwas`
do
	BN=`basename $FN`
	echo "====================================================="
	echo "Extract summaries for $BN"
	../../scripts/extract-summaries-for-file.sh $BN >> $OUTFILE

done
