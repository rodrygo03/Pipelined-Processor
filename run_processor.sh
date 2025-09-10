#!/bin/bash

echo "Running Pipelined CPU with loaded assembly program..."

iverilog -o ProccesorTest ProccesorTest.v Proccesor.v InstructionFetch.v InstructionDecode.v Execute.v Memory.v Writeback.v \
         Control.v RegisterFile.v SignExtender.v ALU.v ProgramCounter.v InstructionMemory.v DataMemory.v \
         HazardDetectionUnit.v ForwardingUnit.v BranchPredictor.v

if [ $? -eq 0 ]; then
    echo "Compilation successful, running simulation..."
    ./ProccesorTest
else
    echo "Compilation failed"
    exit 1
fi