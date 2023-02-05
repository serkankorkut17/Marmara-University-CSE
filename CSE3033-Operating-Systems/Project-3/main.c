/*
Ömer Kibar 150119037
Serkan Korkut 150119036
Müslim Yılmaz 150119566
*/

#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//Entry functions for different type of threads
void *reader(void *param);
void *upper(void *param);
void *replace(void *param);
void *writer(void *param);

int countNumberOfLines(char *fileName);

//Struct for holding arguments of reader threads
struct ReaderArg{
    int threadNo;
    int startLine;
    int endLine;
}typedef ReaderArg;

//Struct for holding each line and status of the line
struct Line{
    char line[1024];
    int uppered; //1 if line is uppered by upper threads 0 otherwise
    int replaced; //1 if line is replaced by replace threads 0 otherwise
}typedef Line;

char *fileName; //Holds file name given as argument. It is assigned at the main function
Line **lines; //Global array for holding lines.
int numberOfLines; //Holds the number of lines in the file. It is assigned at the main function
int upperCount; //Holds the uppered lines count
int replaceCount; //Holds the replaced lines count
int writeIndex; //Holds first not written index
int upperIndex; //Holds first not uppered index
int replaceIndex; //Holds first not replaced index
 
pthread_mutex_t **mutex; //Mutex array (When a thread modifies some index of lines array it should first lock the corresponding mutex from the mutex array.)
pthread_mutex_t replaceMutex; //Mutex for replaceIndex global variable
pthread_mutex_t upperMutex; //Mutex for upperIndex global variable
pthread_mutex_t writeMutex; //Mutex for writeIndex global variable

int main(int argc,char *argv[]){
    //Check arguments and initialize variables to hold thread counts for each thread type
    if(argc!=8){
        puts("Incorrect argument count. Correct use;\n./main.o -d filename -n %num %num %num %num\n");
        exit(1);
    }
    int readerThreadCount = atoi(argv[4]);
    int upperThreadCount = atoi(argv[5]);
    int replaceThreadCount = atoi(argv[6]);
    int writerThreadCount = atoi(argv[7]);
    if(readerThreadCount <= 0 || upperThreadCount <= 0 || replaceThreadCount <= 0 || writerThreadCount <= 0){
        puts("Thread counts should be positive number.");
        exit(1);
    }
    //Initialize global variables and mutexes.
    fileName = argv[2];
    pthread_mutex_init(&writeMutex, NULL);
    pthread_mutex_init(&upperMutex,NULL);
    pthread_mutex_init(&replaceMutex,NULL);
    numberOfLines = countNumberOfLines(fileName);
    lines = (Line**)malloc(sizeof(Line*)*numberOfLines);
    mutex = (pthread_mutex_t**)malloc(sizeof(pthread_mutex_t*)*numberOfLines);
    int i;
    for(i = 0;i<numberOfLines;i++){
        lines[i] = NULL;
        mutex[i] = (pthread_mutex_t*)malloc(sizeof(pthread_mutex_t));
        pthread_mutex_init(mutex[i],NULL);
    }
    //Create reader threads. Each reader thread assigned to read some number of lines.
    pthread_t readerThreads[readerThreadCount];
    int currentLine = 0;
    int lineCount = numberOfLines/readerThreadCount;
    for(i=0;i<readerThreadCount;i++){
        ReaderArg *readerArg = (ReaderArg*)malloc(sizeof(ReaderArg));
        readerArg->threadNo = i;
        readerArg->startLine = currentLine;
        readerArg->endLine = currentLine+lineCount;
        if(i == readerThreadCount-1){
            readerArg->endLine = readerArg->startLine + numberOfLines - currentLine;
        }
        currentLine += lineCount;
        pthread_create(&readerThreads[i],NULL,reader,readerArg);
    }
    //Create writer threads
    pthread_t writerThreads[writerThreadCount];
    for(i=0;i<writerThreadCount;i++){
        int *threadNo = (int *)malloc(sizeof(int));
        *threadNo = i;
        pthread_create(&writerThreads[i],NULL,writer,threadNo);
    }
    //Create upper threads
    pthread_t upperThreads[upperThreadCount];
    for(i=0;i<upperThreadCount;i++){
        int *threadNo = (int *)malloc(sizeof(int));
        *threadNo = i;
        pthread_create(&upperThreads[i],NULL,upper,threadNo);
    }
    //Create replace threads
    pthread_t replaceThreads[replaceThreadCount];
    for(i=0;i<replaceThreadCount;i++){
        int *threadNo = (int *)malloc(sizeof(int));
        *threadNo = i;
        pthread_create(&replaceThreads[i],NULL,replace,threadNo);
    }
    //Wait all threads
    for(i=0;i<readerThreadCount;i++){
        pthread_join(readerThreads[i],NULL);
    }
    for(i=0;i<upperThreadCount;i++){
        pthread_join(upperThreads[i],NULL);
    }
    for(i=0;i<replaceThreadCount;i++){
        pthread_join(replaceThreads[i],NULL);
    }
    for(i=0;i<writerThreadCount;i++){
        pthread_join(writerThreads[i],NULL);
    }
    //Destroy mutexes
    pthread_mutex_destroy(&writeMutex);
    pthread_mutex_destroy(&upperMutex);
    pthread_mutex_destroy(&replaceMutex);
    for(i=0;i<numberOfLines;i++){
        pthread_mutex_destroy(mutex[i]);
    }
    pthread_exit(NULL);
}

