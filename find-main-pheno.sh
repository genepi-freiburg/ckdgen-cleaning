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
elif [[ $FN == *eGFR_* ]]
then
        echo "eGFR"
elif [[ $FN == *_egfr_* ]]
then
        echo "eGFR"
elif [[ $FN == *_MA_* ]]
then
        echo "MA"
elif [[ $FN == *_UACR_* ]]
then
        echo "UACR"
elif [[ $FN == *_uacr_* ]]
then
        echo "UACR"
elif [[ $FN == *_BUN_* ]]
then
        echo "BUN"
elif [[ $FN == *_bun_* ]]
then
        echo "BUN"
elif [[ $FN == *_urate_* ]]
then
        echo "urate"
elif [[ $FN == *_uric_acid_* ]]
then
        echo "urate"
elif [[ $FN == *uric_acid_* ]]
then
        echo "urate"
else
	echo "???"
fi


