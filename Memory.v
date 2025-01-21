module Memory(
    input clk, resetl, ALUzero_MEM, 
    input RegWrite_MEM, Branch_MEM, Uncondbranch_MEM, MemRead_MEM, MemWrite_MEM, Mem2Reg_MEM,
    input [4:0] RD_MEM,
    input [63:0] RegOutB_MEM, ALUout_MEM, PCtarget_MEM,
    output PCSrc,
    output [4:0] RD_WB,
    output [63:0] ALUout_WB, ReadData_WB, PCtarget
    );

    // Interim Reg
    reg [4:0] RD_MEM_reg;
    reg [63:0] ALUout_MEM_reg, ReadData_MEM_reg;
    
    wire [63:0] readdata;
    DataMemory datamemory(
        .WriteData(RegOutB_MEM),
        .Address(ALUout_MEM),
        .Clock(clk),
        .MemoryRead(MemRead_MEM),
        .MemoryWrite(MemWrite_MEM),
        .ReadData(readdata)
    );


    always @(posedge clk or negedge resetl)
    begin
        if (resetl) begin
            RD_MEM_reg <= RD_MEM;
            ALUout_MEM_reg <= ALUout_MEM;
            ReadData_MEM_reg <= readdata;
        end
        else begin
            RD_MEM_reg <= 5'b0;
            ALUout_MEM_reg <= 64'b0;
            ReadData_MEM_reg <= 64'b0;
        end
    end

    assign RD_WB = RD_MEM_reg;
    assign PCtarget = PCtarget_MEM;
    assign ALUout_WB = ALUout_MEM_reg;
    assign ReadData_WB = ReadData_MEM_reg;
    assign PCSrc = Uncondbranch_MEM || (ALUzero_MEM && Branch_MEM);

endmodule