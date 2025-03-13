#include <stddef.h>
#include <stdio.h>
#include <string.h>

extern void* alloc(size_t);
extern void* alloc_c(int, size_t);
extern void* reallocate(void*, size_t);
extern void release(void*);

int
main(void){
    char* test = (char*)alloc_c(12, sizeof(char));
    if(!test){
        printf("error\n");
        return 1;
    }

    printf("%p\n", test);

    test = (char*)reallocate(test, sizeof(char));
    if(!test){
        printf("error\n");
        return 1;
    }

    printf("%p\n", test);
        
    release(test);

    return 0;
}