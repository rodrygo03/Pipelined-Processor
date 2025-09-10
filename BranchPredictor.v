module BranchPredictor(
    input clk, resetl,
    input [63:0] pc_IF,
    input branch_taken_MEM,
    input [63:0] pc_MEM,
    output branch_predict
    );

    // 2-bit saturating counter 
    // 00 (strong not taken) <-> 01 (weak not taken) <-> 10 (weak taken) <-> 11 (strong taken)
    reg [1:0] predictor_state;
    
    always @(posedge clk or negedge resetl) begin
        if (!resetl) begin
            predictor_state <= 2'b01;
        end else if (pc_MEM == pc_IF) begin
            case (predictor_state)
                2'b00: predictor_state <= branch_taken_MEM ? 2'b01 : 2'b00;
                2'b01: predictor_state <= branch_taken_MEM ? 2'b10 : 2'b00;
                2'b10: predictor_state <= branch_taken_MEM ? 2'b11 : 2'b01;
                2'b11: predictor_state <= branch_taken_MEM ? 2'b11 : 2'b10;
            endcase
        end
    end
    
    assign branch_predict = predictor_state[1];

endmodule