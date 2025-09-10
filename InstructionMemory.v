/*
 * Module: InstructionMemory
 *
 * Implements read-only instruction memory
 * 
 */

`timescale 1ns / 1ps

module InstructionMemory(Data, Address);
	parameter T_rd = 20;
	parameter MemSize = 1024;
	
	output [31:0] Data;
	input  [63:0] Address;
	
	reg [31:0] memory [0:255];
	
	initial begin
		$readmemh("program.hex", memory);
	end
	
	assign Data = memory[Address[9:2]];
	
endmodule
