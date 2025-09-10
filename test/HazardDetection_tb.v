module HazardDetection_tb;
    reg [4:0] rm_ID, rn_ID, rd_EX, rd_MEM;
    reg regwrite_EX, regwrite_MEM, memread_EX;
    wire pc_stall, id_bubble;
    
    HazardDetectionUnit uut(
        .rm_ID(rm_ID),
        .rn_ID(rn_ID),
        .rd_EX(rd_EX),
        .rd_MEM(rd_MEM),
        .regwrite_EX(regwrite_EX),
        .regwrite_MEM(regwrite_MEM),
        .memread_EX(memread_EX),
        .pc_stall(pc_stall),
        .id_bubble(id_bubble)
    );
    
    initial begin
        rm_ID = 5'd1; rn_ID = 5'd2; rd_EX = 5'd3; rd_MEM = 5'd4;
        regwrite_EX = 1'b0; regwrite_MEM = 1'b0; memread_EX = 1'b0;
        #10;
        
        memread_EX = 1'b1; rd_EX = 5'd1;
        #10;
        if (pc_stall && id_bubble) $display("PASS: Load-use hazard detected");
        else $display("FAIL: Load-use hazard not detected");
        
        rd_EX = 5'd0;
        #10;
        if (!pc_stall && !id_bubble) $display("PASS: No hazard for register 0");
        else $display("FAIL: False hazard for register 0");
        
        $finish;
    end
endmodule