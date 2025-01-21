#!/bin/bash

iverilog -o WB_tb Writeback_tb.v Writeback.v 
./WB_tb