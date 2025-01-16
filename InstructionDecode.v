module InstructionDecode(
    input clk, resetl, RegWrite_WB,
    input [4:0] RD_WB,
    input [31:0] instruction_ID,
    input [63:0] pc_ID, MemtoRegOut_WB,
    output RegWrite_EX, ALUSrc_EX, Branch_EX, Uncondbranch_EX, MemRead_EX, MemWrite_EX, Mem2Reg_EX,
    output [3:0] ALUOp_EX,
    output [4:0] RD_EX,
    output [63:0] RegOutA_EX, RegOutB_EX, SignExtImm64_EX, pc_EX
    );

    // Interim Registers
    reg RegWrite_ID_reg, ALUSrc_ID_reg, Branch_ID_reg, Uncondbranch_ID_reg;
    reg MemRead_ID_reg, MemWrite_ID_reg, Mem2Reg_ID_reg;
    reg [3:0] ALUOp_ID_reg;
    reg [4:0] RD_ID_reg;
    reg [63:0] RegOutA_ID_reg, RegOutB_ID_reg, SignExtImm64_ID_reg, pc_ID_reg;

    // Control Connections    
    wire Reg2Loc_ID, RegWrite_ID, ALUSrc_ID, Branch_ID, Uncondbranch_ID, MemRead_ID, MemWrite_ID, Mem2Reg_ID;
    wire [2:0] SignOp_ID; 
    wire [3:0] ALUOp_ID;

    // Register File Connections
    wire [4:0] 		  rd;            // The destination register
    wire [4:0] 		  rm;            // Operand 1
    wire [4:0] 		  rn;            // Operand 2
    wire [10:0] 	  opcode;
    assign rd = instruction_ID[4:0];
    assign rm = instruction_ID[9:5];
    assign rn = Reg2Loc_ID ? instruction_ID[4:0] : instruction_ID[20:16];
    assign opcode = instruction_ID[31:21];
    wire [63:0] RegOutA_ID, RegOutB_ID;

    // Sign Extender Connections
    wire [63:0] SignExtImm64_ID;

    Control control(
        .reg2loc(Reg2Loc_ID),
        .alusrc(ALUSrc_ID),
        .mem2reg(Mem2Reg_ID),
        .regwrite(RegWrite_ID),
        .memread(MemRead_ID),
        .memwrite(MemWrite_ID),
        .branch(Branch_ID),
        .uncond_branch(Uncondbranch_ID),
        .aluop(ALUOp_ID),
        .signop(SignOp_ID),
        .opcode(opcode)
    );

    RegisterFile rf(
       .BusA(RegOutA_ID),
       .BusB(RegOutB_ID),
       .BusW(MemtoRegOut_WB),
       .RA(rm),
       .RB(rn),
       .RW(RD_WB),
       .RegWr(RegWrite_WB),
       .Clk(clk)
    );

    SignExtender signext(
       .BusImm(SignExtImm64_ID),
       .Imm26(instruction_ID[25:0]),
       .Ctrl(SignOp_ID)
    );


    always @(posedge clk or negedge resetl) 
    begin
        if(resetl) begin
            RegWrite_ID_reg <= RegWrite_ID;
            ALUSrc_ID_reg <= ALUSrc_ID;
            Branch_ID_reg <= Branch_ID;
            Uncondbranch_ID_reg <= Uncondbranch_ID;
            MemRead_ID_reg <= MemRead_ID;
            MemWrite_ID_reg <= MemWrite_ID;
            Mem2Reg_ID_reg <= Mem2Reg_ID;
            ALUOp_ID_reg <= ALUOp_ID;
            RD_ID_reg <= rd;
            RegOutA_ID_reg <= RegOutA_ID;
            RegOutB_ID_reg <= RegOutB_ID;
            SignExtImm64_ID_reg <= SignExtImm64_ID;
            pc_ID_reg <= pc_ID;
        end
        else begin
            RegWrite_ID_reg <= 1'b0;
            ALUSrc_ID_reg <= 1'b0;
            Branch_ID_reg <= 1'b0;
            Uncondbranch_ID_reg <= 1'b0;
            MemRead_ID_reg <= 1'b0;
            MemWrite_ID_reg <= 1'b0;
            Mem2Reg_ID_reg <= 1'b0;
            ALUOp_ID_reg <= 4'b0;
            RD_ID_reg <= 5'b0;
            RegOutA_ID_reg <= 64'b0;
            RegOutB_ID_reg <= 64'b0;
            SignExtImm64_ID_reg <= 64'b0;
            pc_ID_reg <= 64'b0;
        end
    end

    assign RegWrite_EX = RegWrite_ID_reg;
    assign ALUSrc_EX = ALUSrc_ID_reg;
    assign Branch_EX = Branch_ID_reg;
    assign Uncondbranch_EX = Uncondbranch_ID_reg;
    assign MemRead_EX = MemRead_ID_reg;
    assign MemWrite_EX = MemWrite_ID_reg;
    assign Mem2Reg_EX = Mem2Reg_ID_reg;
    assign ALUOp_EX = ALUOp_ID_reg;
    assign RD_EX = RD_ID_reg;
    assign RegOutA_EX = RegOutA_ID_reg;
    assign RegOutB_EX = RegOutB_ID_reg;
    assign SignExtImm64_EX = SignExtImm64_ID_reg; 
    assign pc_EX = pc_ID_reg;

endmodule