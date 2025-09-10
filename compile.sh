#!/bin/bash

# Usage: ./compile.sh <program_name>

if [ $# -eq 0 ]; then
    echo "Usage: $0 <program_name>"
    echo "Available programs:"
    ls programs/*.s 2>/dev/null | sed 's/programs\///g' | sed 's/\.s//g'
    exit 1
fi

PROGRAM_NAME=$1
ASM_FILE="programs/${PROGRAM_NAME}.s"

if [ ! -f "$ASM_FILE" ]; then
    echo "Error: Assembly file $ASM_FILE not found"
    exit 1
fi

echo "Compiling $ASM_FILE..."
python3 compile_asm.py "$ASM_FILE"

if [ $? -eq 0 ]; then
    echo "Compilation successful! Generated program.hex"
    echo "Run processor test with: ./run_processor.sh"
else
    echo "Compilation failed"
    exit 1
fi