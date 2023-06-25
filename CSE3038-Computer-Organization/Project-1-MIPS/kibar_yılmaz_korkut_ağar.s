            .data
array:      .space 100
prmpt0:     .asciiz "Welcome to our MIPS project!\n"
prmpt1:     .asciiz "Main Menu :\n1 . Find Palindrome\n2 . Reverse Vowels\n3 . Find Distinct Prime\n4 . Lucky Number\n5 . Exit\nPlease select an option: "
prmpt2:     .asciiz "Program ends. Bye :)"
prmpt3:     .asciiz "Input: "
prmpt4:     .asciiz "Enter an integer number: "
prmpt5:     .asciiz "Input: Enter the number of rows: "
prmpt6:     .asciiz "Enter the number of columns: "
prmpt7:     .asciiz "Enter the elements of the matrix: "
prmpt8:     .asciiz "Output: The matrix should have only unique values.\n\n"
prmpt9:     .asciiz "Output: The lucky number is "
prmpt10:    .asciiz ".\n"
prmpt11:    .asciiz "Output: The longest palindrome is "
prmpt12:    .asciiz ", and its length is "
prmpt13:    .asciiz " "
prmpt14:    .asciiz " is a square-free number and distinct prime factors: "
prmpt15:    .asciiz " is not a square-free number.\n"
prmpt16:    .asciiz "\n"
prmpt17:    .asciiz "Output: "
            .text
            .globl main
main:       li $v0,4
            la $a0,prmpt0 
            syscall # Print welcome message
while:      li   $v0, 4 # Infinite loop, displays the menu each iteration
            la   $a0, prmpt1 
            syscall # Print the menu
            li	$v0, 5
            syscall # Get the user's choice into $v0 register
case1:      li $t0,1 # This part is equivalent to switch case in C
            bne $v0,$t0,case2 # If users choice isn't 1 branch to case2 label
            li $v0,4
            la $a0, prmpt3 # Print 'Input: '
            syscall
            li $v0,8
            la $a0, array
            li $a1, 100
            syscall  # Get the input string required for findPalindrome procedure into $a0
            jal findPalindrome # Call for findPalindrome, $a0 is argument to this procedure
            j while # Jump to while label to display menu again
case2:      li $t0,2
            bne $v0,$t0,case3 # If users choice isn't 2 branch to case3 label
            li $v0,4 
            la $a0, prmpt3 
            syscall # Print 'Input: '
            li $v0,8
            la $a0, array 
            li $a1, 100
            syscall # Get the input string required for reverseVowels procedure into $a0
            jal reverseVowels # Call for reverseVowels, $a0 is argument to this procedure
            j while # Jump to while label to display menu again
case3:      li $t0,3 
            bne $v0,$t0,case4 # If users choice isn't 2 branch to case4 label
            li $v0,4
            la $a0, prmpt4 
            syscall # Prompt user to enter an integer number
            li   $v0, 5
            syscall # Get the user input to $v0 register
            move $a0,$v0 # Prepare argument for findDprime procedure
            jal findDPrime # Call for findDprime procedure
            j while # Jump to while label to display menu again
case4:      li $t0,4
            bne $v0,$t0,case5 #  If users choice isn't 4 branch to case5 label
            li $v0,4
            la $a0, prmpt5
            syscall # Prompt the user to enter number of rows in the matrix
            li	$v0, 5
		    syscall # Get the user input into $v0 register
            move $t5,$v0 # Save user input for number of rows into $t5
            li $v0,4
            la $a0, prmpt6 
            syscall # Prompt the user to enter number of columns in the matrix
            li	$v0, 5
		    syscall # Get the user input into $v0 register
            move $t6, $v0 # Save user input for number of columns into $t6
            li $v0, 4
            la $a0, prmpt7
            syscall # Prompt user to enter elements of matrix
            move $a2,$v0
            li $v0,8
            la $a0, array
            li $a1, 100
            syscall # Get the input string into $a0
            move $a1,$t5 # Move number of rows to $a1 to be argument
            move $a2,$t6 # Move number of columns to $a2 to be argument
            jal luckyNumber # Call for luckyNumber, $a0,$a1,$a2 are arguments to this procedure
            j while #  Jump to while label to display menu again
case5:      li $t0,5 
            bne $v0,$t0,while # If user entered wrong input jump to while label to display menu again
            j endwhile # User entered 5, exit from the loop
endwhile:   li   $v0, 4 
            la   $a0, prmpt2 
            syscall # Print program ends message
            li $v0, 10            
            syscall # Terminate the program
    
