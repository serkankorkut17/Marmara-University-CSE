if [ $# -ne 0 ]
then
   echo "Number of arguments should be zero."
   exit 1
fi

# Checks if a directory named "writable" exists.
# If not, it creates a new directory.

file="writable"
if [ -d $file ]
then
	echo "The folder already exists."
else
	mkdir "writable"
fi

# First checks if the files in the main directory are exist and only a file
# then checks if it is writable.
# Moves these files to the "writable" directory.

fileNumber=0
for i in `ls`
do
	if [ -f $i ]
	then
		if [ -w $i ]
		then
			mv $i $file
			fileNumber=`expr $fileNumber + 1`
		fi
	fi
done

echo "$fileNumber files moved to writable directory."
