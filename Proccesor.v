module Proccesor(
   input 	         resetl,
   input [63:0]      startpc,
   output reg [63:0] currentpc,
   output [63:0]     MemtoRegOut,   // this should be attached to the output of the MemtoReg Mux
   input 	         CLK
   );

   // Next PC connections
   wire [63:0]      nextpc;         // The next PC, to be updated on clock cycle

   // Instruction Memory connections
   wire [31:0] 	  instruction;    // The current instruction

   // Parts of instruction
   wire [4:0] 		  rd;             // The destination register
   wire [4:0] 		  rm;             // Operand 1
   wire [4:0] 		  rn;             // Operand 2
   wire [10:0] 	  opcode;

   // Pipeline Registers
      /* Width 
         IF/ID:  32 Instructions, 64 PC
         ID/EX:  5 rd, 11 opcode, 64 signext, 64 readdataA, 64 readdataB, 64 PC
         EX/MEM: 5 rd, 64 readdataB, 64 ALUOut, 1 ALUZero, 64 NextPClogicALUADD,   
         MEM/WB: 5 rd, 64 ALUOut, 64 DataMEMReadData
      */
   reg [31:0] IF_ID_instruction_reg;
   reg [63:0] IF_ID_PC_reg;
   reg [4:0]  ID_EX_rd_reg;
   reg [10:0] ID_EX_opcode_reg;
   reg [63:0] ID_EX_signext_reg;
   reg [63:0] ID_EX_readdataA_reg;
   reg [63:0] ID_EX_readdataB_reg;
   reg [63:0] ID_EX_PC_reg;
   reg [4:0]  EX_MEM_rd_reg;
   reg [63:0] EX_MEM_readdataB_reg;
   reg [63:0] EX_MEM_ALUOut_reg;
   reg [0:0]  EX_MEM_ALUZero_reg;
   reg [63:0] EX_MEM_PC_reg;           // PC + signext << 2 
   reg [4:0]  MEM_WB_rd_reg;
   reg [63:0] MEM_WB_ALUOut_reg;
   reg [63:0] MEM_WB_DMReadData_reg;

   // Control Registers
      /* Signals
         IF/ID  | Reg2Loc, RegWrite,            Propogate{ALUOp, ALUSrc, Branch, MemWrite, MemRead, MemtoReg, RegWrite}
         ID/EX  | ALUOp, ALUSrc,                Propogate{Branch, MemWrite, MemRead, MemtoReg, RegWrite}
         EX/MEM | Branch, MemWrite, MemRead,    Propogate{MemtoReg, RegWrite}
         MEM/WB | MemtoReg, RegWrite
      */
   reg [3:0] ID_EX_aluctrl;
   reg [0:0] ID_EX_alusrc;
   reg [0:0] ID_EX_branch;
   reg [0:0] ID_EX_uncond_branch;
   reg [0:0] ID_EX_memwrite; 
   reg [0:0] ID_EX_memread;
   reg [0:0] ID_EX_mem2reg
   reg [0:0] ID_EX_regwrite;
   reg [0:0] EX_MEM_branch;
   reg [0:0] EX_MEM_uncond_branch;
   reg [0:0] EX_MEM_memwrite;
   reg [0:0] EX_MEM_memread;
   reg [0:0] EX_MEM_mem2reg;
   reg [0:0] EX_MEM_regwrite;
   reg [0:0] MEM_WB_mem2reg;
   reg [0:0] MEM_WB_regwrite;

   // Control wires
   wire 			     reg2loc;
   wire [2:0] 		  signop;
   wire 			     ID_regwrite;   
   wire 			     ID_alusrc;
   wire [3:0] 		  ID_aluctrl;
   wire 			     ID_mem2reg;
   wire 			     ID_memread;
   wire 			     ID_memwrite;
   wire 			     ID_branch;
   wire 			     ID_uncond_branch;       
   wire 			     alusrc;
   wire [3:0] 		  aluctrl;
   wire             EX_regwrite;
   wire 			     EX_mem2reg;
   wire 			     EX_memread;
   wire 			     EX_memwrite;
   wire 			     EX_branch;
   wire 			     EX_uncond_branch;
   wire 			     branch;
   wire 			     uncond_branch;
   wire 			     memread;
   wire 			     memwrite;
   wire             MEM_regwrite;
   wire 			     MEM_mem2reg;
   wire             regwrite;
   wire             mem2reg;

   // Register file connections
   wire [63:0] 	  regoutA;     // Output A
   wire [63:0] 	  regoutB;     // Output B

   // ALU connections
   wire [63:0] 	  aluout;
   wire 			     zero;
 
   // Sign Extender connections
   wire [63:0] 	  extimm;

   // PC update logic
   always @(negedge CLK) begin
      if (resetl)
         currentpc <= nextpc;
      else
         currentpc <= startpc;
   end

   // Parts of instruction
   assign rd = instruction[4:0];
   assign rm = instruction[9:5];
   assign rn = reg2loc ? instruction[4:0] : instruction[20:16];
   assign opcode = instruction[31:21];

   InstructionMemory imem(
			  .Data(instruction),
			  .Address(currentpc)
	);

   always @(negedge CLK) begin
      if (resetl)
         begin 
            IF_ID_instruction_reg <= 32'b0;
            IF_ID_PC_reg <= 64'b0;
         end
      else
         begin
            IF_ID_instruction_reg <= instruction;
            IF_ID_PC_reg <= currentpc;
         end
   end

   always @(negedge CLK) begin
      if (resetl)
         begin 
            ID_EX_regwrite <= 1'b0;
            ID_EX_mem2reg <= 1'b0;
            ID_EX_memread <= 1'b0;
            ID_EX_memwrite <= 1'b0;
            ID_EX_branch <= 1'b0;
            ID_EX_uncond_branch <= 1'b0;
            ID_EX_aluctrl <= 4'b0;
            ID_EX_alusrc <= 1'b0;
            ID_EX_PC_reg <= 64'b0;
         end
      else
         begin 
            ID_EX_regwrite <= ID_regwrite;
            ID_EX_mem2reg <= ID_mem2reg;
            ID_EX_memread <= ID_memread;
            ID_EX_memwrite <= ID_memwrite;
            ID_EX_branch <= ID_branch;
            ID_EX_uncond_branch <= ID_uncond_branch;
            ID_EX_aluctrl <= ID_aluctrl;
            ID_EX_alusrc <= ID_alusrc;

            ID_EX_rd_reg <= rd;
            ID_EX_opcode_reg <= opcode;
            ID_EX_signext_reg <= signext;
            ID_EX_readdataA_reg <= regoutA;
            ID_EX_readdataB_reg <= regoutB;
            ID_EX_PC_reg <= IF_ID_PC_reg;

            alusrc <= ID_EX_alusrc;
            aluctrl <= ID_EX_aluctrl;
         end
   end

   always @(negedge CLK) begin
      if (resetl)
         begin 
            EX_MEM_regwrite <= 1'b0;
            EX_MEM_mem2reg <= 1'b0;
            EX_MEM_memread <= 1'b0;
            EX_MEM_memwrite <= 1'b0;
            EX_MEM_branch <= 1'b0;
            EX_MEM_uncond_branch <= 1'b0;
         end
      else
         begin
            EX_MEM_regwrite <= ID_EX_regwrite;
            EX_MEM_mem2reg <= ID_EX_mem2reg;
            EX_MEM_memread <= ID_EX_memread;
            EX_MEM_memwrite <= ID_EX_memwrite; 
            EX_MEM_branch <= ID_EX_branch;
            EX_MEM_uncond_branch <= ID_EX_uncond_branch;

            EX_MEM_rd_reg <= ID_EX_rd_reg;
            EX_MEM_readdataB_reg <= ID_EX_readdataB_reg;
            EX_MEM_ALUOut_reg <= aluout;
            EX_MEM_ALUZero_reg <= zero;
            EX_MEM_PC_reg <= nextpc;

            branch <= EX_MEM_branch;
            uncond_branch <= EX_MEM_uncond_branch;
            memread <= EX_MEM_memread;
            memwrite <= EX_MEM_memread;
         end
   end

   always @(negedge CLK) begin
      if (resetl)
         begin 
            MEM_WB_regwrite <= 1'b0;
            MEM_WB_mem2reg <= 1'b0;
         end
      else
         begin
            MEM_WB_regwrite <= EX_MEM_regwrite;
            MEM_WB_mem2reg <= EX_MEM_mem2reg;
            regwrite <= MEM_WB_regwrite;
            mem2reg <= MEM_WB_mem2reg;
         end
   end

   control control(
		   .reg2loc(reg2loc),
		   .alusrc(ID_alusrc),
		   .mem2reg(ID_mem2reg),
		   .regwrite(regwrite),
		   .memread(ID_memread),
		   .memwrite(ID_memwrite),
		   .branch(ID_branch),
		   .uncond_branch(ID_uncond_branch),
		   .aluop(ID_aluctrl),
		   .signop(signop),
		   .opcode(opcode)  //******
	);

   /*
    * Connect the remaining datapath elements below.
    * Do not forget any additional multiplexers that may be required.
    */

    NextPClogic nextPCl(
       .CurrentPC(currentpc),
       .SignExtImm64(extimm),
       .Branch(branch),
       .ALUZero(zero),
       .Uncondbranch(uncond_branch),
       .NextPC(nextpc)
    );

    RegisterFile rf(
       .BusA(regoutA),
       .BusB(regoutB),
       .BusW(MemtoRegOut),
       .RA(rm),
       .RB(rn),
       .RW(rd),
       .RegWr(regwrite),
       .Clk(CLK)
    );

    SignExtender signext(
       .BusImm(extimm),
       .Imm26(instruction[25:0]),
       .Ctrl(signop)
    );

    wire[63:0]  aluBin; 
    assign aluBin = alusrc ? extimm : regoutB;      // Mux regfile to ALU(to data memory)
    ALU alu(
       .BusW(aluout),
       .BusA(regoutA),
       .BusB(aluBin),
       .ALUCtrl(aluctrl),
       .Zero(zero)
    );

    wire[63:0] readdata;    
    DataMemory datamemory(
       .WriteData(regoutB),
       .Address(aluout),
       .Clock(CLK),
       .MemoryRead(memread),
       .MemoryWrite(memwrite),
       .ReadData(readdata)
    );
    assign MemtoRegOut = mem2reg ? readdata : aluout;    // Mux data memory to regfile


endmodule
