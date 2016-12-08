BN=$1
if [ "$BN" == "" ]
then
	echo "Input basename missing"
	exit 3
fi

GWAS="05_gwas_combined/$BN"
QCTXT="06_gwasqc/gwasqc${BN}.txt"

if [ ! -f $GWAS ]
then
	echo "GWAS file missing: $GWAS"
	exit 3
fi

if [ ! -f $QCTXT ]
then
	echo "QC text file missing: $QCTXT"
	exit 3
fi

TRAIT=`/shared/cleaning/scripts/find-main-pheno.sh $GWAS`
STRATUM=`/shared/cleaning/scripts/find-stratum.sh $GWAS`
CREATED=`ls --time-style=long-iso -l $GWAS | cut -f6-7 -d" "`
MD5SUM=`cat 05_gwas_combined.md5.txt | grep "${BN}$" | cut -f1 -d" "`
TODAY=`date +%Y-%m-%d`
>&2 echo "Date: $TODAY, Trait: $TRAIT, Stratum: $STRATUM, Created: $CREATED, MD5: $MD5SUM"


NROWS=`cat $QCTXT | grep "Sample size" -A 2 | grep "N" | awk '{print $3}'`
NTOTAL=`cat $QCTXT | grep "Sample size" -A 7 | grep "Median" | awk '{print $3}'`

>&2 echo "Sample Size: n(rows) = $NROWS, n(total) = $NTOTAL"


BETA_N=`cat $QCTXT | grep "Effect size (beta)" -A 2 | grep "N " | awk '{ print $3 }'`
BETA_MEAN=`cat $QCTXT | grep "Effect size (beta)" -A 19 | grep "Mean" | awk '{ print $3 }'`
BETA_MEDIAN=`cat $QCTXT | grep "Effect size (beta)" -A 19 | grep "Median" | awk '{ print $4 }'`
BETA_SD=`cat $QCTXT | grep "Effect size (beta)" -A 19 | grep "StdDev" | awk '{ print $3 }'`
BETA_MIN=`cat $QCTXT | grep "Effect size (beta)" -A 19 | grep "Min" | awk '{ print $4 }'`
BETA_MAX=`cat $QCTXT | grep "Effect size (beta)" -A 19 | grep "Max" | awk '{ print $4 }'`
BETA_Q1=`cat $QCTXT | grep "Effect size (beta)" -A 19 | grep "25%" | awk '{ print $3 }'`
BETA_Q3=`cat $QCTXT | grep "Effect size (beta)" -A 19 | grep "75%" | awk '{ print $3 }'`

>&2 echo "Beta: N = $BETA_N, mean = $BETA_MEAN, median = $BETA_MEDIAN, sd = $BETA_SD, min = $BETA_MIN, max = $BETA_MAX, q1 = $BETA_Q1, q3 = $BETA_Q3"




SE_N=`cat $QCTXT | grep "Standard error (SE)" -A 10 | grep "N " | awk '{ print $3 }'`
SE_MEAN=`cat $QCTXT | grep "Standard error (SE)" -A 19 | grep "Mean" | awk '{ print $3 }'`
SE_MEDIAN=`cat $QCTXT | grep "Standard error (SE)" -A 19 | grep "Median" | awk '{ print $4 }'`
SE_SD=`cat $QCTXT | grep "Standard error (SE)" -A 19 | grep "StdDev" | awk '{ print $3 }'`
SE_MIN=`cat $QCTXT | grep "Standard error (SE)" -A 19 | grep "Min" | awk '{ print $4 }'`
SE_MAX=`cat $QCTXT | grep "Standard error (SE)" -A 25 | grep "Max" | awk '{ print $4 }'`
SE_Q1=`cat $QCTXT | grep "Standard error (SE)" -A 19 | grep "25%" | awk '{ print $3 }'`
SE_Q3=`cat $QCTXT | grep "Standard error (SE)" -A 25 | grep "75%" | awk '{ print $3 }'`

>&2 echo "SE: N = $SE_N, mean = $SE_MEAN, median = $SE_MEDIAN, sd = $SE_SD, min = $SE_MIN, max = $SE_MAX, q1 = $SE_Q1, q3 = $SE_Q3"


PVAL_N=`cat $QCTXT | grep "P-value (pval)" -A 10 | grep "N " | awk '{ print $3 }'`
PVAL_MEAN=`cat $QCTXT | grep "P-value (pval)" -A 19 | grep "Mean" | awk '{ print $3 }'`
PVAL_MEDIAN=`cat $QCTXT | grep "P-value (pval)" -A 19 | grep "Median" | awk '{ print $4 }'`
PVAL_SD=`cat $QCTXT | grep "P-value (pval)" -A 19 | grep "StdDev" | awk '{ print $3 }'`
PVAL_MIN=`cat $QCTXT | grep "P-value (pval)" -A 19 | grep "Min" | awk '{ print $4 }'`
PVAL_MAX=`cat $QCTXT | grep "P-value (pval)" -A 25 | grep "Max" | awk '{ print $4 }'`
PVAL_Q1=`cat $QCTXT | grep "P-value (pval)" -A 19 | grep "25%" | awk '{ print $3 }'`
PVAL_Q3=`cat $QCTXT | grep "P-value (pval)" -A 25 | grep "75%" | awk '{ print $3 }'`

>&2 echo "PVAL: N = $PVAL_N, mean = $PVAL_MEAN, median = $PVAL_MEDIAN, sd = $PVAL_SD, min = $PVAL_MIN, max = $PVAL_MAX, q1 = $PVAL_Q1, q3 = $PVAL_Q3"


