module InstructionFetch(
    input clk, resetl, PCSrc,
    input [63:0] TargetPC, StartPC,
    output [31:0] instruction_ID,
    output [63:0] pc_ID
    );

    wire [63:0] NextPC, PC_IF;
    wire [31:0] instruction_IF;

    reg  [63:0] pc_IF_reg;
    reg  [31:0] instruction_IF_reg;

    assign NextPC = PCSrc ? TargetPC : PC_IF + 4;

    ProgramCounter PC(
        .clk(clk),
        .resetl(resetl),
        .currentpc(PC_IF),
        .nextpc(NextPC),
        .startpc(StartPC)
    );

    InstructionMemory IMEM(
        .Data(instruction_IF),
        .Address(PC_IF)
    );

    always @(posedge clk or negedge resetl) 
    begin
        if (resetl) begin
            instruction_IF_reg <= instruction_IF;
            pc_IF_reg <= PC_IF;
        end
        else begin
            instruction_IF_reg <= 32'b0;
            pc_IF_reg <= 64'b0;
        end
    end

    assign instruction_ID = instruction_IF_reg;
    assign pc_ID = pc_IF_reg;

endmodule