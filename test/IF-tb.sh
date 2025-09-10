#!/bin/bash

iverilog -o IF_tb InstructionFetch_tb.v ../InstructionFetch.v ../ProgramCounter.v ../InstructionMemory.v ../BranchPredictor.v
./IF_tb
