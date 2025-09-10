module ProgramCounter(clk, resetl, currentpc, nextpc, startpc, pc_stall);
    input clk, resetl, pc_stall;
    input [63:0] nextpc, startpc;
    output [63:0] currentpc;
    
    reg [63:0] bus;
    always @(posedge clk or negedge resetl)   
    begin
        if (resetl) begin
            if (!pc_stall)
                bus <= nextpc;
        end
        else
            bus <= startpc;
    end

    assign currentpc = bus;

endmodule