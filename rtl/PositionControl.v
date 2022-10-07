module PositionControl
(
   input clk, ce, ce2Hd4,
   input PLAYER2,
   input [8:0] HC,
   input [7:0] VC,
   
   output LD1n,LD2n,
   output CL1n,CL2n,
   output SHFT0,SHFT1,
   output reg CK1, DIP2
);

always @(posedge clk)         // ic9E
begin
   if (ce2Hd4) CK1 <= #1 ~HC[2];
end

wire ic9H = HC[0] & ~HC[1];
wire ic9J = ~(ic9H & HC[2]);
assign LD2n = ~(~ic9J & ~VC[0]);          // ic9F
assign LD1n = ~(~ic9J & VC[0]);           // ic9F

assign SHFT0 = ~(~PLAYER2 & ~ic9H);       // ic9F
assign SHFT1 = ~(PLAYER2 & ~ic9H);        // ic9F

always @(posedge clk)         // ic10J
begin
   if (ce) 
   begin
      if (~LD2n) DIP2 <= #1 1'b1;
      else if (~LD1n) DIP2 <= #1 1'b0;
   end 
end

assign CL1n = ~(~LD2n & ~DIP2);           // ic10H
assign CL2n = ~(~LD1n & DIP2);            // ic10H

endmodule