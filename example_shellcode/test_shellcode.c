// test_shellcode.c - Execute shellcode from a byte array
// Build: ./build.sh

#include <stdio.h>
#include <string.h>

int main(int argc, char* argv[]) {
    // Shellcode bytes (Hello World)
    unsigned char code[] =
        "\xeb\x1a"                         // jmp message
        "\x48\x31\xc0"                     // xor rax, rax
        "\x48\x31\xff"                     // xor rdi, rdi
        "\x48\x31\xd2"                     // xor rdx, rdx
        "\xb0\x01"                         // mov al, 1
        "\x40\xb7\x01"                     // mov dil, 1
        "\x5e"                             // pop rsi
        "\xb2\x0f"                         // mov dl, 15
        "\x0f\x05"                         // syscall
        "\xb0\x3c"                         // mov al, 60
        "\x48\x31\xff"                     // xor rdi, rdi
        "\x0f\x05"                         // syscall
        "\xe8\xe1\xff\xff\xff"             // call shellcode
        "Hello, World!\n";                 // message

    printf("Shellcode Length: %ld\n", strlen(code));

    // Cast shellcode to function and execute
    void (*shell)() = (void (*)())code;
    shell();

    return 0;
}
