BN=$1
if [ "$BN" == "" ]
then
	echo "Input basename missing"
	exit 3
fi

GWAS="05_gwas_combined/$BN"
QCTXT="06_gwasqc/gwasqc${BN}.txt"

TRAIT="Hallo" # TODO extract from file name
STRATUM="Stratum" # TODO extract from file name
CREATED=`ls --time-style=long-iso -l $GWAS | cut -f6-7 -d" "`
MD5SUM=`cat 05_gwas_combined.md5.txt | grep $BN | cut -f1 -d" "`
TODAY=`date +%Y-%m-%d`

NROWS=`cat $QCTXT | grep "Sample size" -A 2 | grep "N" | awk '{print $3}'`
NTOTAL=`cat $QCTXT | grep "Sample size" -A 7 | grep "Median" | awk '{print $3}'`

BETA_N=`cat $QCTXT | grep "Effect size (beta)" -A 19 | grep "Median
BETA_MEAN=`cat $QCTXT | grep "Effect size (beta)" -A 19 | grep "Median
BETA_MEDIAN
BETA_SD=`cat $QCTXT | grep "Sample size" -A 7 | grep "Median" | awk '{print $3}'`
BETA_MIN=`cat $QCTXT | grep "Sample size" -A 7 | grep "Median" | awk '{print $3}'`
BETA_MAX=`cat $QCTXT | grep "Sample size" -A 7 | grep "Median" | awk '{print $3}'`
BETA_Q1
BETA_Q3

# TODO add -n and tab
echo  "$BN"
echo  "$TRAIT"
echo  "$STRATUM"
echo  "$BN"
echo  "$CREATED"
echo  "$MD5SUM"
echo  "Analyst"
echo  "$TODAY"
echo  "OK?"
echo  ""
echo  "$NTOTAL"
echo  ""   # don't have cases
echo  "$NROWS"
echo  "$BETA_N"
echo  "$BETA_MEAN"
echo  "$BETA_SD"
echo  "$BETA_MIN"
echo  "$BETA_MAX"
echo  ""  # Beta Comment


#FileName	Trait	Stratum	FileName	FileCreationDate	MD5Checksum	Assigned Analyst	File Checking Date	FileOK?	Analyst Comments	N total	N cases (binary)	N rows	Beta_N	Beta_MEAN	Beta_SD	Beta_MIN	Beta_MAX	Beta_Comments	SE_N	SE_MEAN	SE_SD	SE_MIN	SE_MAX	SE_Comments	PVAL_N	PVAL_MEAN	PVAL_SD	PVAL_MIN	PVAL_MAX	PVAL_Comments	Af_coded_all_N	Af_coded_all_MEAN	Af_coded_all_SD	Af_coded_all_MIN	Af_coded_all_MAX	AF_coded_all_Comments	Oevar_imp_N	Oevar_imp_MEAN	Oevar_imp_SD	Oevar_imp_MIN	Oevar_imp_MAX	Oevar_imp_Comments	lambda unfiltered	lambda rsq >0.3, MAF >0.01	position plot ok?	AF plot ok?																																																																																																																																																																																																						
