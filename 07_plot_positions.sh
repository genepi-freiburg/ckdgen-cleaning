mkdir -p 07_plot_positions
for FN in `ls 05_gwas_single/*.gwas`
do
	BN=`basename $FN`
	echo "Plot positions: $BN"

	Rscript /shared/cleaning/scripts/plot-position.R $FN "$BN" 07_plot_positions/${BN}.png

done
