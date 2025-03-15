global alloc
global alloc_c
global reallocate
global release


section .rodata
    MAX_HEAP_SIZE equ 1024 * 1024 * 2   ; максимальный размер кучи
    NO_FREE_MEM equ MAX_HEAP_SIZE + 1

section .data
    CURRENT_HEAP_SIZE: dq 0 ; текущая заполненность кучи
    heap: times MAX_HEAP_SIZE db 1


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
    
    mov rdx, rbx
    call find_free_mem
    cmp rax, [NO_FREE_MEM]
    je ret_null

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
    mov rdx, [rel heap]
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

;---------------------------;
; rcx - указатель           ;
; rdx - новый размер памяти ;
;---------------------------;
reallocate:
; сохраняем данные регистров
    push rcx

; ищем свободную область памяти
    mov rbx, rdx
    call align_by_eight
    mov rdx, rbx
    add rdx, 16 

    call find_free_mem
    cmp rax, [NO_FREE_MEM]
    je ret_null

; востанавливаем значения   
    pop rcx

; создаем новую ячейку
    mov rbx, [rel heap]
    add rbx, rax
    push rbx
    pop rax

    mov qword [rax], 1
    add rax, 8
    mov qword [rax], rdx
    add rax, 8

    ret

;---------------------------------;
; rbx - значение для выравнивания ;
;---------------------------------;
align_by_eight:
    mov rax, rbx
    and rax, 7
    jz _ret

    add rbx, 8
    sub rbx, rax
    ret

_ret: ret
    
ret_null:
    mov rax, 0
    ret


;----------------------------;
; rdx - запрашиваемая память ;
; rax - начало блока памяти  ;
;----------------------------;
find_free_mem:
    mov rax, [rel heap] ; ставим на начало кучи
    mov rbx, rax
    mov rcx, 0

find:
    cmp rbx, 1
    jne not_free

    inc rcx
    cmp rcx, rdx
    je _ret

    inc rbx
    jmp find

not_free:
    mov rcx, 0
    add rbx, 1
    mov rax, rbx

no_free_mem:
    mov rax, [NO_FREE_MEM]
    ret