module NextPClogic(NextPC, CurrentPC, SignExtImm64, Branch, ALUZero, Uncondbranch); 
   input [63:0] CurrentPC, SignExtImm64; 
   input 	Branch, ALUZero, Uncondbranch; 
   output [63:0] NextPC; 

   reg[63:0] bus;
   always @(*) begin
      if (Uncondbranch) begin
         // Unconditional branch
         bus = CurrentPC + (SignExtImm64 << 2);
      end 
      else if (Branch && ALUZero) begin
         // Conditional branch and ALUZero is set
         bus = CurrentPC + (SignExtImm64 << 2);
      end 
      else begin
         // No branch, just increment by 4
         bus = CurrentPC + 4;
      end
   end

   assign NextPC = bus;

endmodule