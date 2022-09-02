module DynamicRamControl
(
   input RESETn, 
   input CLK10, 
   input CLK5n,
   input H1n,
   
   output RASn, CASn, DEADSEL
);

   wire CLK10n = ~CLK10;
   wire w8H_7J = (~CLK5n & ~H1n);
   wire w7J_9L = w8H_7J | RASn;
   
   wire w9K_9L, w9L_9K;
   
   ls74 ic9La
   (
   	.pre_n(1'b1),
      .clr_n(w9K_9L),
      .clk(CLK10n), 
      .d(w7J_9L), 
      .q(RASn)
   );
   
   ls74 ic9Ka
   (
   	.pre_n(1'b1),
      .clr_n(RESETn),
      .clk(CLK10n), 
      .d(RASn), 
      .q(DEADSEL)
   );

   ls74 ic9Kb
   (
   	.pre_n(1'b1),
      .clr_n(RESETn),
      .clk(CLK10), 
      .d(DEADSEL), 
      .q(CASn),
      .q_n(w9K_9L)
   );
   

endmodule