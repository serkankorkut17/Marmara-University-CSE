if [ $# -ne 2 ]
then
   echo "Total agruments must be 2"
   exit 1
elif [[ $2 =~ [^0-9] ]] || ! [ $2 -ge 0 ] 
then
   echo "The second argument should be zero or positive number."
   exit 1
fi

string=$1 # holds first argument
number=$2 # holds second argument

number_length=$(echo -n "$number"|wc -c) # holds length of given number
string_length=$(echo -n "$string"|wc -c) # holds length of given string


if [ $number_length -ne $string_length ] && [ $number_length -ne 1 ]  # checks conditions
then
   echo "The number has to have a length of either 1 or
same as the string"
   exit 1
fi


if [ $number_length -eq $string_length ] # first case: string_length=number_length
then
   #For each characer in the string it calculates
   #the ascii number. After,for each number in the second argument
   #it adds the given numbers to the previous ascii number accordingly.  
   #Lastly, it puts the each letter in the result string after 
   #coverting them to the character reprsentation.
   result=""
   for (( i=0; i<number_length; i++))
   do
    var=$(expr $number % 10)
    last_char=${string: -1}
    asc_last_char=$(echo -n "$last_char"| od -An -tuC)
    new_char_asc_val=$(expr $asc_last_char + $var)
    if [ $new_char_asc_val -gt 122 ]
    then
       new_char_asc_val=$(expr $new_char_asc_val - 26)
    fi  
    word=$(echo "$new_char_asc_val"| awk '{ printf("%c",$0); }')
    result=${word}${result}
    number=$(expr $number / 10)
    var=$(expr $var / 10)
    string=$(echo "$string" | rev | cut -c2- | rev)
   done
echo $result 


elif [ $number_length -eq 1 ] # second case: number_length=1
then
    result=""
   #For each characer in the string it calculates
   #the ascii number. After, it adds the given 
   #number( same movement for all characters)
   #to the previous ascii number accordingly.  
   #Lastly, it puts the each letter in the result string after 
   #coverting them to the character reprsentation.
    for (( i=0; i<string_length; i++))
    do
     last_char=${string: -1}
     asc_last_char=$(echo -n "$last_char"| od -An -tuC)
     new_char_asc_val=$(expr $asc_last_char + $number)
     if [ $new_char_asc_val -gt 122 ]
     then
       new_char_asc_val=$(expr $new_char_asc_val - 26)
     fi  
     word=$(echo "$new_char_asc_val"| awk '{ printf("%c",$0); }')
     result=${word}${result}
     string=$(echo "$string" | rev | cut -c2- | rev)
    done
echo $result     
fi
