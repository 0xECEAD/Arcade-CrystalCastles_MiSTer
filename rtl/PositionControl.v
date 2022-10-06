module PositionControl
(
   input PLAYER2, CLK5n,
   input [8:0] HC,
   input [7:0] VC,
   
   output LD1n,LD2n,
   output CL1n,CL2n,
   output SHFT0,SHFT1,
   output CK1, DIP2
);

ls74 ic9E
(
   .pre_n(1'b1),
   .clr_n(1'b1),
   .clk(HC[1]),      // 2H
   .d(HC[2]),        // 4H
   .q(),             // CK1n
   .q_n(CK1)
);

wire ic9H = HC[0] & ~HC[1];
wire ic9J = ~(ic9H & HC[2]);
assign LD2n = ~(~ic9J & ~VC[0]);          // ic9F
assign LD1n = ~(~ic9J & VC[0]);           // ic9F

assign SHFT0 = ~(~PLAYER2 & ~ic9H);       // ic9F
assign SHFT1 = ~(PLAYER2 & ~ic9H);        // ic9F

ls109 ic10J
(
   .pre_n(1'b1),
   .clr_n(1'b1),
   .clk(CLK5n), 
   .j(~LD2n), 
   .k_n(LD1n), 
  
   .q(DIP2),
   .q_n()      // DIP2n
);

assign CL1n = ~(~LD2n & ~DIP2);           // ic10H
assign CL2n = ~(~LD1n & DIP2);            // ic10H

endmodule