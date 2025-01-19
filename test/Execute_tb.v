`timescale 1ns / 1ps

`define STRLEN 32
`define HalfClockPeriod 60
`define ClockPeriod `HalfClockPeriod * 2

module EX_tb;

    task passTest;
        input [63:0] actualOut, expectedOut;
        input [`STRLEN*8:0] testType;

        if(actualOut == expectedOut) begin $display ("%s passed", testType); end
        else $display ("%s failed: 0x%x should be 0x%x", testType, actualOut, expectedOut);
    endtask

    initial
    begin
        $dumpfile("Execute_tb.vcd");
        $dumpvars;
    end

    // inputs
    reg CLK, Reset_L, RegWrite_ex, ALUSrc_ex;
    reg Branch_ex, Uncondbranch_ex, MemRead_ex, MemWrite_ex, Mem2Reg_ex;
    reg [3:0] ALUOp_ex;
    reg [4:0] RD_ex;
    reg [63:0] RegOutA_ex, RegOutB_ex, SignExtImm64_ex, pc_ex;
    
    // outputs
    wire RegWrite_mem, Branch_mem, Uncondbranch_mem, MemRead_mem, MemWrite_mem, Mem2Reg_mem;
    wire ALUzero_mem;
    wire [4:0] RD_mem;
    wire [63:0] RegOutB_mem, ALUout_mem, PCtarget_mem;

    Execute UUT(
        .clk(CLK),
        .resetl(Reset_L),
        .RegWrite_EX(RegWrite_ex),
        .ALUSrc_EX(ALUSrc_ex),
        .Branch_EX(Branch_ex),
        .Uncondbranch_EX(Uncondbranch_ex),
        .MemRead_EX(MemRead_ex),
        .MemWrite_EX(MemWrite_ex),
        .Mem2Reg_EX(Mem2Reg_ex),
        .ALUOp_EX(ALUOp_ex),
        .RD_EX(RD_ex),
        .RegOutA_EX(RegOutA_ex),
        .RegOutB_EX(RegOutB_ex),
        .SignExtImm64_EX(SignExtImm64_ex),
        .pc_EX(pc_ex),
        .RegWrite_MEM(RegWrite_mem),
        .Branch_MEM(Branch_mem),
        .Uncondbranch_MEM(Uncondbranch_mem),
        .MemRead_MEM(MemRead_mem),
        .MemWrite_MEM(MemWrite_mem),
        .Mem2Reg_MEM(Mem2Reg_mem),
        .ALUzero_MEM(ALUzero_mem),
        .RD_MEM(RD_mem),
        .RegOutB_MEM(RegOutB_mem),
        .ALUout_MEM(ALUout_mem),
        .PCtarget_MEM(PCtarget_mem)
    );

    initial begin
        // reset
        Reset_L = 0;
        RegWrite_ex = 0;
        ALUSrc_ex = 0;
        Branch_ex = 0;
        Uncondbranch_ex = 0;
        MemRead_ex = 0;
        MemWrite_ex = 0;
        Mem2Reg_ex = 0;
        ALUOp_ex = 0;
        RD_ex = 0;
        RegOutA_ex = 0;
        RegOutB_ex = 0;
        SignExtImm64_ex = 0;
        pc_ex = 0;

        // Wait for global reset
        #(1 * `ClockPeriod);
        #1
        Reset_L = 0; 
        @(posedge CLK);
        @(negedge CLK);
        @(posedge CLK);
        Reset_L = 1;

        // 0x0: STUR x14, [x0 #4]
        $display("\nSTUR instruction | reset:",Reset_L);
        RegWrite_ex = 0;
        ALUSrc_ex = 1;
        Branch_ex = 0;
        Uncondbranch_ex = 0;
        MemRead_ex = 0;
        MemWrite_ex = 1;
        Mem2Reg_ex = 1'bx;       // dont care for stur
        ALUOp_ex = 4'b0010;      // add
        RD_ex = 14;
        RegOutA_ex = 6;          // assume x0 contains 6
        RegOutB_ex = 0;          // not used here, dummy value 0
        SignExtImm64_ex = 4;
        pc_ex = 0;
        
        @(posedge CLK);
        @(negedge CLK);
        @(posedge CLK);

        passTest(RegWrite_mem, 0, "RegWrite");
        passTest(Branch_mem, 0, "Branch");
        passTest(Uncondbranch_mem, 0, "Uncondbranch");
        passTest(MemRead_mem, 0, "MemRead");
        passTest(MemWrite_mem, 1, "MemWrite");
        // passTest(Mem2Reg_mem, 1'bx, "Mem2Reg");
        passTest(ALUzero_mem, 0, "ALU zero");
        passTest(ALUout_mem, 10, "ALU out");
        passTest(RD_mem, 14, "RD");
        passTest(RegOutB_mem, 0, "RegOutB");
        passTest(PCtarget_mem, 4, "Target PC");


        pc_ex = 4; // set to 4 since branch does not occur in prev instruction
        // 0x4: B loop | assume 0x8 positive offset
        $display("\nB instruction | reset:",Reset_L);
        RegWrite_ex = 0;
        ALUSrc_ex = 1'bx;
        Branch_ex = 1'bx;
        Uncondbranch_ex = 1;
        MemRead_ex = 0;
        MemWrite_ex = 0;
        Mem2Reg_ex = 1'bx;
        ALUOp_ex = 4'b0000;
        RD_ex = 0;                // not used 
        RegOutA_ex = 0;           // not used
        RegOutB_ex = 0;           // not used
        SignExtImm64_ex = 8;
 
        @(posedge CLK);
        @(negedge CLK);
        @(posedge CLK);

        passTest(RegWrite_mem, 0, "RegWrite");
        // passTest(Branch_mem, 1'bx, "Branch");
        passTest(Uncondbranch_mem, 1, "Uncondbranch");
        passTest(MemRead_mem, 0, "MemRead");
        passTest(MemWrite_mem, 0, "MemWrite");
        // passTest(Mem2Reg_mem, 1'bx, "Mem2Reg");
        // passTest(ALUzero_mem, 1'bx, "ALU zero");
        // passTest(ALUout_mem, 64'bx, "ALU out");
        // passTest(RD_mem, 5'bx, "RD");
        // passTest(RegOutB_mem, 64'bx, "RegOutB");
        passTest(PCtarget_mem, 64'hC, "Target PC");

        pc_ex = 64'hC;
        // 0xC: CBZ x12, end  | assume 0xC negative offset
        $display("\nCBZ instruction | reset:",Reset_L);
        RegWrite_ex = 0;
        ALUSrc_ex = 0;
        Branch_ex = 1;
        Uncondbranch_ex = 0;
        MemRead_ex = 0;
        MemWrite_ex = 0;
        Mem2Reg_ex = 1'bx;
        ALUOp_ex = 0111;      // pass B 
        RD_ex = 12;
        RegOutA_ex = 0;       // not used
        RegOutB_ex = 0;       // asssume x12 contains zero
        SignExtImm64_ex = -64'hC;

        @(posedge CLK);
        @(negedge CLK);
        @(posedge CLK);

        passTest(RegWrite_mem, 0, "RegWrite");
        passTest(Branch_mem, 1, "Branch");
        passTest(Uncondbranch_mem, 0, "Uncondbranch");
        passTest(MemRead_mem, 0, "MemRead");
        passTest(MemWrite_mem, 0, "MemWrite");
        // passTest(Mem2Reg_mem, 1'bx, "Mem2Reg");
        passTest(ALUzero_mem, 1, "ALU zero");
        passTest(ALUout_mem, 0, "ALU out");
        passTest(RD_mem, 12, "RD");
        passTest(RegOutB_mem, 0, "RegOutB");
        passTest(PCtarget_mem, 0, "Target PC");

        $finish;
    end



    // Initialize the clock to be 0
    initial begin
        CLK = 0;
    end

    // The following is correct if clock starts at LOW level at StartTime //
    always begin
        #`HalfClockPeriod CLK = ~CLK;
        #`HalfClockPeriod CLK = ~CLK;
    end



endmodule