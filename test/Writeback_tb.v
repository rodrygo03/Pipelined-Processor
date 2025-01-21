`timescale 1ns / 1ps

`define STRLEN 32
`define HalfClockPeriod 60
`define ClockPeriod `HalfClockPeriod * 2

module WB_tb;

    task passTest;
        input [63:0] actualOut, expectedOut;
        input [`STRLEN*8:0] testType;

        if(actualOut == expectedOut) begin $display ("%s passed", testType); end
        else $display ("%s failed: 0x%x should be 0x%x", testType, actualOut, expectedOut);
    endtask

    initial
    begin
        $dumpfile("Writeback_tb.vcd");
        $dumpvars;
    end

    // inputs
    reg CLK, Reset_L, Mem2Reg_wb;
    reg [4:0] RD_wb;
    reg [63:0] ALUout_wb, ReadData_wb;

    // outputs
    wire [4:0] RD;
    wire [63:0] MemtoRegOut;

    Writeback UUT(
        .clk(CLK),
        .resetl(Reset_L),
        .Mem2Reg_WB(Mem2Reg_wb),
        .RD_WB(RD_wb),
        .ALUout_WB(ALUout_wb),
        .ReadData_WB(ReadData_wb),
        .RD(RD),
        .MemtoRegOut(MemtoRegOut)
    );


    initial begin
        // reset
        Reset_L = 0;
        Mem2Reg_wb = 0;
        RD_wb = 0;
        ALUout_wb = 0;
        ReadData_wb = 0;

        // Wait for global reset
        #(1 * `ClockPeriod);
        #1
        Reset_L = 0; 
        @(posedge CLK);
        @(negedge CLK);
        @(posedge CLK);
        Reset_L = 1;

        // reg[3] <- mem[] = 56
        Mem2Reg_wb = 1;
        RD_wb = 3;
        ALUout_wb = 0;
        ReadData_wb = 56;
        
        @(posedge CLK);
        @(negedge CLK);
        @(posedge CLK);

        $display("reg[3] <- mem[] = 56 | reset:", Reset_L);
        passTest(RD, 3, "RD");
        passTest(MemtoRegOut, 56, "MemtoRegOut");

        // reg[7] <- 98
        Mem2Reg_wb = 0;
        RD_wb = 7;
        ALUout_wb = 98;
        ReadData_wb = 0;
 
        @(posedge CLK);
        @(negedge CLK);
        @(posedge CLK);

        $display("reg[7] <- 98 | reset:", Reset_L);
        passTest(RD, 7, "RD");
        passTest(MemtoRegOut, 98, "MemtoRegOut");

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