/*
Name Surname: Serkan Korkut
Student ID: 150119036
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define SIZE 100
// Structure of numberNode 
struct numberNode {
	char digit;		// each numberNode contains a digit character
	struct numberNode *nextPtr;		// pointer to next node
};

typedef struct numberNode numberNode;	// synonym for struct numberNode
typedef numberNode * numberNodePtr;		// synonym for numberNode*


// prototypes
void getMultiplicandMultiplier(numberNodePtr *mltplcndPtr, numberNodePtr *mltplrPtr);
int numberOfDigits(numberNodePtr numberPtr);
int char2Int(char ch);
numberNodePtr getResult(numberNodePtr mltplcndPtr, numberNodePtr mltplrPtr);
void node2String(char* string, numberNodePtr numberPtr);
void writeOutput(numberNodePtr mltplcndPtr, numberNodePtr mltplrPtr, numberNodePtr resultPtr);


int main(void)
{
	numberNodePtr mltplcndPtr = NULL;	// points to first node of multiplicand
	numberNodePtr mltplrPtr = NULL;		// points to first node of multiplier
	
	// Get first node of multiplicand and multiplier lists
	getMultiplicandMultiplier(&mltplcndPtr, &mltplrPtr);
	// Get first node of result list
	numberNodePtr resultPtr = getResult(mltplcndPtr, mltplrPtr);
	// Create output.txt file that contains multiplicand, multiplier and result
	writeOutput(mltplcndPtr, mltplrPtr, resultPtr);
}

// Get the multiplicand and multiplier from the input file
void getMultiplicandMultiplier(numberNodePtr *mltplcndPtr, numberNodePtr *mltplrPtr)
{
	FILE *inputPtr;			// outputPtr = output.txt file pointer	
	// // fopen opens file; exits program if file cannot be opened 
	if ((inputPtr = fopen("input.txt", "r")) == NULL) {
		puts("File could not be opened");
		exit(0);
	}
   else {
   		// Create char arrays
   		char multiplicand[SIZE];
   		char multiplier[SIZE];
   		// While not end of file
   		while (!feof(inputPtr)) { 
   			// Read multiplicand and multiplier strings from input file
        	fscanf(inputPtr, "%s%s", multiplicand, multiplier);
        	
        	/*		For MULTIPLICAND		*/
        	// Create first numberNode for MULTIPLICAND
        	numberNodePtr newM1Ptr = malloc(sizeof(numberNode));
        	// Assign last digit of multiplicand to first numberNode
         	newM1Ptr->digit = multiplicand[strlen(multiplicand) - 1];
         	newM1Ptr->nextPtr = NULL;	// Make sure new node points to NULL
         	
         	(*mltplcndPtr) = newM1Ptr;
         	numberNodePtr currentPtr = (*mltplcndPtr);
        	// Add all digits to the list starting from the second last digit to the first digit
        	int i;
        	for (i = strlen(multiplicand) - 2; i >= 0; i--) {
         		numberNodePtr newPtr = malloc(sizeof(numberNode));
         		if (newPtr != NULL) {
	         		newPtr->digit = multiplicand[i];
	         		newPtr->nextPtr = NULL;
	         		// Link current node with new node
	         		currentPtr->nextPtr = newPtr;
	         		currentPtr = newPtr;
	         	}
		 	}
		 	/*		For MULTIPLIER		*/
		 	// Create first numberNode for MULTIPLIER
		 	numberNodePtr newM2Ptr = malloc(sizeof(numberNode));
		 	// Assign last digit of multiplier to first numberNode
         	newM2Ptr->digit = multiplier[strlen(multiplier) - 1];
         	newM2Ptr->nextPtr = NULL;
         	
         	(*mltplrPtr) = newM2Ptr;
         	currentPtr = (*mltplrPtr);
		 	
		 	// Add all digits to the list starting from the second last digit to the first digit
		 	int j;
        	for (j = strlen(multiplier) - 2; j >= 0; j--) {
         		numberNodePtr newPtr = malloc(sizeof(numberNode));
         		if (newPtr != NULL) {
	         		newPtr->digit = multiplier[j];
	         		newPtr->nextPtr = NULL;
	         		// Link current node with new node
	         		currentPtr->nextPtr = newPtr;
	         		currentPtr = newPtr;
	         	}
		 	}
		}
	}
	// fclose closes the file 
	fclose(inputPtr);	
}

// Find out how many digits the number in the list has
int numberOfDigits(numberNodePtr numberPtr)
{
	int number = 0;
	while (numberPtr != NULL) {
		number++;							// Increment number if current numberNode is not empty
		numberPtr = numberPtr->nextPtr;		// Go to next numberNode
	}
	return number;
}

// Convert character to digit
int char2Int(char ch)
{
	int i = ch - '0';
	return i;
}

