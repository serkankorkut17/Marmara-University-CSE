
content_name=$1 # holds first argument
file_name="${content_name::-1}"

yes_count=0 # it holds the number of removed files.
  
  
# This function removes the files
# in the current directory if the 
# given argument condition holds.(first argument)

deleteFile ()
{
	string_path_name=`ls ./$file_name*`
 	for eachfile in $string_path_name 
 	do
 		if [ -f $eachFile ]
 		then
	  		file=${eachfile:2}
	  		parent_dic=${PWD##*/} #
	  		new_path=$parent_dic'/'$file #
	 
	  		echo -n "Do you want to delete $new_path? ( y/n ):"
	  		
	  		read answer
	  		if [ $answer = "y" ]
	  		then
	    			rm ./"$file"
	    			yes_count=$((yes_count+1))
	  		fi
	  	fi
 	done
}

# Recursivly it checks all the subdirectories
# with the start path as the given optinal argument.
# If the condition holds it calls the deleteFile()
# and remove the files.

deleteFileInAll ()
{
	
	cd $1
	
	deleteFile
	
	for i in `ls $PWD`
	do
		if [ -d $i ]
		then
			deleteFileInAll $i
		fi
	done
}

if [ $# -eq 1 ]
then
	deleteFile
	echo "$yes_count file deleted."
elif [ $# -eq 2 ]
then
	path=$2
	deleteFileInAll $path
	echo "$yes_count file deleted."
else
	echo "Number of arguments should be one or two."
	exit 1
fi

