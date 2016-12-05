RENAMES=$1

if [ "$RENAMES" == "" ]
then
        echo "Usage: $0 <renameColumns> <file1> <file2>..."
        echo "Rename columns: oldname1=newname1,oldname2=newname2..."
        exit 3
fi

shift

for FN in $@
do

if [ ! -f "$FN" ]
then
	echo "Input file does not exist: $FN"
	exit 3
fi

echo ""
echo "Process file: $FN"
echo "==============================="

RENAMES2=$(echo $RENAMES | tr "," "\n")
HEADER=`head -n 1 $FN`

echo "Old header: $HEADER"

for RENAME in $RENAMES2
do
	OLD=$(echo $RENAME | cut -d= -f1)
	NEW=$(echo $RENAME | cut -d= -f2)
	echo "Rename $OLD to $NEW"
	HEADER=`echo "$HEADER" | sed s/$OLD/$NEW/`
done

echo "New header: $HEADER"

echo "$HEADER" > $FN.new
tail -n +2 $FN >> $FN.new

mv $FN.new $FN

done