void *reader(void *param){
    ReaderArg *readerArg = (ReaderArg*)param;
    if(readerArg->startLine == readerArg->endLine){
        pthread_exit(NULL);
    }
    FILE *file;
    file = fopen(fileName,"r");
    int lineNo = 0;
    char line[1024];
    while(fgets(line, 1024, file)){
        //Each reader thread reads its assigned lines
        if(lineNo>=readerArg->startLine && lineNo<readerArg->endLine){
            //Remove newline character from the end of line
            char *pos;
            if ((pos=strchr(line, '\n')) != NULL)
                *pos = '\0';
            pthread_mutex_lock(mutex[lineNo]); //Lock the corresponding mutex from mutex array before modifying content of lines array.
            lines[lineNo] = (Line*)malloc(sizeof(Line));
            strcpy(lines[lineNo]->line,line);
            pthread_mutex_unlock(mutex[lineNo]);//Unlock the mutex.
            printf("Read_%d             Read_%d read the line %d which is \"%s\"\n",readerArg->threadNo,readerArg->threadNo,lineNo,line);
        }
        lineNo++;
    }
    pthread_exit(NULL);
}

void *upper(void *param){
    int threadNo = *((int *)(param));
    while(1){
        int index;
        pthread_mutex_lock(&upperMutex);//Lock the upperMutex before modifying upperIndex.
        if(upperIndex>=numberOfLines){
            pthread_mutex_unlock(&upperMutex);
            break;
        }
        index = upperIndex;
        upperIndex++;
        pthread_mutex_unlock(&upperMutex);//Unlock the mutex.
        //Wait until the index is readed
        while(!(lines[index]->line != NULL));
        pthread_mutex_lock(mutex[index]);//Lock the corresponding mutex from mutex array before modifying content of lines array.
        char line[1024];
        strcpy(line,lines[index]->line);
        //Convert lowercase letters to uppercase
        int j;
        for(j=0; lines[index]->line[j]!='\0'; j++){
            if(lines[index]->line[j]>='a' && lines[index]->line[j]<='z'){
                lines[index]->line[j] = lines[index]->line[j] - 32;
            }
        }
        lines[index]->uppered = 1;
        pthread_mutex_unlock(mutex[index]);//Unlock the mutex.
        printf("Upper_%d            Upper_%d read index %d and converted \"%s\" to \"%s\"\n",threadNo,threadNo,index,line,lines[index]->line);
    }
    pthread_exit(NULL);
}

void *replace(void *param){
    int threadNo = *((int *)(param));
    while(1){
        int index;
        pthread_mutex_lock(&replaceMutex);//Lock the replaceMutex before modifying replaceIndex
        if(replaceIndex>=numberOfLines){
            pthread_mutex_unlock(&replaceMutex);
            break;
        }
        index = replaceIndex;
        replaceIndex++;
        pthread_mutex_unlock(&replaceMutex);
        //Wait until the index is readed
        while(!(lines[index]->line != NULL));
        pthread_mutex_lock(mutex[index]);//Lock the corresponding mutex from mutex array before modifying content of lines array.
        char line[1024];
        strcpy(line,lines[index]->line);
        //Convert spaces to underline character
        int j;
        for(j=0; lines[index]->line[j]!='\0'; j++){
            if(lines[index]->line[j]==' '){
                lines[index]->line[j] = '_';
            }
        }
        lines[index]->replaced = 1;
        pthread_mutex_unlock(mutex[index]);//Unlock the mutex.
        printf("Replace_%d          Replace_%d read index %d and converted \"%s\" to \"%s\"\n",threadNo,threadNo,index,line,lines[index]->line); 
    }
    pthread_exit(NULL);
}

void *writer(void *param){
    int threadNo = *((int *)(param));//Lock the writeMutex before modifying writeIndex
    while(1){
        int index;
        pthread_mutex_lock(&writeMutex);
        if(writeIndex>=numberOfLines){
            pthread_mutex_unlock(&writeMutex);
            break;
        }
        index = writeIndex;
        writeIndex++;
        pthread_mutex_unlock(&writeMutex);
        //Wait until the index is readed, replaced and uppered
        while(!(lines[index]->line != NULL && lines[index]->replaced && lines[index]->uppered));
        FILE *fp;
        fp = fopen(fileName,"r+");
        char line[1024];
        int i = 0;
        while (1){
            if(i == index ){
                fprintf(fp,"%s\n", lines[index]->line);   
                break;
            }
            fgets(line, sizeof(line), fp);
            i++;
        }
        fclose(fp);
        printf("Writer_%d           Writer_%d write line %d back which is \"%s\"\n",threadNo,threadNo,index,lines[index]->line);
    }
    pthread_exit(NULL);
}

int countNumberOfLines(char *fileName){
    FILE *file;
    int count = 0;
    char c;  
    file = fopen(fileName,"r");
    char line[1024];
    while(fgets(line, 1024, file)){
        count++;
    }
    fclose(file);
    return count;
}
