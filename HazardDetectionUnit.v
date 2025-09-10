module HazardDetectionUnit(
    input [4:0] rm_ID, rn_ID,           
    input [4:0] rd_EX, rd_MEM,          
    input regwrite_EX, regwrite_MEM,    
    input memread_EX,                   
    output pc_stall,                    
    output id_bubble                    // Insert bubble (NOP) in ID/EX pipeline register
    );

    wire load_use_hazard;
    
    // Detect load-use data hazard (load in EX, use in ID)
    // Don't stall for writes to register 0
    assign load_use_hazard = memread_EX && ((rd_EX == rm_ID) || (rd_EX == rn_ID)) && (rd_EX != 5'b0);  
    
    // Stall pipeline when load-use hazard detected
    assign pc_stall = load_use_hazard;
    assign id_bubble = load_use_hazard;

endmodule