// Horizontal Sync Chan
// CLK10 = 10MHz
// pixclk = 5MHz

// H1 = 2.5MHz
// H2 = 1.25 MHz        MOS6502 clock
// HBLANK = 5 / 320  => 15.625 kHz
// count 320 pixels, 256 visible



module HorSyncChan(
   
   input CLK10,
   input RESETn,

   output CLK5n,
   output HBLANK, HBLANK2, HSYNC, HBLANK1n,
   output [8:0] hcount

);

   wire CLK5;
   wire HSYNCn;
   wire w7M_7N, w7L_8L, w8L_7M;
   wire H1n,H2,H4,H8;
   wire H16,H32,H64,H128;

   assign hcount = {HBLANK,H128,H64,H32,H16,H8,H4,H2,~H1n};
   
   ls74 ic9Lb
   (
      .pre_n(1'b1),
      .clr_n(RESETn),
      .clk(CLK10), 
      .d(CLK5n), 
      
      .q(CLK5),
      .q_n(CLK5n)
   );

   ls109 ic8Lb
   (
      .pre_n(1'b1),
      .clr_n(RESETn),
      .clk(CLK10), 
      .j(CLK5), 
      .k_n(CLK5n), 
      
      .q(w8L_7M),
      .q_n(H1n)
   );

   ls163 ic7M
   (
      .load_n(1'b1),
      .clr_n(RESETn),
      .clk(CLK10),
      .p(4'b0000),   
      .ent(w8L_7M),
      .enp(CLK5),
      .q({H16,H8,H4,H2}),
      .rco(w7M_7N)   
   );

   ls160 ic7N
   (
      .load_n(1'b1),
      .clr_n(RESETn),
      .clk(CLK10),
      .p(4'b0000),   
      .ent(w7M_7N),
      .enp(CLK5),
      .q({HBLANK,H128,H64,H32})
   );

   ls74 ic7Lb
   (
      .pre_n(HBLANK),
      .clr_n(RESETn),
      .clk(H16), 
      .d(H32),
      
      .q(HSYNCn),
      .q_n(HSYNC)
   );

   ls74 ic7La
   (
      .pre_n(1'b1),
      .clr_n(RESETn),
      .clk(H4), 
      .d(HBLANK), 
      
      .q(w7L_8L),
      .q_n(HBLANK1n)
   );
   
   ls109 ic8La
   (
      .pre_n(HBLANK1n),
      .clr_n(RESETn),
      .clk(~H4), 
      .j(w7L_8L), 
      .k_n(w7L_8L), 
      
      .q(HBLANK2)
   );
    
endmodule