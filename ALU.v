`define AND   4'b0000
`define OR    4'b0001
`define ADD   4'b0010
`define SUB   4'b0110
`define PassB 4'b0111 


module ALU(BusW, Zero, BusA, BusB, ALUCtrl);
    output  [63:0] BusW;
    input   [63:0] BusA, BusB;
    input   [3:0] ALUCtrl;
    output  Zero;
    
    reg     [63:0] bus;
    
    always @(ALUCtrl or BusA or BusB) begin
        case(ALUCtrl)
            `AND: begin
                bus = BusA & BusB;
            end
            `OR: begin
                bus = BusA | BusB;
            end
            `ADD: begin
                bus = BusA + BusB;
            end
            `SUB: begin
                bus = BusA - BusB;
            end
            `PassB: begin
                bus = BusB;
            end      
        endcase
    end

    assign BusW = bus;
    assign Zero = BusW ? 0 : 1;
    
endmodule