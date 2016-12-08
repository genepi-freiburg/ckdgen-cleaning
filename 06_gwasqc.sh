#!/bin/bash

SCRIPTS=/shared/cleaning/scripts
WD=`pwd`

rm -rf 06_gwasqc
mkdir 06_gwasqc
cd 06_gwasqc
cp $SCRIPTS/gwasqc.R .
cp $SCRIPTS/gwasqc-params-template.txt gwasqc-params.txt

for FN in `ls -1 ../05_gwas_combined/*.gwas`
do
	BN=`basename $FN`
	echo "PROCESS $BN" >> gwasqc-params.txt
	ln -s $FN .
done

ls -l
Rscript gwasqc.R

# cleanup links
rm *.gwas

cd $WD
