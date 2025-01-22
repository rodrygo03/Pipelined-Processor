module ProgramCounter(clk, resetl, currentpc, nextpc, startpc);
    input clk, resetl;
    input [63:0] nextpc, startpc;
    output [63:0] currentpc;
    
    reg [63:0] bus;
    always @(posedge clk or negedge resetl)   
    begin
        if (resetl)
            bus <= nextpc;
        else
            bus <= startpc;
    end

    assign currentpc = bus;

endmodule