#!/bin/bash
# Build vulnerable C binary for exploitation practice
# Disables stack protector and PIE for easier exploitation

gcc -fno-stack-protector -no-pie -g -o vuln vuln.c

echo "Built: vuln"
echo "Run: ./vuln"
echo "Debug: gdb ./vuln"
