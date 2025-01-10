#!/bin/bash

iverilog -o ProccesorTest ProccesorTest.v Proccesor.v Control.v SignExtender.v RegisterFile.v NextPClogic.v InstructionMemory.v DataMemory.v ALU.v
./ProccesorTest
