cd /shared/cleaning/data

POPS="EAS EUR AFR AMR SAS"

for POP in $POPS
do
	echo "Process $POP"
	FN="1KGP_Phase3_${POP}_frequencies.txt"
	if [ -f "${FN}" ]
	then
		echo "Exists -> skip"
	else
		echo "CHROM	POS	REF	ALT	${POP}_AF" > ${FN}
		vcf-query ALL.wgs.phase3_shapeit2_mvncall_integrated_v5b.20130502.sites.vcf.gz -f "%CHROM\t%POS\t%REF\t%ALT\t%INFO/${POP}_AF\n" >> ${FN}
	fi
done
