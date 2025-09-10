#!/bin/bash

iverilog -o MEM_tb Memory_tb.v ../Memory.v ../DataMemory.v 
./MEM_tb