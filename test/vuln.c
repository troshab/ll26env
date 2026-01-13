// Simple vulnerable program for testing GDB and Ghidra
// Compile: gcc -fno-stack-protector -no-pie -o vuln vuln.c

#include <stdio.h>
#include <string.h>

void win() {
    puts("You win!");
}

void vulnerable() {
    char buf[32];
    puts("Enter input:");
    gets(buf);  // vulnerable!
    printf("You said: %s\n", buf);
}

int main() {
    setvbuf(stdout, NULL, _IONBF, 0);
    vulnerable();
    return 0;
}
