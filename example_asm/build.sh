#!/bin/bash
# Build x86-64 assembly program

nasm -f elf64 -o hello.o hello.asm
ld -o hello hello.o

echo "Built: hello"
echo "Run: ./hello"
echo "Disassemble: objdump -d hello"
