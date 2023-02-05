#
# Script to test if..elif...else
#
if test $1 -gt 0
then
   echo "$1 is positive"
elif test $1 -lt 0 
then
   echo "$1 is negative "
elif test $1 -eq 0
then 
   echo "$1 is zero"
else
   echo "Opps! $1 is not number, please give number"
fi