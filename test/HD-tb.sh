#!/bin/bash

iverilog -o HD_tb HazardDetection_tb.v ../HazardDetectionUnit.v
./HD_tb