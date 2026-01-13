; shellcode.nasm - Position-independent shellcode that prints "Hello, World!"
; Build: ./build.sh

section .text
    global _start

_start:
    jmp message

shellcode:
    xor rax, rax        ; clear registers (avoid null bytes)
    xor rdi, rdi
    xor rdx, rdx
    mov al, 0x1         ; syscall: write
    mov dil, 0x1        ; fd: stdout
    pop rsi             ; get message address from stack
    mov dl, 0xF         ; length: 15
    syscall

    mov al, 0x3c        ; syscall: exit
    xor rdi, rdi        ; status: 0
    syscall

message:
    call shellcode      ; push address of msg onto stack
    db "Hello, World!", 0ah
