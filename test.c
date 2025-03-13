#include <stdio.h>
#include <string.h>

extern void* alloc(size_t);
extern void release(void*);

int
main(void){
    char* test = (char*)alloc(sizeof(char));
    if(!test){
        printf("error\n");
        return 1;
    }

    strcpy(test, "H");

    printf("%c\n", *test);
        
    release(test);

    return 0;
}