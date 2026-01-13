#!/bin/bash
# Build vulnerable C binary for exploitation practice
#
# Security flags disabled:
#   -fno-stack-protector  - disable stack canaries
#   -no-pie               - disable ASLR (fixed addresses)
#   -z execstack          - make stack executable
#   -g                    - include debug symbols

gcc -fno-stack-protector -no-pie -z execstack -g -o vuln vuln.c

echo "Built: vuln"
echo ""
echo "Verify protections disabled:"
checksec --file=vuln
