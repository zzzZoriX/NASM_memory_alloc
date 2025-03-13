#include <stddef.h>
#include <stdio.h>
#include <string.h>

extern void* alloc(size_t);
extern void* alloc_c(int, size_t);
extern void release(void*);

int
main(void){
    char* test = (char*)alloc_c(12, sizeof(char));
    if(!test){
        printf("error\n");
        return 1;
    }

    strcpy(test, "Hello world!");

    for(size_t i = 0; i < 12; ++i)
        printf("%c", test[i]);
        
    release(test);

    return 0;
}