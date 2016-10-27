POP=$1
echo "Using POP: $POP"
if [ "$POP" == "" ]
then
	echo "Please specify population as parameter: EUR AFR AMR EAS SAS"
	exit
fi

mkdir -p 08_plot_freqs
for FN in `ls 06_concat/*.epacts`
do
	echo "Check $FN with KGP $POP"
	../../scripts/join-to-kgp-and-plot.sh $FN $POP

	mv -v $FN*.png 08_plot_freqs
done