#$a0 -> input string
findPalindrome:
            add $t0,$a0,$zero  # $t0 address of input
            addi $sp,$sp,-4    # store $ra and $a0
            sw $ra,0($sp)
            addi $sp,$sp,-4
            sw $a0,0($sp)
            add $s0,$zero,$zero     # length of the palindrome
            add $s1,$zero,$zero     # count if same letter +1
            addi $s2,$zero,2        # count should be 2
            li $s3,96       # lowercase a = 0x61 = 97
            li $s4,123      # lowercase z = 0x7a = 122
            li $s5,64       # uppercase A = 0x41 = 65
            li $s6,91       # uppercase Z = 0x5a = 90
            li $v0,4
            la $a0,prmpt11
            syscall         # print "Output: The longest palindrome is "

            lb $t1,0($t0)       # load first char of the string
            jal isLetter        # check if it is a letter
            add $t2,$t1,$zero   # load same char for comparison



notFinal:   beq $t1,$zero,beforefinal   # if end of the string
            bne $t1,$t2,next      # if two char do not match
            
            addi $s1,$s1,1        # if two char match count +1
            bne $s1,$s2,continue  # if count != 2

            add $a0,$t1,$zero
            li $v0,11
            syscall               # count==2 print char

            addi $s0,$s0,1        # palindrome length+1
            addi $sp,$sp,-1       
            sb $t1,0($sp)         # store char

            add $s1,$zero,$zero   # reset count
            addi $t0,$t0,1        # go to next char address
            lb $t1,0($t0)         # load next char
            jal isLetter          # check if it is a letter
            j notFinal

continue:   addi $t0,$t0,1      # go to next char address
            lb $t1,0($t0)       # load next char
            jal isLetter        # check if it is a letter
            j notFinal

next:       
            add $t2,$t1,$zero    # replace the second character with the last loaded one 
            add $s1,$zero,1      # count to 1
            addi $t0,$t0,1       # go to next char address
            lb $t1,0($t0)        # load next char
            jal isLetter         # check if it is a letter
            j notFinal

printSecond:
            lb $t1,0($sp)        # load char from stack
            addi $sp,$sp,1
            add $a0,$t1,$zero
            li $v0,11
            syscall              # print char
            addi $t3,$t3,-1      # number of chars in the stack - 1
            j final

beforefinal:      
            add $t3,$s0,$zero   # $t3 = palindrome half length = number of chars in the stack
final:
            bne $t3,$zero,printSecond   # if $t3 != 0 print second half of palindrome
            li $v0,4
            la $a0,prmpt12
            syscall                     # print ", and its length is "       

            sll $s0,$s0,1               # palindrome length*2
            add $a0,$s0,$zero
            li $v0,1
            syscall                     # print palindrome length

            li $v0,4
            la $a0,prmpt10
            syscall                     # print ".\n"

            lw $a0,0($sp)               # load $a0
            addi $sp,$sp,4
            lw $ra,0($sp)               # load $ra
            addi $sp,$sp,4
            jr $ra

isLetter:   
            beq $t1,$zero,beforefinal     # if end of the string
            slt $t3,$t1,$s4         
            slt $t4,$s3,$t1
            and $t5,$t3,$t4       # if char between a and z

            slt $t3,$t1,$s6
            slt $t4,$s5,$t1
            and $t6,$t3,$t4       # if char between A and Z

            bne $t5,$zero,ifLowercase # if char is a lowercase letter
            bne $t6,$zero,convert       # if char is an uppercase letter

            addi $t0,$t0,1     # char is not letter go to next char   
            lb $t1,0($t0)
            j isLetter

ifLowercase:   jr $ra

convert:    addi $t1,$t1,32    # convert uppercase to lowercase
            jr $ra

#$a0 -> input string
reverseVowels:
            addi $sp,$sp,-4 # store $ra and $a0
            sw $ra,0($sp)
            addi $sp,$sp,-4
            sw $a0,0($sp)
            add $t0,$a0,$zero # $t0 address of input
            addi $s0,$zero,0 # j => for the end of the input
            li $s1,65 # uppercase A
            li $s2,69 # uppercase E
            li $s3,73 # uppercase I
            li $s4,79 # uppercase O
            li $s5,85 # uppercase U
            li $s6,0 # true or false => if it is vowel

            lb $t1,0($t0) # load first char of the input

