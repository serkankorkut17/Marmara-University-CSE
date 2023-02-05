#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>
#include <signal.h>

#define MAX_LINE 80 /* 80 chars per line, per command, should be enough. */

/* The setup function below will not return any value, but it will just: read
in the next command line; separate it into distinct arguments (using blanks as
delimiters), and set the args array entries to point to the beginning of what
will become null-terminated, C-style strings. */

void setup(char inputBuffer[], char *args[], int *background)
{
	int length, /* # of characters in the command line */
		i,		/* loop index for accessing inputBuffer array */
		start,	/* index where beginning of next command parameter is */
		ct;		/* index of where to place the next parameter into args[] */

	ct = 0;

	/* read what the user enters on the command line */
	length = read(STDIN_FILENO, inputBuffer, MAX_LINE);
	/* 0 is the system predefined file descriptor for stdin (standard input),
	   which is the user's screen in this case. inputBuffer by itself is the
	   same as &inputBuffer[0], i.e. the starting address of where to store
	   the command that is read, and length holds the number of characters
	   read in. inputBuffer is not a null terminated C-string. */

	start = -1;
	if (length == 0)
	{
		exit(0); /* ^d was entered, end of user command stream */
	}
	/* the signal interrupted the read system call */
	/* if the process is in the read() system call, read returns -1
	  However, if this occurs, errno is set to EINTR. We can check this  value
	  and disregard the -1 value */
	if ((length < 0) && (errno != EINTR))
	{
		perror("error reading the command");
		exit(-1); /* terminate with error code of -1 */
	}

	for (i = 0; i < length; i++)
	{ /* examine every character in the inputBuffer */

		switch (inputBuffer[i])
		{
		case ' ':
		case '\t': /* argument separators */
			if (start != -1)
			{
				args[ct] = &inputBuffer[start]; /* set up pointer */
				ct++;
			}
			inputBuffer[i] = '\0'; /* add a null char; make a C string */
			start = -1;
			break;

		case '\n': /* should be the final char examined */
			if (start != -1)
			{
				args[ct] = &inputBuffer[start];
				ct++;
			}
			inputBuffer[i] = '\0';
			args[ct] = NULL; /* no more arguments to this command */
			break;

		default: /* some other character */
			if (start == -1)
				start = i;
			if (inputBuffer[i] == '&')
			{
				*background = 1;
				inputBuffer[i - 1] = '\0';
			}
		}			 /* end of switch */
	}				 /* end of for */
	args[ct] = NULL; /* just in case the input line was > 80 */

	// for (i = 0; i <= ct; i++)
	//	printf("args %d = %s\n",i,args[i]);
} /* end of setup routine */

// A structure to store background processes
typedef struct ProcessLL
{
	pid_t processId;		// store processId
	struct ProcessLL *next;		// pointer to next process node
	struct ProcessLL *previous;	// pointer to previous process node
} ProcessLL;

// A structure to store previous commands
typedef struct HistoryLL
{
	char *str;			// command name
	char inputBuffer[MAX_LINE];	// command input buffer
	int background;			// is command background or not
	char *args[MAX_LINE];		// command arguments
	struct HistoryLL *next;		// pointer to next command node
} HistoryLL;

char *getCommandPath(char *command);
pid_t createChildProcess(char *path, char **args, int background);
void arrayToString(char **arr, char *str);

static void stopSignalHandler(int signo)
{
	printf("\nmyshell: ");
	fflush(stdout);
}