// Calculate result and return first node of result list
numberNodePtr getResult(numberNodePtr mltplcndPtr, numberNodePtr mltplrPtr)
{
	numberNodePtr multiplicandPtr = mltplcndPtr;

	numberNodePtr resultPtr = NULL;
	numberNodePtr currentPtr = NULL;
	numberNodePtr previousPtr = NULL;
	
	int m1 = numberOfDigits(mltplcndPtr);		// number of digits of the multiplicand
	int m2 = numberOfDigits(mltplrPtr);			// number of digits of the multiplier
	int i = 0;
	while (mltplrPtr != NULL) {
		int multiplier = char2Int(mltplrPtr->digit);	// get the digit of the multiplier
		mltplrPtr = mltplrPtr->nextPtr;					// Move to next node

		int remaining = 0;		// save the remaining for the next multiplication
		int product = 0;		// the result of the multiplied digits
		int upperNumber = 0;	// the old number in the current node	
		while (multiplicandPtr != NULL) {
			int multiplicand = char2Int(multiplicandPtr->digit);	// get the digit of the multiplicand
			multiplicandPtr = multiplicandPtr->nextPtr;		// Move to next node
			
			// If it is the first stage of multiplication 
			if (i == 0) {
				numberNodePtr newPtr = malloc(sizeof(numberNode));
				product = multiplicand * multiplier;
         		newPtr->digit = (product % 10) + '0';
         		remaining = product / 10;
         		newPtr->nextPtr = NULL;
         		// Link result nodes with new node
         		resultPtr = newPtr;
				currentPtr = resultPtr;
				previousPtr = resultPtr;
			}
			// If it is in the first row of multiplication
			else if (i < m1) {
				numberNodePtr newPtr = malloc(sizeof(numberNode));
				product = multiplicand * multiplier + remaining;
				newPtr->digit = (product % 10) + '0';
				remaining = product / 10;
				// Link current node with new node
				currentPtr->nextPtr = newPtr;
				currentPtr = newPtr;
		        newPtr->nextPtr = NULL;
		        
		        // If it is the end of the first row of multiplication and the remaining is different from 0 
		        if ((i+1) == m1 && remaining != 0) {
		        	numberNodePtr new2Ptr = malloc(sizeof(numberNode));
			        new2Ptr->digit = remaining + '0';
			        remaining = 0;
			        // Link current node with new node
			        currentPtr->nextPtr = new2Ptr;
			        currentPtr = new2Ptr;
			        new2Ptr->nextPtr = NULL;
				}
			}
			else {
				// If it's the last multiplication in any row below
				if ((i+1) % m1 == 0) {
					// If next numberNode is not empty
					if (currentPtr->nextPtr != NULL) {
						currentPtr = currentPtr->nextPtr;
						upperNumber = char2Int(currentPtr->digit);
						product = multiplicand * multiplier + remaining + upperNumber;
						remaining = product / 10;
						currentPtr->digit = (product % 10) + '0';
						currentPtr->nextPtr = NULL;
						// If the remaining is different from 0
						if (remaining != 0) {
							numberNodePtr new2Ptr = malloc(sizeof(numberNode));
							new2Ptr->digit = (remaining) + '0';
							new2Ptr->nextPtr = NULL;
							// Link current node with new node
							currentPtr->nextPtr = new2Ptr;
							currentPtr = new2Ptr;
						}
					}
					// If next numberNode is empty
					else {
						numberNodePtr newPtr = malloc(sizeof(numberNode));
						product = multiplicand * multiplier + remaining;
						remaining = product / 10;
						newPtr->digit = (product % 10) + '0';
						newPtr->nextPtr = NULL;
						// Link current node with new node
						currentPtr->nextPtr = newPtr;
						currentPtr = newPtr;
						// If the remaining is different from 0
						if (remaining != 0) {
							numberNodePtr new2Ptr = malloc(sizeof(numberNode));
							new2Ptr->digit = (remaining) + '0';
							new2Ptr->nextPtr = NULL;
							// Link current node with new node
							currentPtr->nextPtr = new2Ptr;
							currentPtr = new2Ptr;
						}
					}	
				}
				// If it is a multiplication that is not the last in any row below
				else if (currentPtr->nextPtr != NULL) {
					currentPtr = currentPtr->nextPtr;
					upperNumber = char2Int(currentPtr->digit);
					product = multiplicand * multiplier + remaining + upperNumber;
					remaining = product / 10;
					currentPtr->digit = (product % 10) + '0';
				}
			}
			// Increment i at the end of each multiplication
			i++;
		}
		// Point multiplicand node to the first node of the multiplicand list
		multiplicandPtr = mltplcndPtr;
		// Point current node to previous node
		currentPtr = previousPtr;
		// Move previous node to next node
		previousPtr = previousPtr->nextPtr;	
	}	
	return resultPtr;
}

// Convert linked list to a string
void node2String(char* string, numberNodePtr numberPtr)
{
	int size = numberOfDigits(numberPtr);		// size of the list
	int i;
	for (i = 0; i < size; i++) {
		char digit = numberPtr->digit;		// Get the digit from numberNode
		string[i] = digit;					// Insert the digit in string
		numberPtr = numberPtr->nextPtr;		// Go to next numberNode
	}
	string[i] = '\0';			// Insert the null character at the end of the string
	string = strrev(string);	// Reverse the string
}

// Write multiplicand, multiplier and result into output file
void writeOutput(numberNodePtr mltplcndPtr, numberNodePtr mltplrPtr, numberNodePtr resultPtr)
{
	FILE *outputPtr;		// outputPtr = output.txt file pointer 
	// fopen opens file. Exit program if unable to create file 
   	if ((outputPtr = fopen("output.txt", "w")) == NULL) {
      	puts("File could not be opened");
      	exit(1);
   	} 
   	else {
   		// Create char arrays
   		char multiplicand[SIZE];
   		char multiplier[SIZE];
   		char result[SIZE];
   		// Convert multiplicand, multiplier and result linked lists to strings
   		node2String(multiplicand, mltplcndPtr);
   		node2String(multiplier, mltplrPtr);
   		node2String(result, resultPtr);
   		// Write multiplicand, multiplier and result into output file with fprintf
   		fprintf(outputPtr, "%s\n%s\n%s", multiplicand, multiplier, result);
   		// fclose closes file  
    	fclose(outputPtr);  
   }
}

