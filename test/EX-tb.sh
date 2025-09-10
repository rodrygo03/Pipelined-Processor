#!/bin/bash

iverilog -o EX_tb Execute_tb.v ../Execute.v ../ALU.v ../ForwardingUnit.v  
./EX_tb