int main(void)
{
	signal(SIGTSTP, stopSignalHandler);
	char inputBuffer[MAX_LINE];	  /*buffer to hold command entered */
	int background;				  /* equals 1 if a command is followed by '&' */
	char *args[MAX_LINE / 2 + 1]; /*command line arguments */
	ProcessLL *bgProcessesHead = (ProcessLL *)malloc(sizeof(ProcessLL));
	bgProcessesHead->previous = NULL;
	bgProcessesHead->next = NULL;
	ProcessLL *bgProcessesTail = bgProcessesHead;

	// Initially there are no nodes
	HistoryLL *historyLLHead = NULL;

	while (1)
	{
		background = 0;
		printf("myshell: ");
		fflush(stdout);
		/*setup() calls exit() when Control-D is entered */
		setup(inputBuffer, args, &background);
		/** the steps are:
		(1) fork a child process using fork()
		(2) the child process will invoke execv()
		(3) if background == 0, the parent will wait,
		otherwise it will invoke the setup() function again. */
		
		// Copy the giving command into "line" string
		char *line = (char *)malloc(MAX_LINE * sizeof(char));
		arrayToString(args, line);
		int i;
	
		// Checks if the command is "history"
		if (!strcmp(line, "history"))
		{
			HistoryLL *ptr = historyLLHead;
			i = 0;
			// Prints last 10 commands line by line
			while (ptr != NULL)
			{
				printf("%d %s\n", i, ptr->str);
				ptr = ptr->next;
				if (i == 9)
					break;
				i++;
			}
			continue;
		}
		// Checks if the command is "history -i num"
		else if(!strcmp(args[0],"history") && !strcmp(args[1],"-i") && args[2] != NULL)
		{
			// Converts "num" argument to an int
			int commandNo = atoi(args[2]);
                        // Checks if "num" is between 0 and 9
                        if(commandNo < 0 || commandNo > 9){
                        	fputs("Number should be between 0 and 9.\n",stderr);
                        	continue;
                        }
                        	
                        // Command "num" is accessed from history list
			HistoryLL *ptr = historyLLHead;
			i = 0;
			while (ptr != NULL)
			{
				if (i == commandNo)
					break;
				ptr = ptr->next;
				i++;
			}
			// Copies history node members to "inputBuffer", "background" and "args"
			strcpy(inputBuffer, ptr->inputBuffer);	// Copy history to inputBuffer
			background = ptr->background;		// Copy history to background

			for (i = 0; i < sizeof(ptr->args); i++)
			{
				if ((ptr->args)[i] == NULL)
					break;
				// Copy history to arguments
				char *temp = malloc((MAX_LINE) * sizeof(char));
				strcpy(temp, (ptr->args)[i]);
				args[i] = temp;
			}
			args[i] = NULL;
		}
		else if (!strcmp(inputBuffer, "fg"))
		{
			pid_t pid = (pid_t)atoi(args[1]);
			int isPidFound = 0;
			ProcessLL *bgProcess = bgProcessesHead;
			while (bgProcess->next != NULL)
			{
				if (bgProcess->processId == pid)
				{
					isPidFound = 1;
					if (bgProcess->previous == NULL)
					{
						bgProcessesHead = bgProcess->next;
						bgProcessesHead->previous = NULL;
					}
					else
					{
						bgProcess->previous->next = bgProcess->next;
					}
					free(bgProcess);
					break;
				}
				bgProcess = bgProcess->next;
			}
			if (!isPidFound)
			{
				printf("No background processes found with the given process id %s\n", args[1]);
				continue;
			}
			tcsetpgrp(STDIN_FILENO, getpgid(pid));
			int status;
			waitpid(pid, &status, WUNTRACED);
			if (WIFSTOPPED(status))
			{
				printf("\n");
				killpg(getpgid(pid), SIGKILL);
				waitpid(pid, NULL, 0);
			}
			tcsetpgrp(STDIN_FILENO, getpgid(getpid()));
			continue;
		}
		else if (!strcmp(inputBuffer, "exit"))
		{
			if (bgProcessesHead->next == NULL)
				return 0;
			printf("There are background processes running.\nBackground processes must be terminated before exiting!\n");
			continue;
		}

		if (args[0] != NULL)
		{
			// Create a new history node
			HistoryLL *historyLL = (HistoryLL *)malloc(sizeof(HistoryLL));
			// Create a command string from arguments
			char *strLL = (char *)malloc(MAX_LINE * sizeof(char));
			arrayToString(args, strLL);
			historyLL->str = strLL;
			// Copy command inputBuffer to history node
			strcpy(historyLL->inputBuffer, inputBuffer);

			for (i = 0; i < sizeof(args); i++)
			{
				if (args[i] == NULL)
					break;
				// Copy command arguments to history node
				char *temp = malloc((MAX_LINE) * sizeof(char));
				strcpy(temp, args[i]);
				(historyLL->args)[i] = temp;
			}
			(historyLL->args)[i] = NULL;
			// Copy command background to history node
			historyLL->background = background;
			// Insert a new node into the beginning of history list
			historyLL->next = historyLLHead;
			historyLLHead = historyLL;
			
			char *commandPath = getCommandPath(inputBuffer);
			pid_t childProcess = createChildProcess(commandPath, args, background);
			if (!background)
			{
				int status;
				waitpid(childProcess, &status, WUNTRACED);
				if (WIFSTOPPED(status))
				{
					printf("\n");
					killpg(getpgid(childProcess), SIGKILL);
					waitpid(childProcess, NULL, 0);
				}
				tcsetpgrp(STDIN_FILENO, getpgid(getpid()));
			}
			else
			{
				bgProcessesTail->processId = childProcess;
				bgProcessesTail->next = (ProcessLL *)malloc(sizeof(ProcessLL));
				bgProcessesTail->next->previous = bgProcessesTail;
				bgProcessesTail = bgProcessesTail->next;
				bgProcessesTail->next = NULL;
			}
		}
	}
}

