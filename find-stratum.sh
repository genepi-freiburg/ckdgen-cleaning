FN=$1
if [ "$FN" == "" ]
then
	echo "Need filename"
elif [[ $FN == *nonDM* ]] || [[ $FN == *nondm* ]]
then
        echo "nonDM"
elif [[ $FN == *_DM* ]]
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
else
	echo "???"
fi


