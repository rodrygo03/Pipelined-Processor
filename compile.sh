#!/bin/bash

iverilog -o ProccesorTest Proccesor.v InstructionFetch.v InstructionDecode.v Execute.v Memory.v Writeback.v Control.v ProgramCounter.v SignExtender.v RegisterFile.v InstructionMemory.v DataMemory.v ALU.v
./ProccesorTest
