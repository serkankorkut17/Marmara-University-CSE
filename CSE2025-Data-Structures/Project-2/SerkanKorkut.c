/*
Name Surname: Serkan Korkut
Student ID: 150119036
*/
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#define SIZE 100
// Structure of BTNode 
struct BTNodeType {
	int data;					// each BTNode contains an integer
	struct BTNodeType *left;	// pointer to left node
	struct BTNodeType *right;	// pointer to right node
};
typedef struct BTNodeType BTNodeType;	// synonym for struct BTNodeType
typedef BTNodeType * BTNodeTypePtr;		// synonym for BTNodeType*

// prototypes
BTNodeTypePtr createBTNode();
void arrayOrder(int *array, int size, int *ordered);
BTNodeTypePtr insert(int key, BTNodeType *p);
int find(BTNodeType *p, int key);
int findDepth(BTNodeType *p, int key);
void findNumbersInDepthN(BTNodeType *p, int depth, int currentDepth, int *numbers);
int findRank(BTNodeType *p, int key);
int numberOfKeysInDepthN(BTNodeType *p, int depth);
int findTotalDepth(BTNodeType *p);
int arraySearch(int *array, int key);
void splitArray(int *array, int n, int *a, int *b);
void arraySort(int *array, int size);

// For findNumbersInDepthN function
int n = 0;



int main(void)
{
	BTNodeTypePtr BTNode = NULL;	// points to first node of BTNode
	BTNode = createBTNode();
	
	// OUTPUT:
	printf("\nDepth level of BST is %d", findTotalDepth(BTNode));
	int i;
	for(i = 0; i < findTotalDepth(BTNode); i++)
	{
		printf("\nDepth level %d -> %d", i, numberOfKeysInDepthN(BTNode, i));
	}
	
	int key = 0;
	int depth = 0;
	int rank = 0;
	
	while(1)
	{
		printf("\nKey value to be searched (Enter 0 to exit) :");
		scanf("%d", &key);
		// Exit the loop if the key is 0
		if(key == 0)
		{
			printf("Exit");
			break;
		}
		// If key is not found in BTNode, it returns to the beginning of the loop
		if(find(BTNode, key) == 0)
		{
			printf("%d is not found in BST", key);
			continue;
		}// If key is found in BTNode, prints the key location
		else if(find(BTNode, key) == 1)
		{
			depth = findDepth(BTNode, key);
			rank = findRank(BTNode, key);
			if (rank == 1)
				printf("At Depth level %d, %dst element", depth, rank);
			else if (rank == 2)
				printf("At Depth level %d, %dnd element", depth, rank);
			else if (rank == 3)
				printf("At Depth level %d, %drd element", depth, rank);
			else
				printf("At Depth level %d, %dth element", depth, rank);
		}
	}
}

// Creates BTNode
BTNodeTypePtr createBTNode()
{
	BTNodeTypePtr BTNode = NULL;
	FILE *inputPtr;					// inputPtr = input.txt file pointer
	int k = 0;
	int keys[SIZE] = {0};
	// fopen opens file; exits program if file cannot be opened 
	if ((inputPtr = fopen("input.txt", "r")) == NULL) {
		puts("File could not be opened");
		exit(0);
	}
	else {
   		int data;
   		// While not end of file
   		while (!feof(inputPtr)) {
   			// // Read keys from input file
        	fscanf(inputPtr, "%d", &data);
        	// If the number is 0 or less than 0, exits program
        	if (data <= 0)
        	{
        		printf("The number cannot be zero or less than zero.");
        		exit(0);
			}
			// If the same number is in the array, exits program
			if (arraySearch(keys, data))
			{
			 	printf("The same number cannot be used more than once.");
			 	exit(0);
			}
        	// Puts the number in the array
        	keys[k] = data;
        	k++;
		}
	}
	fclose(inputPtr);	// fclose closes the file 
	// If the numbers in the array are less than 16, exits program
	if (k < 16)
	{
		printf("The numbers in the file must be at least 16.");
		exit(0);
	}
	// Sorts the array
	arraySort(keys, k);
	// Number of completely filled depth levels
	int fullDepth = floor(log(k)/log(2));	
	// Desired number of depth levels
	int realDepth = 3 * floor(log(k)/log(4));
	// Number of keys that must be kept apart to reach the desired number of depth levels
	int dif = realDepth - fullDepth;
	int first = k - dif;
	// Keys that should be inserted first into BTNode
	int partFull[first];
	// Keys that should be inserted last into BTNode
	int partExtra[dif];
	
	// Fill partFull array
	int i;
	for (i = 0; i < first; i++)
	{
		partFull[i] = keys[i];
	}
	// Fill partExtra array
	int j = 0;
	for(i = first; i < k; i++, j++)
	{
		partExtra[j] = keys[i];
	}
	// Copies partFull array into full array in a special order
	int full[SIZE] = {0};
	arrayOrder(partFull, first, full);
	// Inserts full array into BTNode
	i = 0;
	while(full[i] != 0)
	{
		BTNode = insert(full[i], BTNode);
		i++;
	}
	// Inserts partExtra array into BTNode
	for(i = 0; i < dif; i++)
	{
		BTNode = insert(partExtra[i], BTNode);
	}
	
	return BTNode;
}

