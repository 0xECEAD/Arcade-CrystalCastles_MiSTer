module HorizontalScrolling
(
   input RESETn,
   input CLK10, CLK5,
   input HBLANK1n, VBLANK, HSLDn, PLAYER2,
   input [7:0] BD,
   
   output [7:0] HL  
);

wire w5P_5N;
wire en_n = ~HBLANK1n | VBLANK;
ls169 ic5P
(
   .clr_n(RESETn),
	.load_n(HSLDn),
   .clk(CLK10),
   .updwn(~PLAYER2),
   .p(BD[3:0]),
   .ent_n(CLK5), 
   .enp_n(en_n),
   .q(HL[3:0]),
   .rco_n(w5P_5N)
);
ls169 ic5N
(
   .clr_n(RESETn),
	.load_n(HSLDn),
   .clk(CLK10),
   .updwn(~PLAYER2),
   .p(BD[7:4]),
   .ent_n(w5P_5N), 
   .enp_n(en_n),
   .q(HL[7:4])
);

endmodule
