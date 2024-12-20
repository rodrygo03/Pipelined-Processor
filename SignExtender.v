`define BTYPE   3'b000
`define CBZTYPE 3'b001
`define ITYPE   3'b010
`define DTYPE   3'b011
`define IWTYPE  3'b100      // MOVZ type according to green sheet is IW type


module SignExtender(BusImm, Imm26, Ctrl); 
    output [63:0] BusImm; 
    input  [25:0] Imm26; 
    input  [2:0]	 Ctrl; 
   
    reg [63:0] result;

	always @(*) begin
		case(Ctrl)
            `BTYPE: begin    
                result = {{36{Imm26[25]}}, Imm26};                   
            end
            `CBZTYPE: begin    
                result = {{43{Imm26[23]}}, Imm26[23:5]};
            end
            `ITYPE: begin    
                result = {52'b0, Imm26[21:10]}; 
            end
            `DTYPE: begin    
                result = {{55{Imm26[20]}}, Imm26[20:12]}; 
            end
            `IWTYPE: begin   
                result = {{48'b0, Imm26[20:5]} << (Imm26[22:21] * 16)};
            end
            default: begin	// invalid type
                result = 64'b0;
            end
		endcase
    end 

    assign BusImm = result;

endmodule