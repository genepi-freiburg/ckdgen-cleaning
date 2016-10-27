STUDY=$1

EXTRACT_FILE="/tmp/extract-${RANDOM}.txt"
POSITIVE_FILE="/tmp/positive-${RANDOM}.txt"

echo "Determine positive control to use"
echo "---------------------------------"

##################### DETERMINE POP AND PHENO

POP=`/shared/cleaning/scripts/find-population.sh $STUDY`
echo "Determined population: $POP"
if [ "$POP" == "???" ]
then
	echo "No population found - check filename: $STUDY"
	exit
fi

PHENO=`/shared/cleaning/scripts/find-main-pheno.sh $STUDY`
echo "Determined phenotype: $PHENO"
if [ "$PHENO" == "???" ]
then
        echo "No phenotype found - check filename: $STUDY"
        exit
fi



##################### FIND PARAMETERS

POSITIVE_CONTROLS="/shared/cleaning/data/positive-controls.txt"
head -n 1 $POSITIVE_CONTROLS > ${POSITIVE_FILE}
cat $POSITIVE_CONTROLS | grep $PHENO | grep $POP >> ${POSITIVE_FILE}

echo "Use this positive control(s):"
cat ${POSITIVE_FILE}

POSITIVES=`wc -l ${POSITIVE_FILE} | cut -f1 -d" "`
if [ "$POSITIVES" == "1" ]
then
	echo "No positive controls available for population $POP and phenotype $PHENO"
	exit 9
fi


##################### EXTRACT STUDY SNPs

FIND_COL="/shared/cleaning/scripts/find-column-index.pl"

STUDY_CHR=`$FIND_COL chr $STUDY`
STUDY_POS=`$FIND_COL position $STUDY`
STUDY_ALL1=`$FIND_COL 'REF' $STUDY`
STUDY_ALL2=`$FIND_COL 'ALT' $STUDY`
STUDY_FREQ=`$FIND_COL AF_coded_all $STUDY`
STUDY_PVAL=`$FIND_COL pvalue $STUDY`
STUDY_BETA=`$FIND_COL beta $STUDY`

if [ "$STUDY_ALL1" == "-1" ] || [ "$STUDY_ALL2" == "-1" ]
then
	STUDY_ALL1=`$FIND_COL noncoded_all $STUDY`
	STUDY_ALL2=`$FIND_COL coded_all $STUDY`
fi

if [ "$STUDY_PVAL" == "-1" ]
then
	STUDY_PVAL=`$FIND_COL pval $STUDY`
fi

echo ""
echo "Column indices in STUDY file"
echo "----------------------------"
echo "Study: $STUDY"
echo "Chromosome column: $STUDY_CHR"
echo "Position column: $STUDY_POS"
echo "Allele 1 column: $STUDY_ALL1"
echo "Allele 2 column: $STUDY_ALL2"
echo "Frequency column: $STUDY_FREQ"
echo "p-value column: $STUDY_PVAL"
echo "Beta column: $STUDY_BETA"

if [ "$STUDY_CHR" == "-1" ] || [ "$STUDY_POS" == "-1" ] || [ "$STUDY_ALL1" == "-1" ] || [ "$STUDY_ALL2" == "-1" ] || [ "$STUDY_FREQ" == "-1" ] || [ "$STUDY_PVAL" == "-1" ] || [ "$STUDY_BETA" == "-1" ]
then
        echo "Column in STUDY file not found - check indices and header."
        exit
fi


echo ""
echo "Extract SNPs from study file"
echo "----------------------------"

echo "chr	position	noncoded_all	coded_all	AF_coded_all	beta	pvalue" > ${EXTRACT_FILE}

I=0
while IFS='' read -r LINE || [[ -n "$LINE" ]]
do

# trait	ethnicity	SNP	gene	chr	pos	ref	alt	MAF_1KGP	direction_alt

if [ "$I" -gt 0 ]
then
	echo "Process positive control $I"
	echo $LINE
	SNP_GENE=`echo $LINE | cut -f 4 -d" "`
	SNP_CHROM=`echo $LINE | cut -f 5 -d" "`
	SNP_POS=`echo $LINE | cut -f 6 -d" "`
	echo "Gene: $SNP_GENE"
	echo "Detect chromosome: $SNP_CHROM"
	echo "Detect position: $SNP_POS"
	cat $STUDY  | \
        awk -v chr=$STUDY_CHR -v pos=$STUDY_POS -v all1=$STUDY_ALL1 -v all2=$STUDY_ALL2 -v freq=$STUDY_FREQ -v beta=$STUDY_BETA -v pval=$STUDY_PVAL \
	    -v snp_chr=$SNP_CHROM -v snp_pos=$SNP_POS \
        'BEGIN { OFS="\t" } { 
		if ($(chr+1) == snp_chr && $(pos+1) == snp_pos) { 
			print $(chr+1), $(pos+1), $(all1+1), $(all2+1), $(freq+1), $(beta+1), $(pval+1) 
		} 
	}' >> ${EXTRACT_FILE}
else
	echo "(Skip header line)"
fi
I=$((I+1))

done < ${POSITIVE_FILE}


echo ""
echo "Extraction result:"
cat ${EXTRACT_FILE}

SNP_COUNT=`wc -l ${EXTRACT_FILE} | cut -f1 -d" "`
echo ""
echo "Got SNPs (plus 1): ${SNP_COUNT}"

if [ "${SNP_COUNT}" == "1" ]
then
	echo "Did not find any SNPs"
	exit 9
fi

if [ "$POSITIVES" -ne "${SNP_COUNT}" ]
then
        echo "Did not find a SNP for each positive control"
fi

################## INTERPRET RESULT

Rscript /shared/cleaning/scripts/interpret-positive-controls.R ${EXTRACT_FILE} ${POSITIVE_FILE}

#rm -vf ${EXTRACT_FILE} ${POSITIVE_FILE}


