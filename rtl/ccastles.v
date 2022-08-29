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
   
	wire IRQCK;
   vertsyncchan vsc
   (
      .CLK10(clk),
      .RESETn(reset_n),

      .HBLANK(HBlank),
      .HSYNC(HSync),
		
		.VBLANK(VBlank),
		.VSYNC(VSync),
      .IRQCK(IRQCK),
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

   wire H2 = reset_n ? hc[1] : clk;    // need cylces for reset?
   wire [15:0] adress;
   wire [7:0] data_from_progmem;
   reg [7:0] data_to_cpu;

   wire ROM2 = adress[15:13] == 3'b111;
   
   always @(posedge H2) 
   begin
      if (ROM2 == 1'b1) 
         data_to_cpu <= #1 data_from_progmem;
   end

   
   microprocessor cpu
   (
      .clk(H2),        // runs on 2H
      .RESETn(reset_n),
      .INTACKn(1'b1),      // TODO
      .IRQCK(IRQCK),
      
      .data_to_cpu(data_to_cpu),
      .data_from_cpu(),
      .adressbus(adress),
      .RWn()
   );
   
   programmemory progmem
   (
      .clk(clk),
      .adress(adress[12:0]),
      .rom2_n(~ROM2),
      .data(data_from_progmem)
   );

	assign video = adress[8:0];

endmodule
