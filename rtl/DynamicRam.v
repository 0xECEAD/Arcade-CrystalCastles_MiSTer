module DynamicRam
(
   input clk,
   input RASn, CASn, DRWR,
   input [7:0] DRAB,
   input DRLn, DRHn,
   input WP0n, WP1n, WP2n, WP3n,
   
   input [7:0] data_to_dram,
   output [7:0] data_from_dram,
   
   output BIT2, BIT1, BIT0
);

wire [3:0] data_from_4H;
dram4416 ic4H
(
   .clk(clk),
   .rasn(RASn), .casn(CASn),
   .gn(DRWR), .wn(WP0n),
   .a(DRAB), 
   .din(data_to_dram[3:0]),
   .dout(data_from_4H)
);
wire [3:0] data_from_4J;
dram4416 ic4J
(
   .clk(clk),
   .rasn(RASn), .casn(CASn),
   .gn(DRWR), .wn(WP1n),
   .a(DRAB), 
   .din(data_to_dram[7:4]),
   .dout(data_from_4J)
);
wire [3:0] data_from_4F;
dram4416 ic4F
(
   .clk(clk),
   .rasn(RASn), .casn(CASn),
   .gn(DRWR), .wn(WP2n),
   .a(DRAB), 
   .din(data_to_dram[3:0]),
   .dout(data_from_4F)
);
wire [3:0] data_from_4E;
dram4416 ic4E
(
   .clk(clk),
   .rasn(RASn), .casn(CASn),
   .gn(DRWR), .wn(WP2n),
   .a(DRAB), 
   .din(data_to_dram[7:4]),
   .dout(data_from_4E)
);

assign data_from_dram = DRHn ? { data_from_4J, data_from_4H } : { data_from_4E, data_from_4F };

endmodule