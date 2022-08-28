module ccastles
(
	input         clk,
	input         reset_n,
	
	output        HBlank,
	output        HSync,
	output        VBlank,
	output        VSync,

	output  [8:0] video
);

	wire [8:0] hc;
	wire [7:0] vc;

   horsyncchan hsc
   (
      .CLK10(clk),
      .RESETn(reset_n),
      
      .HBLANK(HBlank),
      .HSYNC(HSync),
		.hcount(hc)

   );
   
   vertsyncchan vsc
   (
      .CLK10(clk),
      .RESETn(reset_n),

      .HBLANK(HBlank),
      .HSYNC(HSync),
		
		.VBLANK(VBlank),
		.VSYNC(VSync),
		.vcount(vc)
   );

   wire wd_reset_n;
   wire DCOKn = ~reset_n;
   watchdog wd
   (
      .WDIS(1'b1),
      .WDOGn(1'b1),
      .VBLANK(VBlank),
      .DCOKn(DCOKn),
      .WDRESETn(wd_reset_n)
   );

	assign video = hc[8:0];

endmodule
