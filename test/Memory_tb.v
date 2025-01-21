`timescale 1ns / 1ps

`define STRLEN 32
`define HalfClockPeriod 60
`define ClockPeriod `HalfClockPeriod * 2

module MEM_tb;

    task passTest;
        input [63:0] actualOut, expectedOut;
        input [`STRLEN*8:0] testType;

        if(actualOut == expectedOut) begin $display ("%s passed", testType); end
        else $display ("%s failed: 0x%x should be 0x%x", testType, actualOut, expectedOut);
    endtask

    initial
    begin
        $dumpfile("Memory_tb.vcd");
        $dumpvars;
    end

    // inputs
    reg CLK, Reset_L, ALUzero_mem;
    reg RegWrite_mem, Branch_mem, Uncondbranch_mem, MemRead_mem, MemWrite_mem, Mem2Reg_mem;
    reg [4:0] RD_mem;
    reg [63:0] RegOutB_mem, ALUout_mem, PCtarget_mem;
    
    // outputs
    wire pcsrc;
    wire [4:0] RD_wb;
    wire [63:0] ALUout_wb, ReadData_wb, PCtarget;

    Memory UUT(
        .clk(CLK),
        .resetl(Reset_L),
        .ALUzero_MEM(ALUzero_mem),
        .RegWrite_MEM(RegWrite_mem),
        .Branch_MEM(Branch_mem),
        .Uncondbranch_MEM(Uncondbranch_mem),
        .MemRead_MEM(MemRead_mem),
        .MemWrite_MEM(MemWrite_mem),
        .Mem2Reg_MEM(Mem2Reg_mem),
        .RD_MEM(RD_mem),
        .RegOutB_MEM(RegOutB_mem),
        .ALUout_MEM(ALUout_mem),
        .PCtarget_MEM(PCtarget_mem),
        .PCSrc(pcsrc),
        .RD_WB(RD_wb),
        .ALUout_WB(ALUout_wb),
        .ReadData_WB(ReadData_wb),
        .PCtarget(PCtarget)
    );

    initial begin
        // reset
        Reset_L = 0;
        ALUzero_mem = 0;
        RegWrite_mem = 0;
        Branch_mem = 0;
        Uncondbranch_mem = 0;
        MemRead_mem = 0;
        MemWrite_mem = 0;
        Mem2Reg_mem = 0;
        RD_mem = 0;
        RegOutB_mem = 0;
        ALUout_mem = 0;
        PCtarget_mem = 0;

        // Wait for global reset
        #(1 * `ClockPeriod);
        #1
        Reset_L = 0; 
        @(posedge CLK);
        @(negedge CLK);
        @(posedge CLK);
        Reset_L = 1;

        $display("mem[1] <- 10 | reset:", Reset_L);
        // mem[1] <- 10;
        ALUzero_mem = 0;
        RegWrite_mem = 0;
        Branch_mem = 0;
        Uncondbranch_mem = 0;
        MemRead_mem = 0;
        MemWrite_mem = 1;
        Mem2Reg_mem = 0;
        RD_mem = 0;
        RegOutB_mem = 10;
        ALUout_mem = 1;
        PCtarget_mem = 64'h8;
 
        @(posedge CLK);
        @(negedge CLK);

        passTest(ALUout_wb, 1, "ALUout");
        passTest(PCtarget, 8, "PC Target");
        passTest(pcsrc, 0, "PC Source");

        $display("reg[2] <- mem[1] | reset:", Reset_L);
        // reg[2] <- mem[1];
        ALUzero_mem = 0;
        RegWrite_mem = 1;
        Branch_mem = 0;
        Uncondbranch_mem = 0;
        MemRead_mem = 1;
        MemWrite_mem = 0;
        Mem2Reg_mem = 1;
        RD_mem = 2;
        RegOutB_mem = 0;   
        ALUout_mem = 1;
        PCtarget_mem = 64'h128;
 
        @(posedge CLK);
        @(negedge CLK);
        passTest(RD_wb, 2, "RD");
        @(posedge CLK);
        @(negedge CLK);
        passTest(ReadData_wb, 10, "ReadData");

        $display("mem[12] <- 44 | reset:", Reset_L);
        // mem[12] <- 44;
        ALUzero_mem = 0;
        RegWrite_mem = 0;
        Branch_mem = 0;
        Uncondbranch_mem = 0;
        MemRead_mem = 0;
        MemWrite_mem = 1;
        Mem2Reg_mem = 0;
        RD_mem = 0;
        RegOutB_mem = 44;
        ALUout_mem = 12;
        PCtarget_mem = 64'h32;

        @(posedge CLK);
        @(negedge CLK);

        passTest(ALUout_wb, 12, "ALUout");
        passTest(PCtarget, 64'h32, "PC Target");
        passTest(pcsrc, 0, "PC Source");

        $display("reg[10] <- mem[12] | reset:", Reset_L);
        // reg[10] <- mem[12];
        ALUzero_mem = 0;
        RegWrite_mem = 1;
        Branch_mem = 0;
        Uncondbranch_mem = 0;
        MemRead_mem = 1;
        MemWrite_mem = 0;
        Mem2Reg_mem = 1;
        RD_mem = 10;
        RegOutB_mem = 0;   
        ALUout_mem = 12;
        PCtarget_mem = 64'h64;

        @(posedge CLK);
        @(negedge CLK);
        passTest(RD_wb, 10, "RD");
        @(posedge CLK);
        @(negedge CLK);
        passTest(ReadData_wb, 44, "ReadData");

        // CBZ
        $display("CBZ | reset:", Reset_L);
        ALUzero_mem = 1;
        RegWrite_mem = 0;
        Branch_mem = 1;
        Uncondbranch_mem = 0;
        MemRead_mem = 0;
        MemWrite_mem = 0;
        Mem2Reg_mem = 0;
        RD_mem = 0;
        RegOutB_mem = 0;   
        ALUout_mem = 0;
        PCtarget_mem = 64'h69;

        @(posedge CLK);
        @(negedge CLK);

        passTest(pcsrc, 1, "PCSrc");
        passTest(PCtarget_mem, 64'h69, "PC Target");

        // B
        $display("B | reset:", Reset_L);
        ALUzero_mem = 0;
        RegWrite_mem = 0;
        Branch_mem = 0;
        Uncondbranch_mem = 1;
        MemRead_mem = 0;
        MemWrite_mem = 0;
        Mem2Reg_mem = 0;
        RD_mem = 0;
        RegOutB_mem = 0;   
        ALUout_mem = 0;
        PCtarget_mem = 64'h420;

        @(posedge CLK);
        @(negedge CLK);

        passTest(pcsrc, 1, "PCSrc");
        passTest(PCtarget_mem, 64'h420, "PC Target");

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