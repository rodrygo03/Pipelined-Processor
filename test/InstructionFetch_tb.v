`timescale 1ns / 1ps

`define STRLEN 32
`define HalfClockPeriod 60
`define ClockPeriod `HalfClockPeriod * 2

module IF_tb;

    task passTest;
        input [63:0] actualOut, expectedOut;
        input [`STRLEN*8:0] testType;

        if(actualOut == expectedOut) begin $display ("%s passed", testType); end
        else $display ("%s failed: 0x%x should be 0x%x", testType, actualOut, expectedOut);
    endtask

    initial
    begin
        $dumpfile("InstructionFetch_tb.vcd");
        $dumpvars;
    end

    // inputs
    reg CLK, Reset_L, pcsrc, pc_stall;
    reg [63:0] targetPC, startPC;
    reg [15:0] watchdog;
    
    // outputs
    wire [63:0] pcID;
    wire [31:0] instructionID;

    // 
    InstructionFetch UUT(
        .clk(CLK),
        .resetl(Reset_L),
        .PCSrc(pcsrc),
        .TargetPC(targetPC),
        .StartPC(startPC),
        .pc_stall(pc_stall),
        .branch_taken_MEM(1'b0),
        .pc_MEM(64'b0),
        .instruction_ID(instructionID),
        .pc_ID(pcID)
    );

    initial begin
        Reset_L = 0;
        startPC = 0;
        pcsrc = 0;
        pc_stall = 0;
        targetPC = 10;
        
        watchdog = 0;
    
        // Wait for global reset
        #(1 * `ClockPeriod);

        // Program 1
        #1
        Reset_L = 0; startPC = 0;
        @(posedge CLK);
        @(negedge CLK);
        @(posedge CLK);
        Reset_L = 1;

        while (pcID < 64'h010)
        begin
        @(posedge CLK);
        @(negedge CLK);
            $display("pcID:%h",pcID);
        end
        passTest(instructionID, {11'b00001011000, 5'b00001, 6'b000000, 5'b00000, 5'b00100}, "Instruction from IF to ID");
        passTest(pcID, 63'h010, "Program Count from IF to ID");
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
        watchdog = watchdog +1;
    end

    // Kill the simulation if the watchdog hits 64K cycles
    always @*
        if (watchdog == 16'hFF)
        begin
            $display("Watchdog Timer Expired.");
            $finish;
        end

endmodule

