global alloc
global alloc_c
global release


section .rodata
    MAX_HEAP_SIZE equ 1024 * 1024 * 2   ; максимальный размер кучи

section .data
    CURRENT_HEAP_SIZE: dq 0 ; текущая заполненность кучи
    heap_start: dq heap                 ; начало кучи


section .bss
    heap: resb MAX_HEAP_SIZE            ; куча


section .text

;------------------------------;
; rcx - размер ячейки          ;
; rax - возвращаемый указатель ;
;------------------------------;
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
    mov qword [rax + 8], rbx            ; размер ячейки(включая доп информацию)
    
    add rax, 16                          ; перемещаем указатель так, чтобы он не указывал на доп информацию
    add [rel CURRENT_HEAP_SIZE], rbx

    ret

;---------------------------------;
; rcx - указатель для освобождения;
;---------------------------------;
release:
    sub rcx, 8
    
    mov qword [rcx], 1
    mov rbx, [rcx]
    sub [rel CURRENT_HEAP_SIZE], rbx
    mov qword [rcx - 8], 0

    ret

;--------------------------------;
; rcx - кол-во ячеек             ;
; rdx - размер ячейки            ;
; rax - возвращаемый указатель   ;
;--------------------------------;
alloc_c:
; размер ячейки
    mov rbx, rdx
    call align_by_eight

; размер всех ячеек
    mov rax, rbx
    mul rcx
    add rax, 16

; проверка на наличие места
    mov rdx, [rel CURRENT_HEAP_SIZE]
    add rdx, rax
    cmp rdx, MAX_HEAP_SIZE
    ja ret_null
    
; главный указатель
    mov rdx, [rel heap_start]
    add rdx, [rel CURRENT_HEAP_SIZE] ; перемещаем на первую свободную память
    
; устанавливаем значения указателя
    mov [rdx], rax ; размер всех ячеек, включая мета-данные указателя

    add rdx, 8
    mov [rdx], rbx ; размер одной ячейки / шаг
    add rdx, 8

    sub [rel CURRENT_HEAP_SIZE], rax

; возвращаем указатель
    push rdx
    pop rax

    ret

reallocate:

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