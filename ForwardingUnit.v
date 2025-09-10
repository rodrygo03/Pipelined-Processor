module ForwardingUnit(
    input [4:0] rm_EX, rn_EX,           
    input [4:0] rd_MEM, rd_WB,          
    input regwrite_MEM, regwrite_WB,    
    output [1:0] forward_A,             
    output [1:0] forward_B              
    );

    assign forward_A = (regwrite_MEM && (rd_MEM != 5'b0) && (rd_MEM == rm_EX)) ? 2'b10 :
                       (regwrite_WB && (rd_WB != 5'b0) && (rd_WB == rm_EX)) ? 2'b01 :
                       2'b00;

    assign forward_B = (regwrite_MEM && (rd_MEM != 5'b0) && (rd_MEM == rn_EX)) ? 2'b10 :
                       (regwrite_WB && (rd_WB != 5'b0) && (rd_WB == rn_EX)) ? 2'b01 :
                       2'b00;

endmodule