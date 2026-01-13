#!/bin/bash
# Build x86-64 assembly binary
#
# Flags:
#   -f elf64  - 64-bit ELF format
#   -g        - include debug symbols (DWARF)
#   -F dwarf  - DWARF debug format for GDB

nasm -f elf64 -g -F dwarf -o hello.o hello.asm
ld -o hello hello.o

echo "Built: hello"
echo ""
echo "Run: ./hello"
echo "Debug: gdb ./hello"
echo "  (use 'b _start' not 'b main' - this is pure ASM)"
