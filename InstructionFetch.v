module InstructionFetch(
    input clk, resetl, PCSrc, pc_stall,
    input [63:0] TargetPC, StartPC,
    input branch_taken_MEM,
    input [63:0] pc_MEM,
    output [31:0] instruction_ID,
    output [63:0] pc_ID
    );

    // Interim Registers
    reg  [63:0] pc_IF_reg;
    reg  [31:0] instruction_IF_reg;

    // Interim Wires
    wire [63:0] NextPC, PC_IF, PredictedPC;
    wire [31:0] instruction_IF;
    wire branch_predict;

    BranchPredictor bp(
        .clk(clk),
        .resetl(resetl),
        .pc_IF(PC_IF),
        .branch_taken_MEM(branch_taken_MEM),
        .pc_MEM(pc_MEM),
        .branch_predict(branch_predict)
    );

    assign PredictedPC = branch_predict ? PC_IF + 4 : PC_IF + 4;
    assign NextPC = PCSrc ? TargetPC : PredictedPC;
    ProgramCounter PC(
        .clk(clk),
        .resetl(resetl),
        .currentpc(PC_IF),
        .nextpc(NextPC),
        .startpc(StartPC),
        .pc_stall(pc_stall)
    );

    InstructionMemory IMEM(
        .Data(instruction_IF),
        .Address(PC_IF)
    );


    always @(posedge clk or negedge resetl) 
    begin
        if (resetl) begin
            if (!pc_stall) begin
                instruction_IF_reg <= instruction_IF;
                pc_IF_reg <= PC_IF;
            end
        end
        else begin
            instruction_IF_reg <= 32'b0;
            pc_IF_reg <= 64'b0;
        end
    end

    assign instruction_ID = instruction_IF_reg;
    assign pc_ID = pc_IF_reg;

endmodule