gotoInputEnd:    
            beq $t1,$zero,beforeLoop # If end of the input string
            addi $s0,$s0,1  # increment j
            addi $t0,$t0,1  # go to next char address
            lbu $t1,0($t0)  # load char
            j gotoInputEnd

beforeLoop:       
            add $t0,$a0,$zero # $t0 address of input start
            addi $s0,$s0,-1
            add $t2,$t0,$s0 # $t2 address of input end

L1:
            lb $t1,0($t0) # load char
            add $a0,$zero,$t1 # arg for isVowel
            jal isVowel # check if it is a vowel
            bne $s6,$zero,L2 # if it is a vowel search for other vowel
            addi $t0,$t0,1 # go to next char address
            j L1

L2:      
            lb $t3,0($t2) # load char
            add $a0,$zero,$t3 # arg for isVowel
            jal isVowel # check if it is a vowel
            bne $s6,$zero,swapChar # if it is a vowel swap chars
            addi $t2,$t2,-1 # go to next char address
            j L2

swapChar:
            bge $t0,$t2,Last
            sb $t1,0($t2) # swap char in L1
            sb $t3,0($t0) # with char in L2
            addi $t0,$t0,1 # next address for L1
            addi $t2,$t2,-1 # next address for L2
            j L1

isVowel:  
            beq $a0,$s1,ifTrue # if argument char is A
            beq $a0,$s2,ifTrue # if argument char is E
            beq $a0,$s3,ifTrue # if argument char is I
            beq $a0,$s4,ifTrue # if argument char is O
            beq $a0,$s5,ifTrue # if argument char is U

            addi $t4,$s1,32 # if argument char is a
            beq $a0,$t4,ifTrue
            addi $t4,$s2,32 # if argument char is e
            beq $a0,$t4,ifTrue
            addi $t4,$s3,32 # if argument char is i
            beq $a0,$t4,ifTrue
            addi $t4,$s4,32 # if argument char is o
            beq $a0,$t4,ifTrue
            addi $t4,$s5,32 # if argument char is u
            beq $a0,$t4,ifTrue

            addi $s6,$zero,0 # if char is not a vowel => $s5 = 0
            jr $ra

ifTrue:
            addi $s6,$zero,1 # if char is a vowel => $s5 = 1
            jr $ra

Last:      
            li $v0,4
            la $a0,prmpt17
            syscall         # print "Output: "

            lw $a0,0($sp) # load $a0
            addi $sp,$sp,4
            li $v0, 4
            syscall     # print output

            lw $ra,0($sp) # load $ra
            addi $sp,$sp,4
            jr $ra

#$a0 -> input integer
findDPrime:
            li $t0, 2 # set i = 2 for loopForSquareFree
            add $a1,$a0,0 # copy the content of input to the $a1 for later use.
loopForSquareFree:
            mult $t0,$t0 # calculates i*i
            addi $t0,$t0,1 # incerement i by one for loop 
            mflo $s1 # saves the result of i*i in $s1
            blt $a0,$s1,trueLabel # if i * i <= num  jump to the TrueLabel. It means that the number is'square-free'
            div $a0,$s1 # calculates num / (i * i)
            mfhi $t2 # remainder of division kept in $t2
            beq $t2,$zero, falseLabel # if remainder in $t2 == 0 it means that i * i divides the number. So number is not 'square-free'.Jump to falseLabel; 
            j loopForSquareFree  # continue loop
falseLabel:
            li $v0, 1  # print the input value
            syscall
            li $v0, 4    
            la $a0, prmpt15  # print to not square free message
            syscall
            jr $ra
trueLabel:
            li $v0, 1
            syscall
            li $v0, 4   
            la $a0, prmpt14  # print the input value
            syscall
            move $t0,$a1
findEachPrime:
            li $t1,2           # set i = 2
loopForPrimes:
            ble $t1, $t0, innerProcess   # loop condition for checking primes
            j exitFromLoopPrime
innerProcess:
            div $t0, $t1 # $t0 = num / i 
            mfhi $t2 # remainder in $t2
            bne $t2, $zero, nextProcess # if remainder in $t2 not zero jump nextProcess
            li $v0, 1    
            move $a0, $t1 # print the i value which is prime factor
            syscall
            li $v0,4
            la $a0, prmpt13 # print space btwn numbers
            syscall  
            div $t0, $t1
            mflo $t0 # num = num / i 
