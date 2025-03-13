global main

extern printf

; буду тестить
extern alloc
extern release

section .data
    msg1: db "prog start", 10 0
    msg2: db "prog end", 10, 0
    
    integ_fmt: db "%d", 10, 0

    success: db "success", 10, 0

section .text
main:
    sub rsp, 40
    
    lea rcx, [rel msg1]
    call printf

    mov rdi, 10
    call alloc
    test rax, rax
    jz exit

    mov rbx, rax
    
    xor eax, eax

    add rbx, 16
    lea rcx, [rel integ_fmt]
    mov rdx, [rbx]
    call printf
    sub rbx, 16

    mov rcx, rbx
    call release

    xor eax, eax
    lea rcx, [rel success]
    call printf

    add rsp, 40

exit:
    xor eax, eax
    lea rcx, [rel msg2]
    call printf
    ret