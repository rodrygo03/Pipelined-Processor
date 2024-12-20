`define OPCODE_ANDREG 11'b?0001010???
`define OPCODE_ORRREG 11'b?0101010???
`define OPCODE_ADDREG 11'b?0?01011???
`define OPCODE_SUBREG 11'b?1?01011???
`define OPCODE_ADDIMM 11'b?0?10001???
`define OPCODE_SUBIMM 11'b?1?10001???
`define OPCODE_MOVZ   11'b110100101??
`define OPCODE_B      11'b?00101?????
`define OPCODE_CBZ    11'b?011010????
`define OPCODE_LDUR   11'b??111000010
`define OPCODE_STUR   11'b??111000000

/*************************************************************************************************************
Instruction	  Opcode	      Reg2Loc	Uncondbranch	Branch	MemRead	MemtoReg	MemWrite	ALUSrc	RegWrite	ALUOp
LDUR	        11111000010	  X	      0	            0		    1       1         0         1       1        	0010
STUR	        11111000000   1       0             0       0       x         1         1       0         0010					
ADD	          10001011000		0       0             0       0       0         0         0       1         0010							
SUB	          11001011000		0       0             0       0       0         0         0       1         0110           							
AND	          10001010000		0       0             0       0       0         0         0       1         0000							
ORR	          10101010000		0		    0             0       0       0         0         0       1         0001  					
CBZ	          10110100XXX		1       0             1       0       x         0         0       0         0111							
B	            000101XXXXX 	X	      1             x       0       x         0         x       0         xxxx							
**************************************************************************************************************/


module control(
	       output reg 	reg2loc,
	       output reg 	alusrc,
	       output reg 	mem2reg,
	       output reg 	regwrite,
	       output reg 	memread,
	       output reg 	memwrite,
	       output reg 	branch,
	       output reg 	uncond_branch,
	       output reg [3:0] aluop,
	       output reg [2:0] signop,
	       input [10:0] 	opcode
	       );

  always @(*) begin
	  casez (opcode)
      `OPCODE_LDUR:
        begin
            reg2loc       = 1'bx;
            alusrc        = 1'b1;
            mem2reg       = 1'b1;
            regwrite      = 1'b1;
            memread       = 1'b1;
            memwrite      = 1'b0;
            branch        = 1'b0;
            uncond_branch = 1'b0;
            aluop         = 4'b0010;       // Add alu op
            signop        = 3'b011;        // D-type opcode for sign extender module
        end
      `OPCODE_STUR:
        begin
            reg2loc       = 1'b1;
            alusrc        = 1'b1;
            mem2reg       = 1'bx;
            regwrite      = 1'b0;
            memread       = 1'b0;
            memwrite      = 1'b1;
            branch        = 1'b0;
            uncond_branch = 1'b0;
            aluop         = 4'b0010;       // Add alu op
            signop        = 3'b011;        // D-type opcode for sign extender module
        end
      `OPCODE_ADDREG:
        begin
            reg2loc       = 1'b0;
            alusrc        = 1'b0;
            mem2reg       = 1'b0;
            regwrite      = 1'b1;
            memread       = 1'b0;
            memwrite      = 1'b0;
            branch        = 1'b0;
            uncond_branch = 1'b0;
            aluop         = 4'b0010;      // Add alu op
            signop        = 3'bxxx;       // R-type does not use sign extender
        end
      `OPCODE_ADDIMM:
        begin        
            reg2loc       = 1'b0;
            alusrc        = 1'b0;
            mem2reg       = 1'b0;
            regwrite      = 1'b1;
            memread       = 1'b0;
            memwrite      = 1'b0;
            branch        = 1'b0;
            uncond_branch = 1'b0;
            aluop         = 4'b0010;      // Add alu op
            signop        = 3'b010;       // I-type opcode for sign extender module
        end
      `OPCODE_SUBREG:
        begin
            reg2loc       = 1'b0;
            alusrc        = 1'b0;
            mem2reg       = 1'b0;
            regwrite      = 1'b1;
            memread       = 1'b0;
            memwrite      = 1'b0;
            branch        = 1'b0;
            uncond_branch = 1'b0;
            aluop         = 4'b0110;      // Sub alu op
            signop        = 3'bxxx;       // R-type does not use sign extender
        end
      `OPCODE_SUBIMM:
        begin
            reg2loc       = 1'b0;
            alusrc        = 1'b0;
            mem2reg       = 1'b0;
            regwrite      = 1'b1;
            memread       = 1'b0;
            memwrite      = 1'b0;
            branch        = 1'b0;
            uncond_branch = 1'b0;
            aluop         = 4'b0110;      // Sub alu op
            signop        = 3'b010;       // I-type opcode for sign extender module
        end
      `OPCODE_ANDREG:
        begin
            reg2loc       = 1'b0;
            alusrc        = 1'b0;
            mem2reg       = 1'b0;
            regwrite      = 1'b1;
            memread       = 1'b0;
            memwrite      = 1'b0;
            branch        = 1'b0;
            uncond_branch = 1'b0;
            aluop         = 4'b0000;      // and op
            signop        = 3'bxxx;       // R-type does not use sign extender
        end
      `OPCODE_ORRREG:
        begin
            reg2loc       = 1'b0;
            alusrc        = 1'b0;
            mem2reg       = 1'b0;
            regwrite      = 1'b1;
            memread       = 1'b0;
            memwrite      = 1'b0;
            branch        = 1'b0;
            uncond_branch = 1'b0;
            aluop         = 4'b0001;      // or op
            signop        = 3'bxxx;       // R-type does not use sign extender
        end
      `OPCODE_CBZ:
        begin
            reg2loc       = 1'b1;
            alusrc        = 1'b0;
            mem2reg       = 1'bx;
            regwrite      = 1'b0;
            memread       = 1'b0;
            memwrite      = 1'b0;
            branch        = 1'b1;
            uncond_branch = 1'b0;
            aluop         = 4'b0111;      // pass b op
            signop        = 3'b001;       // CB-type opcode for sign extender module
        end
      `OPCODE_B:
        begin
            reg2loc       = 1'bx;
            alusrc        = 1'bx;          // regfile/data mem not affected
            mem2reg       = 1'bx;
            regwrite      = 1'b0;
            memread       = 1'b0;
            memwrite      = 1'b0;
            branch        = 1'bx;          
            uncond_branch = 1'b1;
            aluop         = 4'bxxxx;       // alu not used for uncondt branch
            signop        = 3'b000;        // B-type opcode for sign extender module
        end
      `OPCODE_MOVZ:
        begin
            reg2loc       = 1'b0;
            alusrc        = 1'b1;
            mem2reg       = 1'b0;
            regwrite      = 1'b1;
            memread       = 1'b0;
            memwrite      = 1'b0;
            branch        = 1'b0;
            uncond_branch = 1'b0;
            aluop         = 4'b0111;        
            signop        = 3'b100;       // I-type opcode for sign extender module
        end
      default:
        begin
            reg2loc       = 1'bx;
            alusrc        = 1'bx;
            mem2reg       = 1'bx;
            regwrite      = 1'b0;
            memread       = 1'b0;
            memwrite      = 1'b0;
            branch        = 1'b0;
            uncond_branch = 1'b0;
            aluop         = 4'bxxxx;      
            signop        = 3'bxxx;
        end
	  endcase
  end

endmodule
