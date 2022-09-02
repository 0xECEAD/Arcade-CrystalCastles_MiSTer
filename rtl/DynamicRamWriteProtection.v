module DynamicRamWriteProtection
(
   input clk, CLK5n,
   input [15:0] BA,
   input [14:1] DRBA,
   input BITMDn, PIXA, PIXB, WRITEn,
   
   output WP0n, WP1n, WP2n, WP3n  
);

   wire [3:0] data;
   wire BA1520 = ~BA[15] & ~DRBA[14] & ~DRBA[13] & ~DRBA[12];
   rom82S129 #(.INIT_FILE("82s129-136022-110.11l.rom")) ic11L
   (
      .clk(clk),
      .A({BA1520, DRBA[11], DRBA[10], BITMDn, 1'b0, BA[0], PIXB, PIXA }),
      .CE_n(1'b0),
      .O(data)
   );

   wire w11M_11K;
   ls74 ic11Mb
   (
   	.pre_n(1'b1),
      .clr_n(~BA[15] & ~WRITEn),
      .clk(~clk), 
      .d(CLK5n), 
      .q_n(w11M_11K)
   );

   assign WP0n = ~(~data[0] & ~w11M_11K);
   assign WP1n = ~(~data[1] & ~w11M_11K);
   assign WP2n = ~(~data[2] & ~w11M_11K);
   assign WP3n = ~(~data[3] & ~w11M_11K);

endmodule