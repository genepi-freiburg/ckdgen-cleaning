FN=$1
if [ "$FN" == "" ]
then
	echo "Need filename"
elif [[ $FN == *nonDM* ]] || [[ $FN == *nondm* ]]
then
        echo "nonDM"
elif [[ $FN == *_DM* ]] || [[ $FN == *_dm* ]]
then
        echo "DM"
elif [[ $FN == *_men* ]]
then
        echo "men"
elif [[ $FN == *women* ]]
then
        echo "women"
elif [[ $FN == *_overall_* ]]
then
        echo "overall"
elif [[ $FN == *overall* ]]
then
        echo "overall"
elif [[ $FN == *CKD* ]] || [[ $FN == *ckd* ]]
then
	# eGFR_decline_CKD, but CKD is also pheno!
	echo "CKD"
else
	echo "???"
fi


