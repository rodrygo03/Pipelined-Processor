#!/bin/bash

iverilog -o Proccesor.v Control.v SignExtender.v RegisterFile.v NextPClogic.v InstructionMemory.v DataMemory.v ALU.v

