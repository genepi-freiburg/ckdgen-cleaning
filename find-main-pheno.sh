FN=$1
if [ "$FN" == "" ]
then
	echo "Need filename"
elif [[ $FN == *_creatinine_* ]]
then
	echo "creatinine"
elif [[ $FN == *_eGFR_* ]]
then
        echo "eGFR"
elif [[ $FN == *_MA_* ]]
then
        echo "MA"
elif [[ $FN == *_UACR_* ]]
then
        echo "UACR"
elif [[ $FN == *_BUN_* ]]
then
        echo "BUN"
elif [[ $FN == *_urate_* ]]
then
        echo "urate"
else
	echo "???"
fi


