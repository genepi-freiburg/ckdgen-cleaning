mkdir -p 08_plot_freqs
for FN in `ls 05_gwas_combined/*.gwas`
do
	POP=`/shared/cleaning/scripts/find-population.sh $FN`
	if [ "$POP" == "???" ]
	then
		echo "Unable to detect population for: $FN"
		echo "SKIP!"
	else
		echo "Check $FN with KGP $POP"
		/shared/cleaning/scripts/join-to-kgp-and-plot.sh $FN $POP

		mv -v $FN*.png 08_plot_freqs
	fi
done
