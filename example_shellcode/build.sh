#!/bin/bash
# Build shellcode and tester
#
# Security flags disabled for tester:
#   -fno-stack-protector  - disable stack canaries
#   -z execstack          - make stack executable (required!)
#   -no-pie               - disable ASLR
#   -g                    - include debug symbols

echo "=== Building shellcode from NASM ==="
nasm -f elf64 -g -F dwarf -o shellcode.o shellcode.nasm
ld -o shellcode shellcode.o
echo "Standalone: ./shellcode"

echo ""
echo "=== Extracting shellcode bytes ==="
objcopy -O binary -j .text shellcode shellcode.bin
echo "Bytes:"
xxd -i shellcode.bin | head -5

echo ""
echo "=== Building shellcode tester ==="
gcc -fno-stack-protector -z execstack -no-pie -g -o test_shellcode test_shellcode.c
echo "Tester: ./test_shellcode"

echo ""
echo "=== Verify protections disabled ==="
checksec --file=test_shellcode

echo ""
echo "=== Quick test ==="
./test_shellcode