char *getCommandPath(char *command)
{
	char *dup = strdup(getenv("PATH"));
	char *s = dup;
	char *p = NULL;
	do
	{
		p = strchr(s, ':');
		if (p != NULL)
		{
			p[0] = 0;
		}
		char *fullPath = (char *)malloc(2 + strlen(s) + strlen(command));
		strcpy(fullPath, s);
		strcat(fullPath, "/");
		strcat(fullPath, command);
		if (access(fullPath, F_OK) == 0)
		{
			free(dup);
			return fullPath;
		}
		s = p + 1;
	} while (p != NULL);
	free(dup);
	return NULL;
}


/*
This function analyzes the arguments and determines the stdin, 
stdout and stderr file of the child process then forks the child assign it is file descriptors and 
also put the child into a new process group and gives the control
of the terminal to the child if child isn’t a background process.
*/

pid_t createChildProcess(char *path, char **args, int background)
{
	signal(SIGTTOU, SIG_IGN);
	char *stdoutFile, *stdinFile, *stderrFile;
	stdoutFile = stdinFile = stderrFile = NULL;
	char stdoutFileMode, stderrFileMode;
	stdoutFileMode = stderrFileMode = 'a';
	int i = 0;
	while (args[i] != NULL)
	{
		if (!strcmp(args[i], ">") || !(strcmp(args[i], ">>")))
		{
			if (!strcmp(args[i], ">"))
				stdoutFileMode = 'w';
			args[i] = NULL;
			i++;
			stdoutFile = (char *)malloc(1 + strlen(args[i]));
			strcpy(stdoutFile, args[i]);
			continue;
		}
		if (!strcmp(args[i], "2>") || !(strcmp(args[i], "2>>")))
		{
			if (!strcmp(args[i], "2>"))
				stderrFileMode = 'w';
			args[i] = NULL;
			i++;
			stderrFile = (char *)malloc(1 + strlen(args[i]));
			strcpy(stderrFile, args[i]);
			continue;
		}
		if (!strcmp(args[i], "<"))
		{
			args[i] = NULL;
			i++;
			stdinFile = (char *)malloc(1 + strlen(args[i]));
			strcpy(stdinFile, args[i]);
			continue;
		}
		if (!strcmp(args[i], "&"))
		{
			args[i] = NULL;
		}
		i++;
	}
	pid_t childPid = fork();
	if (!childPid)
	{
		if (stdoutFile != NULL)
		{
			FILE *file = fopen(stdoutFile, &stdoutFileMode);
			if (file == NULL)
				fputs("Could not open file", stderr);
			dup2(fileno(file), STDOUT_FILENO);
			fclose(file);
		}
		if (stderrFile != NULL)
		{
			FILE *file = fopen(stderrFile, &stderrFileMode);
			if (file == NULL)
				fputs("Could not open file", stderr);
			dup2(fileno(file), STDERR_FILENO);
			fclose(file);
		}
		if (stdinFile != NULL)
		{
			FILE *file = fopen(stdinFile, "r");
			if (file == NULL)
				fputs("Could not open file", stderr);
			dup2(fileno(file), STDIN_FILENO);
			fclose(file);
		}
		pid_t pid = getpid();
		setpgid(pid, pid);
		if (!background)
			tcsetpgrp(STDIN_FILENO, getpgid(pid));
		execv(path, args);
		perror("Command Not Found");
		exit(1);
	}
	return childPid;
}

// Create a string from string array
void arrayToString(char **arr, char *str)
{
	if (arr[0] == NULL)
		return;
	strcpy(str, arr[0]);
	int i;
	for (i = 1; i < (MAX_LINE / 2 + 1); i++)
	{
		if (arr[i] == NULL)
			break;
		strcat(str, " ");
		strcat(str, arr[i]);
	}
}