keepDividingSameFactorLoop:
            div $t0, $t1 # t0 / i 
            mfhi $t2 # remainder in $t2
            bne $t2, $zero, nextProcess #if remainder in $t2 not zero jump nextProcess
            div $t0, $t1 
            mflo $t0 # num = num / i
            j keepDividingSameFactorLoop
nextProcess:
            addi $t3, $zero,1 # t3 = 1
            add $t1, $t1, $t3 # i = i + 1 for iteration
            j loopForPrimes
exitFromLoopPrime:
            li $v0,4
            la $a0, prmpt16 # print space chracter
            syscall   
            jr $ra

#$a0 -> input string $a1 -> number of rows $a2 -> number of columns
luckyNumber:
            addi $sp,$sp,-16 # Reserve 16 byte area to save return adress and s registers
            sw $ra,0($sp)
            sw $a0,4($sp)
            sw $s0,8($sp)
            sw $s1,12($sp)
            jal parseString # Call parseString to parse input string to integer matrix array 
            move $a0,$v0 # $a0 holds starting address of matrix
            move $s1,$a1 # $s1 is set to be number of rows
            mult $a1,$a2 
            mflo $a1 # $a1 holds number of elements in matrix
            jal checkUniqeness # Call checkUniqeness to see if matrix contains unique elements, $v0 -> 0 when unique 1 otherwise
            move $s0,$a0 # $s0 holds starting of matrix 
            beq $v0,$zero,unique # If matrix is unique branch to unique label
            li $v0,4
            la $a0,prmpt8 
            syscall # Print matrix should contain unique elements 
            j exit # Jump to exit label to exit from this procedure
unique:     li $v0,9
            sll $a0,$s1,2
            syscall # Allocate integer array of length equal to number of rows in matrix
            move $t2,$v0
            li $v0,9
            sll $a0,$a2,2
            syscall # Allocate integer array of length equal to number of columns in matrix
            move $t3,$v0
            move $t0,$zero
        # $s0 -> numbers array $s1 -> number of rows $a2 -> number of columns 
        # $t2 -> row smallests array $t3 -> column greatests array
        # loop4 is a start of for loop which searches for smallest element in each row and save them in the allocated array for smallest in rows
loop4:      bge $t0,$s1,end4
            mult $a2,$t0
            mflo $t4
            sll $t4,$t4,2
            add $t4,$t4,$s0
            lw $t4,0($t4)
            li $t1,0
loop5:      bge $t1,$a2,end5 
            mflo $t5
            add $t5,$t5,$t1
            sll $t5,$t5,2
            add $t5,$t5,$s0
            lw $t5,0($t5)
            bge $t5,$t4,endif
            move $t4,$t5
endif:      addi $t1,$t1,1
            j loop5
end5:       sll $t6,$t0,2
            add $t6,$t6,$t2
            sw $t4,0($t6)
            addi $t0,$t0,1
            j loop4
end4:       move $t0,$zero
        # loop6 is a start of for loop which searches biggest element in each column and save them in the allocated array for biggest in columns
loop6:      bge $t0,$a2,end7
            sll $t4,$t0,2
            add $t4,$t4,$s0
            lw $t4,0($t4)
            move $t1,$zero
loop7:      bge $t1,$s1,end6
            mult $t1,$a2
            mflo $t5
            add $t5,$t5,$t0
            sll $t5,$t5,2
            add $t5,$t5,$s0
            lw $t5,0($t5)
            blt $t5,$t4,endif2
            move $t4,$t5
endif2:     addi $t1,$t1,1
            j loop7
end6:       sll $t6,$t0,2
            add $t6,$t6,$t3
            sw $t4,0($t6)
            addi $t0,$t0,1
            j loop6
end7:       move $t0,$zero
        # loop8 is a start of for loop which compares elements of rowSmallests array and columnBiggests array and finds the common element that is lucky number
loop8:      bge $t0,$s1,exit
            move $t1,$zero
loop9:      bge $t1,$a2,end9
            sll $t4,$t0,2
            add $t4,$t4,$t2
            lw $t4,0($t4)
            sll $t5,$t1,2
            add $t5,$t5,$t3
            lw $t5,0($t5)
            bne $t4,$t5,cont2 # If compared indexes doesn't contain same value jump to cont2 label
            li $v0,4
            la $a0,prmpt9
            syscall # Print 'The lucky number is: '
            li $v0,1
            move $a0,$t5
            syscall # Print the lucky number found
            li $v0,4
            la $a0,prmpt10 
            syscall # Print new line
            j exit
cont2:      addi $t1,$t1,1
            j loop9
end9:       addi $t0,$t0,1
            j loop8
