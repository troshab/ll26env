#!/bin/bash
# Build and test shellcode

echo "=== Building shellcode from NASM ==="
nasm -f elf64 -o shellcode.o shellcode.nasm
ld -o shellcode shellcode.o
echo "Run standalone: ./shellcode"

echo ""
echo "=== Extracting shellcode bytes ==="
objcopy -O binary -j .text shellcode shellcode.bin
xxd -i shellcode.bin | head -20
echo ""

echo "=== Building shellcode tester ==="
gcc -z execstack -fno-stack-protector -o test_shellcode test_shellcode.c
echo "Run tester: ./test_shellcode"

echo ""
echo "=== Quick test ==="
./test_shellcode
