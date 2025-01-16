`timescale 1ns / 1ps

`define STRLEN 32
`define HalfClockPeriod 60
`define ClockPeriod `HalfClockPeriod * 2

module ID_tb;

    task passTest;
        input [63:0] actualOut, expectedOut;
        input [`STRLEN*8:0] testType;

        if(actualOut == expectedOut) begin $display ("%s passed", testType); end
        else $display ("%s failed: 0x%x should be 0x%x", testType, actualOut, expectedOut);
    endtask

    initial
    begin
        $dumpfile("InstructionDecode_tb.vcd");
        $dumpvars;
    end

    // inputs
    reg CLK, Reset_L, regwrite_wb;
    reg [4:0] destination_register_wb;
    reg [31:0] instruction_id;
    reg [63:0] pc_id, memtoregout_wb;
    
    // outputs
    wire RegWrite_EX, ALUSrc_EX, Branch_EX, Uncondbranch_EX, MemRead_EX, MemWrite_EX, Mem2Reg_EX;
    wire [3:0] ALUOp_EX;
    wire [4:0] RD_EX;
    wire [63:0] RegOutA_EX, RegOutB_EX, SignExtImm64_EX, pc_EX;

    // 
    InstructionDecode ID(
        .clk(CLK),
        .resetl(Reset_L),
        .RegWrite_WB(regwrite_wb),
        .RD_WB(destination_register_wb),
        .instruction_ID(instruction_id),
        .pc_ID(pc_id),
        .MemtoRegOut_WB(memtoregout_wb),
        .RegWrite_EX(RegWrite_EX),
        .ALUSrc_EX(ALUSrc_EX),
        .Branch_EX(Branch_EX),
        .Uncondbranch_EX(Uncondbranch_EX),
        .MemRead_EX(MemRead_EX),
        .MemWrite_EX(MemWrite_EX),
        .Mem2Reg_EX(Mem2Reg_EX),
        .ALUOp_EX(ALUOp_EX),
        .RD_EX(RD_EX),
        .RegOutA_EX(RegOutA_EX),
        .RegOutB_EX(RegOutB_EX),
        .SignExtImm64_EX(SignExtImm64_EX),
        .pc_EX(pc_EX)
    );

    initial begin
        // reset
        instruction_id = 32'h0;
        regwrite_wb = 0;                
        destination_register_wb = 0;
        memtoregout_wb = 0;
        pc_id = 0;
        // Wait for global reset
        #(1 * `ClockPeriod);
        #1
        Reset_L = 0; 
        @(posedge CLK);
        @(negedge CLK);
        @(posedge CLK);
        Reset_L = 1;

        // Checking Controls and registerfile outputs according to instruction:
        /********************************************************************************************************************
        Instruction	  	      Uncondbranch	Branch	MemRead	MemtoReg	MemWrite  ALUSrc	RegWrite	ALUOp
        LDUR	        	  0	            0		1       1           0         1         1        	0010
        STUR	              0             0       0       x           1         1         0           0010					
        ADD	          		  0             0       0       0           0         0         1           0010							
        SUB	          		  0             0       0       0           0         0         1           0110           							
        AND	          		  0             0       0       0           0         0         1           0000							
        ORR	          		  0             0       0       0           0         0         1           0001  					
        CBZ	          		  0             1       0       x           0         0         0           0111							
        B	           	      1             x       0       x           0         x         0           xxxx	
        *******************************************************************************************************************/
        pc_id = 4;
        $display("\nLDUR instruction at pc:", pc_id);
        instruction_id = 32'hF84003E9; // LDUR X9, [XZR, 0x0]

        // write 0 into x9 for further testing
        regwrite_wb = 1;
        destination_register_wb = 9;
        memtoregout_wb = 0;
        //

        @(posedge CLK);
        @(negedge CLK);
        @(posedge CLK);
        
        passTest(Uncondbranch_EX, 0, "Uncondbranch");
        passTest(Branch_EX, 0, "Branch");
        passTest(MemRead_EX, 1, "MemRead");
        passTest(Mem2Reg_EX, 1, "Mem2Reg");
        passTest(MemWrite_EX, 0, "MemWrite");
        passTest(ALUSrc_EX, 1, "ALUSrc");
        passTest(RegWrite_EX, 1, "RegWrite");
        passTest(ALUOp_EX, 4'b0010, "ALUOp");
        passTest(RD_EX, 9, "RD");
        passTest(RegOutA_EX, 0, "BusA");
        // passTest(RegOutB_EX, ?, "BusB"); not used for LDUR
        passTest(SignExtImm64_EX, 0, "Sign Ext");
        passTest(pc_EX, 4, "PC");

        
        pc_id = 8;
        $display("\nORR(register) instruction at pc:", pc_id);
        instruction_id = 32'b10101010000111110000000100101010; // ORR X10, X9, XZR 
 
        @(posedge CLK);
        @(negedge CLK);
        @(posedge CLK);

        passTest(Uncondbranch_EX, 0, "Uncondbranch");
        passTest(Branch_EX, 0, "Branch");
        passTest(MemRead_EX, 0, "MemRead");
        passTest(Mem2Reg_EX, 0, "Mem2Reg");
        passTest(MemWrite_EX, 0, "MemWrite");
        passTest(ALUSrc_EX, 0, "ALUSrc");
        passTest(RegWrite_EX, 1, "RegWrite");
        passTest(ALUOp_EX, 4'b0001, "ALUOp");
        passTest(RD_EX, 10, "RD");
        passTest(RegOutA_EX, 0, "BusA");
        passTest(RegOutB_EX, 0, "BusB");
        // passTest(SignExtImm64_EX, ?, "Sign Ext"); Not Used for ORR
        passTest(pc_EX, 8, "PC");

        // write 0 into x10 for further testing
        regwrite_wb = 1;
        destination_register_wb = 10;
        memtoregout_wb = 0;
        // 

        @(posedge CLK);
        @(negedge CLK);
        @(posedge CLK);

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