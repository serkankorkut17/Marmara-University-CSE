#
# Script to print uer information who currently login, current date & times
#
#
clear
echo "Hello $USER"
echo "Today is `date`"
echo "Number of user login `who | wc -l`"
echo "Calendar `cal`"
exit 0