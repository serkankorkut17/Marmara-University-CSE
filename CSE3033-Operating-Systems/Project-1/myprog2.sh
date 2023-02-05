if [ $# -ne 1 ]
then
    echo "Number of arguments should be one."
    exit 1
fi

filetoWrite=$1 # holds first argument


# This function takes file to be read as first argument.
# Reads a random line from this file.

createParagraph ()
{
	fileToRead=$1
	randomNumber=`expr $RANDOM % 3 + 1`
	i=1
	while read line
	do
		if [ -n "$line" ]
		then
			if [ $i -eq $randomNumber ]
			then
				echo -e $line '\n'
			fi
			i=`expr $i + 1`
		fi
	done < $fileToRead
}

# This function reads all 3 files to create a random story and 
# writes them to the given file.

writeStory ()
{
	createParagraph "giris.txt" > $filetoWrite
	createParagraph "gelisme.txt" >> $filetoWrite
	createParagraph "sonuc.txt" >> $filetoWrite
}

# If the given file exists, it will ask you if you want to modify this file.
# Then it will create a story and write it to the given file.

if [ -f $filetoWrite ]
then
	echo -n "$filetoWrite exists. Do you want it to be modified? (y/n): "
	read choice
	if [ "y" = $choice ]
	then
		writeStory
		echo "A random story is created and stored in $filetoWrite."
	else
		echo "Story isn't saved."
	fi
else
	writeStory
	echo "A random story is created and stored in $filetoWrite."
fi


