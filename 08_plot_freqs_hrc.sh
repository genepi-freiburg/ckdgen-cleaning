mkdir -p 08_plot_freqs
for FN in `ls 06_concat/*.epacts`
do
	echo "Check $FN with HRC"
	../../scripts/join-to-hrc-and-plot.sh $FN

	mv -v $FN*.png 08_plot_freqs
done
