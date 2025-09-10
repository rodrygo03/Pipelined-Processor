#!/bin/bash

iverilog -o ID_tb InstructionDecode_tb.v ../InstructionDecode.v ../Control.v ../RegisterFile.v ../SignExtender.v 
./ID_tb