// Puts the array in a special order so that the keys can be inserted into BTNode
void arrayOrder(int *array, int size, int *ordered)
{
	static int n = 0;
	if(size >= 3)
	{
		// First puts the number in the middle of array into ordered array
		int middle = size / 2;
		ordered[n] = array[middle];
		n++;
		// Then puts the numbers to the right and left of that number into separate arrays
		int firstPart[size/2];
		int secondPart[size-size/2-1];
		splitArray(array, size, firstPart, secondPart);
		// Finally it calls the function again for both arrays
		arrayOrder(firstPart, size/2, ordered);
		arrayOrder(secondPart, size-size/2-1, ordered);
	}
	else if(size < 3)
	{
		// If the length of the array is less than 3, it puts the numbers in the array into the ordered array in order
		int i;
		for(i = 0; i < size; i++)
		{
			ordered[n] = array[i];
			n++;
		}
	}
}

// Inserts the key into BTNode
BTNodeTypePtr insert(int key, BTNodeType *p)
{
	if (p == NULL)
	{
		p = malloc(sizeof(BTNodeType));
		if (p == NULL)
		{
			printf("Out of memory");
			exit(0);
		}
		// If BTNode is empty, creates root
		p->data = key;
		p->left = NULL;
		p->right = NULL;
		return p;
	}
	else if (key < p->data)
		p->left = insert(key, p->left);
	else if (key > p->data)
		p->right = insert(key, p->right);
	
	return p;
}

// Checks if the specified key is in BTNode
int find(BTNodeType *p, int key)
{
	int isTrue = 0;
	if (p != NULL)
	{
		if (key < p->data)
			isTrue = find(p->left, key);
		else if(key > p->data)
			isTrue = find(p->right, key);
		else if(p->data == key)
			isTrue = 1;
	}
	return isTrue;
}

// Finds the depth level of the specified key in BTNode
int findDepth(BTNodeType *p, int key)
{
	static int depth = 0;
	int d = 0;
	if (p != NULL)
	{
		if (key < p->data)
		{
			depth++;
			depth = findDepth(p->left, key);
		}
		else if(key > p->data)
		{
			depth++;
			depth = findDepth(p->right, key);
		}
		else if(p->data == key)
		{
		}
	}
	d = depth;
	depth = 0;
	
	return d;
}

// Finds all numbers at the specified depth level in BTNode and transfers these numbers to the array
void findNumbersInDepthN(BTNodeType *p, int depth, int currentDepth, int *numbers)
{
	if (p != NULL)
	{
		// If the desired depth level is not reached
		if (currentDepth < depth)
		{
			// Moves to the next depth level and calls the function again
			findNumbersInDepthN(p->left, depth, currentDepth+1, numbers);
			findNumbersInDepthN(p->right, depth, currentDepth+1, numbers);
		}
		else if(currentDepth == depth)	// If desired depth level is reached
		{
			// Puts the key in BTnode into the array
			numbers[n] = p->data;
			n++;
		}
	}
}

// Finds the rank of the key at its depth level in BTNode
int findRank(BTNodeType *p, int key)
{
	n = 0;
	// Finds the depth level where the key is located
	int depth = findDepth(p, key);
	int keys[SIZE] = {0};
	// Puts the numbers found at that depth into keys 
	findNumbersInDepthN(p, depth, 0, keys);
	
	// Finds the rank of the key in the array
	int i = 0;
	while(keys[i] != 0)
	{
		if(keys[i] == key)
		{
			break;
		}
		i++;
	}
	return ++i;
}

// Finds the total number of keys at a given depth level in BTNode
int numberOfKeysInDepthN(BTNodeType *p, int depth)
{
	n = 0;
	int keys[SIZE] = {0};
	// Puts the numbers found at that depth into keys
	findNumbersInDepthN(p, depth, 0, keys);
	
	// Finds how many keys are in this array
	int i = 0;
	while(keys[i] != 0)
	{
		i++;
	}
	return i;
}

// Finds the total number of depth levels in BTNode
int findTotalDepth(BTNodeType *p)
{
	int depth1 = 0;
	int depth2 = 0;
	int d = 0;
	if(p != NULL)
	{
		depth1 = findTotalDepth(p->left);
		depth2 = findTotalDepth(p->right);
		
		if (depth1 > depth2)
			d = depth1 + 1;
		else
			d = depth2 + 1;
	
		return d;
	}
	else if(p == NULL)
		return 0;
	
}

// Checks if the key is in the array 
int arraySearch(int *array, int key)
{
	int isTrue = 0;
	int i;
	for(i = 0; i < SIZE; i++)
	{
		if(array[i] == key)
		{
			isTrue = 1;
			break;
		}
	}
	return isTrue;
}

// Splits an array of length n by 2, excluding the middle element(array[n/2])
void splitArray(int *array, int n, int *a, int *b)
{
	// Puts the numbers to the left of the number in the middle of the array into array a
	int i;
	for(i = 0; i < n/2; i++)
		a[i] = array[i];
	// Puts the numbers to the right of the number in the middle of the array into array b	
	int j = 0;
	for(i = n/2+1; i < n; i++, j++)
		b[j] = array[i];
}

// Sorts the array from lowest to highest
void arraySort(int *array, int size)
{
	int i;
	int j;
	for(i = 0; i < (size-1); i++)
	{
		for(j = 0; j < (size-1-i); j++)
		{
			if(array[j+1] < array[j])
			{
				int temp = array[j+1];
				array[j+1] = array[j];
				array[j] = temp;
			}	
		}
	}
}

