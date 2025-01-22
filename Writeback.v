module Writeback(
    input clk, resetl, RegWrite_WB, Mem2Reg_WB,
    input [4:0] RD_WB,
    input [63:0] ALUout_WB, ReadData_WB,
    output RegWrite_ID,
    output [4:0] RD_ID,
    output [63:0] MemtoRegOut_ID
    );

    assign RegWrite_ID = RegWrite_WB;
    assign RD_ID = RD_WB;
    assign MemtoRegOut_ID = Mem2Reg_WB ? ReadData_WB : ALUout_WB;

endmodule