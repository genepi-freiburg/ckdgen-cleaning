mkdir -p 08_plot_freqs
for FN in `ls 05_gwas_combined/*gwas`
do
	echo "Check $FN with HRC"
	/shared/cleaning/scripts/join-to-hrc-and-plot.sh $FN

	mv -v $FN*.png 08_plot_freqs
done
