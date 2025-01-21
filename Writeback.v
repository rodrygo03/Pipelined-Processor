module Writeback(
    input clk, resetl, Mem2Reg_WB,
    input [4:0] RD_WB,
    input [63:0] ALUout_WB, ReadData_WB,
    output [4:0] RD,
    output [63:0] MemtoRegOut
    );

    assign RD = RD_WB;
    assign MemtoRegOut = Mem2Reg_WB ? ReadData_WB : ALUout_WB;

endmodule