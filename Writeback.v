module Writeback(
    input clk, resetl, RegWrite_WB, Mem2Reg_WB,
    input [4:0] RD_WB,
    input [63:0] ALUout_WB, ReadData_WB,
    output RegWrite_ID,
    output [4:0] RD_ID,
    output [63:0] MemtoRegOut_ID
    );

    assign RD_ID = resetl ? RD_WB : 1'b0;
    assign RegWrite_ID = resetl ? RegWrite_WB : 1'b0;
    assign MemtoRegOut_ID = resetl ? (Mem2Reg_WB ? ReadData_WB : ALUout_WB) : 64'b0;

endmodule