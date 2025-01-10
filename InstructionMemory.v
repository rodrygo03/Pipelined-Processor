/*
 * Module: InstructionMemory
 *
 * Implements read-only instruction memory
 * 
 */

`timescale 1ns / 1ps

module InstructionMemory(Data, Address);
	parameter T_rd = 20;
	parameter MemSize = 40;
	
	output [31:0] Data;
	input  [63:0] Address;
	reg    [31:0] Data;
	   
	always @ (Address) begin
		case(Address)
		   /* Test Program 1:
			* MOVZ    X0, #10         // Load a = 10
			* MOVZ    X1, #20         // Load b = 20
			* MOVZ    X2, #15         // Load c = 15
			* MOVZ    X3, #5          // Load d = 5
			* ADD     X4, X0, X1      // X4 = a + b
			*/
			63'h000: Data = {11'b11010010100, 16'hA, 5'b00000};
			63'h004: Data = {11'b11010010100, 16'h14, 5'b00001};
			63'h008: Data = {11'b11010010100, 16'hF, 5'b00010};
			63'h00c: Data = {11'b11010010100, 16'h5, 5'b00011};
			63'h010: Data = {11'b00001011000, 5'b00001, 6'b000000, 5'b00000, 5'b00100}; 
			default: Data = 32'hXXXXXXXX;


		endcase
	end
endmodule
