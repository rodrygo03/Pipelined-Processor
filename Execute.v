module Execute(
    input clk, resetl, RegWrite_EX, ALUSrc_EX, Branch_EX, Uncondbranch_EX, MemRead_EX, MemWrite_EX, Mem2Reg_EX,
    input [3:0] ALUOp_EX,
    input [4:0] RD_EX,
    input [63:0] RegOutA_EX, RegOutB_EX, SignExtImm64_EX, pc_EX,
    output RegWrite_MEM, Branch_MEM, Uncondbranch_MEM, MemRead_MEM, MemWrite_MEM, Mem2Reg_MEM,
    output ALUzero_MEM, 
    output [4:0] RD_MEM,
    output [63:0] RegOutB_MEM, ALUout_MEM, PCtarget_MEM
    );

    // Interim Reg
    reg RegWrite_EX_reg, Branch_EX_reg, Uncondbranch_EX_reg, MemRead_EX_reg, MemWrite_EX_reg, Mem2Reg_EX_reg;
    reg ALUzero_EX_reg;
    reg [4:0] RD_EX_reg;
    reg [63:0] RegOutB_EX_reg, ALUout_EX_reg, PCtarget_EX_reg;

    // PC target for branching
    wire [63:0] target;
    assign target = pc_EX + SignExtImm64_EX;

    // ALU Connections
    wire zero;
    wire [63:0] aluout;
    wire [63:0] aluBin;
    assign aluBin = ALUSrc_EX ? SignExtImm64_EX : RegOutB_EX;

    ALU alu(
        .BusW(aluout),
        .BusA(RegOutA_EX),
        .BusB(aluBin),
        .ALUCtrl(ALUOp_EX),
        .Zero(zero)
    );


    always @(posedge clk or negedge resetl)
    begin
        if (resetl) begin
            RegWrite_EX_reg <= RegWrite_EX;
            Branch_EX_reg <= Branch_EX;
            Uncondbranch_EX_reg <= Uncondbranch_EX;
            MemRead_EX_reg <= MemRead_EX;
            MemWrite_EX_reg <= MemWrite_EX;
            Mem2Reg_EX_reg <= Mem2Reg_EX;
            ALUzero_EX_reg <= zero;
            RD_EX_reg <= RD_EX;
            RegOutB_EX_reg <= RegOutB_EX;
            ALUout_EX_reg <= aluout;
            PCtarget_EX_reg <= target;
        end
        else begin
            RegWrite_EX_reg <= 1'b0;
            Branch_EX_reg <= 1'b0;
            Uncondbranch_EX_reg <= 1'b0;
            MemRead_EX_reg <= 1'b0;
            MemWrite_EX_reg <= 1'b0;
            Mem2Reg_EX_reg <= 1'b0;
            ALUzero_EX_reg <= 1'b0;
            RD_EX_reg <= 5'b0;
            RegOutB_EX_reg <= 64'b0;
            ALUout_EX_reg <= 64'b0;
            PCtarget_EX_reg <= 64'b0;
        end
    end

    assign RegWrite_MEM = RegWrite_EX_reg;
    assign Branch_MEM = Branch_EX_reg;
    assign Uncondbranch_MEM = Uncondbranch_EX_reg;
    assign MemRead_MEM = MemRead_EX_reg;
    assign MemWrite_MEM = MemWrite_EX_reg;
    assign Mem2Reg_MEM = Mem2Reg_EX_reg;
    assign ALUzero_MEM = ALUzero_EX_reg;
    assign RD_MEM = RD_EX_reg;
    assign RegOutB_MEM = RegOutB_EX_reg;
    assign ALUout_MEM = ALUout_EX_reg;
    assign PCtarget_MEM = PCtarget_EX_reg;

endmodule