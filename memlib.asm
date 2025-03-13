global alloc
global release


section .rodata
    MAX_HEAP_SIZE equ 1024 * 1024 * 2   ; максимальный размер кучи

section .data
    CURRENT_HEAP_SIZE: dq 0 ; текущая заполненность кучи
    heap_start: dq heap                 ; начало кучи


section .bss
    heap: resb MAX_HEAP_SIZE            ; куча


section .text
alloc:
    mov rbx, rcx                        ; записываю параметр в другой регистр для функции align
    call align_by_eight
    
    add rbx, 16                          ; добавить к размеру 8 байт для информации

    ; есть ли место в куче
    ; нету - вернуть null 
    mov rdx, [rel CURRENT_HEAP_SIZE]
    add rdx, rbx
    cmp rdx, MAX_HEAP_SIZE
    ja ret_null    
    
    mov rax, [rel heap_start]                 ; указатель на начало кучи
    add rax, [rel CURRENT_HEAP_SIZE]        ; отступ на свободную память

    mov qword [rax], 0              ; свободна ли память ячека
    mov qword [rax - 8], rbx            ; размер ячейки(включая доп информацию)
    
    sub rax, 16                          ; перемещаем указатель так, чтобы он не указывал на доп информацию
    sub [rel CURRENT_HEAP_SIZE], rbx

    ret

release:
    add rcx, 8
    
    mov qword [rcx], 1
    mov rbx, [rcx]
    add [rel CURRENT_HEAP_SIZE], rbx
    mov qword [rcx + 8], 0

    ret

align_by_eight:
    mov rax, rbx
    and rax, 7
    jz ret_align

    add rbx, 8
    sub rbx, rax
    ret

ret_align: ret
    
ret_null:
    mov rax, 0
    ret