module MotionObjectHorizontalControl
(
   input clk, ce5,
   input [15:0] SR,
   input LD1n, LD2n, CL1n, CL2n,
   output reg [7:0] addr1, addr2
);

always @(posedge clk)         // ic10F, ic10E
begin
   if (~LD2n & ce5) 
      addr2 <= #1 SR[15:8];
   else if (~CL2n & ce5) 
      addr2 <= #1 8'd0;
   else if (ce5) 
      addr2 <= #1 addr2 + 8'b00000001;
end


always @(posedge clk)         // ic10D, ic10C
begin
   if (~LD1n & ce5) 
      addr1 <= #1 SR[15:8];
   else if (~CL1n & ce5) 
      addr1 <= #1 8'd0;
   else if (ce5) 
      addr1 <= #1 addr1 + 8'b00000001;
end

endmodule