FN=$1
if [ "$FN" == "" ]
then
	echo "Need filename"
elif [[ $FN == *_EUR_* ]]
then
	echo "EUR"
elif [[ $FN == *_EA_* ]]
then
        echo "EUR"
elif [[ $FN == *_HIS* ]]
then
        echo "EUR"
elif [[ $FN == *_AFR_* ]]
then
        echo "AFR"
elif [[ $FN == *AA* ]]
then
        echo "AFR"
elif [[ $FN == *_AMR_* ]]
then
        echo "AMR"
elif [[ $FN == *_EAS_* ]]
then
        echo "EAS"
elif [[ $FN == *_Chinese* ]]
then
	echo "EAS"
elif [[ $FN == *_SAS_* ]]
then
        echo "SAS"
elif [[ $FN == *_SA_* ]]
then
        echo "SAS"
else
	echo "???"
fi


