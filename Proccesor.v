module Proccesor(
	input 	          resetl,
	input 	          CLK,
	input [63:0]      startpc,
	output [63:0]     currentpc,
	output [63:0]     MemtoRegOut  
	);

	// fetch -> decode interim wires
	wire [31:0] instruction_decode;
	wire [63:0] pc_decode;

	// decode -> execute interim wires
	wire regwrite_execute, alusrc_execute;
	wire branch_execute, uncondbranch_execute;
	wire memread_execute, memwrite_execute, mem2reg_execute;
	wire [3:0] aluop_execute;
	wire [4:0] rd_execute;
	wire [63:0] regoutA_execute, regoutB_execute, signext_execute, pc_execute;

	// execute -> memory interim wires
	wire regwrite_memory, branch_memory, uncondbranch_memory, memread_memory;
	wire memwrite_memory, mem2reg_memory, aluzero_memory;
	wire [4:0] rd_memory;
	wire [63:0] regoutB_memory, aluout_memory, pctarget_memory;

	// memory -> fetch interim wires
	wire pcsrc_fetch;
	wire [63:0] pctarget_fetch;

	// memory -> writeback interim wires
	wire regwrite_writeback, mem2reg_writeback;
	wire [4:0] rd_writeback;
	wire [63:0] aluout_writeback, readdata_writeback;

	// writeback -> decode interim wires
	wire regwrite_decode;
	wire [4:0] rd_decode;
	wire [63:0] memtoregout_decode;

	InstructionFetch Fetch_Cycle(
		.clk(CLK),
		.resetl(resetl),
		.PCSrc(pcsrc_fetch),
		.TargetPC(pctarget_fetch),
		.StartPC(startpc),
		.instruction_ID(instruction_decode),
		.pc_ID(pc_decode)
	);

	InstructionDecode Decode_Cycle(
		.clk(CLK),
		.resetl(resetl),
		.RegWrite(regwrite_decode),
		.RD_ID(rd_decode),
		.instruction_ID(instruction_decode),
		.pc_ID(pc_decode),
		.MemtoRegOut_ID(memtoregout_decode),
		.RegWrite_EX(regwrite_execute),
		.ALUSrc_EX(alusrc_execute),
		.Branch_EX(branch_execute),
		.Uncondbranch_EX(uncondbranch_execute),
		.MemRead_EX(memread_execute),
		.MemWrite_EX(memwrite_execute),
		.Mem2Reg_EX(mem2reg_execute),
		.ALUOp_EX(aluop_execute),
		.RD_EX(rd_execute),
		.RegOutA_EX(regoutA_execute),
		.RegOutB_EX(regoutB_execute),
		.SignExtImm64_EX(signext_execute),
		.pc_EX(pc_execute)
	);

	Execute Execute_Cycle(
		.clk(CLK),
		.resetl(resetl),
		.RegWrite_EX(regwrite_execute),
		.ALUSrc_EX(alusrc_execute),
		.Branch_EX(branch_execute),
		.Uncondbranch_EX(uncondbranch_execute),
		.MemRead_EX(memread_execute),
		.MemWrite_EX(memwrite_execute),
		.Mem2Reg_EX(mem2reg_execute),
		.ALUOp_EX(aluop_execute),
		.RD_EX(rd_execute),
		.RegOutA_EX(regoutA_execute),
		.RegOutB_EX(regoutB_execute),
		.SignExtImm64_EX(signext_execute),
		.pc_EX(pc_execute),
		.RegWrite_MEM(regwrite_memory),
		.Branch_MEM(branch_memory),
		.Uncondbranch_MEM(uncondbranch_memory),
		.MemRead_MEM(memread_memory),
		.MemWrite_MEM(memwrite_memory),
		.Mem2Reg_MEM(mem2reg_memory),
		.ALUzero_MEM(aluzero_memory),
		.RD_MEM(rd_memory),
		.RegOutB_MEM(regoutB_memory),
		.ALUout_MEM(aluout_memory),
		.PCtarget_MEM(pctarget_memory)
	);

	Memory Memory_Cycle(
		.clk(CLK),
		.resetl(resetl),
		.ALUzero_MEM(aluzero_memory),
		.RegWrite_MEM(regwrite_memory),
		.Branch_MEM(branch_memory),
		.Uncondbranch_MEM(uncondbranch_memory),
		.MemRead_MEM(memread_memory),
		.MemWrite_MEM(memwrite_memory),
		.Mem2Reg_MEM(mem2reg_memory),
		.RD_MEM(rd_memory),
		.RegOutB_MEM(regoutB_memory),
		.ALUout_MEM(aluout_memory),
		.PCtarget_MEM(pctarget_memory),
		.PCSrc(pcsrc_fetch),
		.RegWrite_WB(regwrite_writeback),
		.Mem2Reg_WB(mem2reg_writeback),
		.RD_WB(rd_writeback),
		.ALUout_WB(aluout_writeback),
		.ReadData_WB(readdata_writeback),
		.PCtarget(pctarget_fetch)
	);

	Writeback Writeback_Cycle(
		.clk(CLK),
		.resetl(resetl),
		.Mem2Reg_WB(mem2reg_writeback),
		.RD_WB(rd_writeback),
		.RegWrite_WB(regwrite_writeback),
		.ALUout_WB(aluout_writeback),
		.ReadData_WB(readdata_writeback),
		.RegWrite_ID(regwrite_decode),
		.RD_ID(rd_decode),
		.MemtoRegOut_ID(memtoregout_decode)
	);

	assign currentpc = pc_decode;
	assign MemtoRegOut = memtoregout_decode;

endmodule