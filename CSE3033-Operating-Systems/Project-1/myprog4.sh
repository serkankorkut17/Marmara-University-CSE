if [ $# -ne 1 ]
then
    	echo "Number of arguments should be one."
    	exit 1
elif [[ $1 =~ [^0-9] ]] || ! [ $1 -gt 2 ] 
then
	echo "The argument should be greather than 2."
	exit 1
fi


# This fucntion checks the first argument if it 
# is prime returns 1. Otherwise returns 0.

isPrime()
{
    for (( j=2;j<$1;j++ ))
    do
    	if [ `expr $1 % $j` -eq 0 ]
    	then
    	    return 0
    	fi
    done
    return 1  
}

# For the given first arguments it returns to
# hexadecimal notation.

getHexChar ()
{
	if [ $1 -lt 10 ]
	then
		echo -n "$1"
	elif [ $1 -eq 10 ]
	then
		echo -n "A"
	elif [ $1 -eq 11 ]
	then
		echo -n "B"
	elif [ $1 -eq 12 ]
	then
		echo -n "C"
	elif [ $1 -eq 13 ]
	then
		echo -n "D"
	elif [ $1 -eq 14 ]
	then
		echo -n "E"
	elif [ $1 -eq 15 ]
	then
		echo -n "F"
	fi
}

# For the given argument it prints the hexadecimal
# notation to the prompt.
convertToHex ()
{
	number=$1
	result=""
	while [ $number -ne 0 ]
	do
		digit=`expr $number % 16`
		result="$(getHexChar $digit)$result"
		number=`expr $number / 16`
	done
	echo "Hexadecimal of $1 is $result"
}

# It prints the hexadecimal notation starting
# from 2 up to given command line argument.

for (( i=2;i<$1;i++ ))
do
	isPrime $i
	if [ $? -eq 1 ]
	then
		convertToHex $i
	fi
done
