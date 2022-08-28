// Horizontal Sync Chan
// CLK10 = 10MHz
// pixclk = 5MHz

// H1 = 2.5MHz
// H2 = 1.25 MHz        MOS6502 clock
// HBLANK = 5 / 320  => 15.625 kHz
// count 320 pixels, 256 visible



module horsyncchan(
   
   input CLK10,
   input RESETn,

   output HBLANK, HSYNC,
   output [8:0] hcount

);

   wire CLK5, CLK5n;
   wire HSYNCn;
   wire w7M_7N, w7L_8L, w8L_7M;
   wire H1n,H2,H4,H8;
   wire H16,H32,H64,H128;
   wire HBLANK1n, HBLANK2;

   
   assign hcount = {HBLANK,H128,H64,H32,H16,H8,H4,H2,~H1n};
   
   ls74 ic9Lb
   (
   	.n_pre(1'b1),
      .n_clr(RESETn),
      .clk(CLK10), 
      .d(CLK5n), 
      
      .q(CLK5),
      .n_q(CLK5n)
   );

   ls109 ic8Lb
   (
   	.n_pre(1'b1),
      .n_clr(RESETn),
      .clk(CLK10), 
      .j(CLK5), 
      .k_n(CLK5n), 
      
      .q(w8L_7M),
      .n_q(H1n)
   );

   ls163 ic7M
   (
      .n_load(1'b1),
      .n_clr(RESETn),
      .clk(CLK10),
      .p(4'b0000),   
      .ent(w8L_7M),
      .enp(CLK5),
      .q({H16,H8,H4,H2}),
      .rco(w7M_7N)   
   );

   ls160 ic7N
   (
      .n_load(1'b1),
      .n_clr(RESETn),
      .clk(CLK10),
      .p(4'b0000),   
      .ent(w7M_7N),
      .enp(CLK5),
      .q({HBLANK,H128,H64,H32})
   );

   ls74 ic7Lb
   (
   	.n_pre(HBLANK),
      .n_clr(RESETn),
      .clk(H16), 
      .d(H32),
      
      .q(HSYNCn),
      .n_q(HSYNC)
   );

   ls74 ic7La
   (
   	.n_pre(1'b1),
      .n_clr(RESETn),
      .clk(H4), 
      .d(HBLANK), 
      
      .q(w7L_8L),
      .n_q(HBLANK1n)
   );
   
   ls109 ic8La
   (
   	.n_pre(HBLANK1n),
      .n_clr(RESETn),
      .clk(~H4), 
      .j(w7L_8L), 
      .k_n(w7L_8L), 
      
      .q(HBLANK2)
   );
    
endmodule