AF_N=`cat $QCTXT | grep "Minor allele frequency" -A 10 | grep "N " | awk '{ print $3 }'`
AF_MEAN=`cat $QCTXT | grep "Minor allele frequency" -A 19 | grep "Mean" | awk '{ print $3 }'`
AF_MEDIAN=`cat $QCTXT | grep "Minor allele frequency" -A 19 | grep "Median" | awk '{ print $4 }'`
AF_SD=`cat $QCTXT | grep "Minor allele frequency" -A 19 | grep "StdDev" | awk '{ print $3 }'`
AF_MIN=`cat $QCTXT | grep "Minor allele frequency" -A 19 | grep "Min (0%)" | awk '{ print $4 }'`
AF_MAX=`cat $QCTXT | grep "Minor allele frequency" -A 25 | grep "Max" | awk '{ print $4 }'`
AF_Q1=`cat $QCTXT | grep "Minor allele frequency" -A 19 | grep "25%" | awk '{ print $3 }'`
AF_Q3=`cat $QCTXT | grep "Minor allele frequency" -A 25 | grep "75%" | awk '{ print $3 }'`

>&2 echo "AF_coded_all: N = $AF_N, mean = $AF_MEAN, median = $AF_MEDIAN, sd = $AF_SD, min = $AF_MIN, max = $AF_MAX, q1 = $AF_Q1, q3 = $AF_Q3"




IQ_N=`cat $QCTXT | grep "Imputation quality" -A 10 | grep "N " | awk '{ print $3 }'`
IQ_MEAN=`cat $QCTXT | grep "Imputation quality" -A 19 | grep "Mean" | awk '{ print $3 }'`
IQ_MEDIAN=`cat $QCTXT | grep "Imputation quality" -A 19 | grep "Median" | awk '{ print $4 }'`
IQ_SD=`cat $QCTXT | grep "Imputation quality" -A 19 | grep "StdDev" | awk '{ print $3 }'`
IQ_MIN=`cat $QCTXT | grep "Imputation quality" -A 19 | grep "Min" | awk '{ print $4 }'`
IQ_MAX=`cat $QCTXT | grep "Imputation quality" -A 25 | grep "Max" | awk '{ print $4 }'`
IQ_Q1=`cat $QCTXT | grep "Imputation quality" -A 19 | grep "25%" | awk '{ print $3 }'`
IQ_Q3=`cat $QCTXT | grep "Imputation quality" -A 25 | grep "75%" | awk '{ print $3 }'`

>&2 echo "IQ: N = $IQ_N, mean = $IQ_MEAN, median = $IQ_MEDIAN, sd = $IQ_SD, min = $IQ_MIN, max = $IQ_MAX, q1 = $IQ_Q1, q3 = $IQ_Q3"





# echo "File Name	Trait	Stratum	FileCreationDate	MD5Checksum	Assigned Analyst	File Checking Date	FileOK?	Analyst Comments	N total	N cases (binary)	N rows	Beta_MEDIAN	Beta_MEAN	Beta_SD	Beta_Q1	Beta_Q3	Beta_Comments	SE_MEDIAN	SE_MEAN	SE_SD	SE_Q1	SE_Q3	SE_Comments	PVAL_N	PVAL_MEAN	PVAL_SD	PVAL_MIN	PVAL_MAX	PVAL_Comments	AF_coded_all_MEDIAN	AF_coded_all_MEAN	AF_coded_all_SD	AF_coded_all_Q1	AF_coded_all_Q3	AF_coded_all_Comments	IQ_MEDIAN	IQ_MEAN	IQ_SD	IQ_Q1	IQ_Q3	IQ_Comments	lambda unfiltered	lambda rsq >0.3, MAF >0.01	lambda rsq >0.9, MAF >0.05	position plot ok?	AF plot ok?"
echo -n "$BN	"
echo -n "$TRAIT	"
echo -n "$STRATUM	"
echo -n "$CREATED	"
echo -n "$MD5SUM	"
echo -n "$USER	"
echo -n "$TODAY	"
echo -n "<file ok?>	"
echo -n "<your comments>	"
echo -n "$NTOTAL	"
echo -n "	"   # TODO don't have cases
echo -n "$NROWS	"
echo -n "$BETA_MEDIAN	"
echo -n "$BETA_MEAN	"
echo -n "$BETA_SD	"
echo -n "$BETA_Q1	"
echo -n "$BETA_Q3	"
echo -n "	"
echo -n "$SE_MEDIAN	"
echo -n "$SE_MEAN	"
echo -n "$SE_SD	"
echo -n "$SE_Q1	"
echo -n "$SE_Q3	"
echo -n "	"
echo -n "$PVAL_N	"
echo -n "$PVAL_MEAN	"
echo -n "$PVAL_SD	"
echo -n "$PVAL_MIN	"
echo -n "$PVAL_MAX	"
echo -n "	"
echo -n "$AF_MEDIAN	"
echo -n "$AF_MEAN	"
echo -n "$AF_SD	"
echo -n "$AF_Q1	"
echo -n "$AF_Q3	"
echo -n "	"
echo -n "$IQ_MEDIAN	"
echo -n "$IQ_MEAN	"
echo -n "$IQ_SD	"
echo -n "$IQ_Q1	"
echo -n "$IQ_Q3	"
echo -n "	"
echo -n "<lambda_unf>	"
echo -n "<lambda_filt1>	"
echo -n "<lambda_filt2>	"
echo -n "<pos ok?>	"
echo -n "<af ok?>"
echo

>&2 echo DONE: $BN