exit:       move $a1,$s0 # Restore $a1
            lw $ra,0($sp) # Restore $ra return address
            lw $a0,4($sp) # Restore $a0
            lw $s0,8($sp) # Restore $s0
            lw $s1,12($sp) # Restore $s1
            addi $sp,$sp,16 # Deallocate area from stack
            jr $ra # Return to main function

# $a0 -> input string $a1 -> number of rows $a2 -> number of columns
# This procedure parses input string and constructs integer array and returns it
parseString:
            addi $sp,$sp,-12 # Decrement stack pointer to save current values of s registers
            sw $s0,0($sp)
            sw $a1,4($sp)
            sw $a2,8($sp)
            move $s0,$a0 # Save $a0 before syscall
            mult $a1,$a2
            mflo $t0 # Length of integer array is put in $t0
            sll $t3,$t0,2 # Size of integer array is put in $t3 = $t0 * 4 
            li $v0,9 
            move $a0,$t3 # Size of integer array we require moved to $a0 before syscall
            syscall #v0 starting address of integer array
            move $t3,$s0 # $t3 points to index of input string that isn't processed yet
            li $t2,1 # Initialize iteration variable
loop:       slt $t1,$t0,$t2 
            bne $t1,$zero,end # Jump out of loop if $t0 (length of integer array) < $t2 (iteration variable)
            move $t4,$zero # Current number is initialized to 0
while2:     li $t5,32 # $t5 is set to value of ' ' in ascii
            lbu $t6,0($t3) # The character pointed by $t3 is fetched $t6 register
            beq $t5,$t6,endwhile2 # If current character is ' ' than jump out of inner while loop
            move $t5,$zero # $t5 is set to value of null character in asciii
            beq $t5,$t6,endwhile2 # If current character is null character than jump out of inner while loop
            li $t5,48 # $t5 is set to value of 0 in ascii
            blt $t6,$t5,endif3 # If current character has lower value in ascii jump to endif3 label
            li $t5,57 # $t5 is set to value of 9 in ascii
            bgt $t6,$t5,endif3 # If current character has higher value in ascii jump to endif3 label
            li $t5,10 
            mult $t5,$t4 # To add digit to current number multiply it by 10
            mflo $t4
            addi $t6,$t6,-48 # Subtract 48 to convert from char to int
            add $t4,$t4,$t6 # Add current digit to current number
endif3:    addi $t3,$t3,1 # Add 1 to $t3 to point next character in the input string
            j while2 # Jump to start of while loop
endwhile2:  addi $t3,$t3,1 # After while loop the current number is calculated and it will be put to it's position in the integer array
            sll $t5,$t0,2
            sub $t5,$a0,$t5
            add $t6,$v0,$t5
            sw $t4, 0($t6)  
            addi $t0,$t0,-1
            j loop # Go to start of for loop to scan next number
end:        move $a0,$s0 # Restore $a0 register
            lw $s0,0($sp) # Restore s registers
            lw $a1,4($sp)
            lw $a2,8($sp)
            addi $sp,$sp,12 
            jr $ra # Return $v0 which points to start adress of integer array created

# $a0 -> starting address of integer array
# $a1 -> length of array
#returns 0 if array is unique 1 otherwise
checkUniqeness:
            move $t0,$zero # Initialize iteration variable $t0 to 0
loop2:      bge $t0,$a1,end2 # If $t0 is greater than or equal to length of array terminate loop
            move $t1,$zero # Initialiaze iteration variable for inner loop $t1 to 0
loop3:      bge $t1,$a1,inc # If $t1 is greater than or equal to length of array jump out of inner loop
            beq $t0,$t1,inc # $t0 and $t1 shouldn't be same index if they are same jump out of inner loop
            sll $t4,$t0,2
            add $t2,$a0,$t4
            lw $t2,0($t2) # Load the value at index $t0 to $t2 register
            sll $t4,$t1,2 
            add $t3,$a0,$t4 
            lw $t3,0($t3) # Load the value at index $t1 to $t3 register
            bne $t3,$t2,cont # If the values aren't equal go cont label
            li $v0,1 
            jr $ra # Return 1 since array doesn't contain unique values
cont:       addi $t1,$t1,1 # Increment $t1 by 1 and jump to start of inner loop
            j loop3
inc:        addi $t0,$t0,1 # Increment $t0 by 1 and jump to start of outer loop
            j loop2
end2:       li $v0,0 
            jr $ra # Return 0 since array contains unique elements

            