// Vertical Sync Chan
// counts HBLANK's

// HBLANK = 15.625 kHz
// V1 = 7812.5 Hz
// V2 = 3906.25 MHz        MOS6502 clock
// VBLANK = 15625 / 256  =>  61.03 Hz
// count 256 lines,    233 visible


module vertsyncchan(
   
   input CLK10,
   input RESETn,

   input HBLANK,HSYNC,

   output VBLANK, VSYNC, IRQCK,
   output [7:0] vcount
);

   wire w7P_7R;
   wire V1,V2,V4,V8;
   wire V16,V32,V64,V128;
   wire HBLANKn;
   wire IRQCLK,VBLANKn;
   wire w8J_8F;
   wire [3:0] w7K_8J;
   wire dmy0,dmy1,dmy2;

   assign HBLANKn = ~HBLANK;
   assign vcount = {V128,V64,V32,V16,V8,V4,V2,V1};
   
   ls163 ic7P
   (
      .n_load(1'b1),
      .n_clr(RESETn),
      .clk(HBLANKn),
      .p(4'b0000),   
      .ent(1'b1),
      .enp(1'b1),
      .q({V8,V4,V2,V1}),
      .rco(w7P_7R)   
   );

   ls163 ic7R
   (
      .n_load(1'b1),
      .n_clr(RESETn),
      .clk(HBLANKn),
      .p(4'b0000),   
      .ent(w7P_7R),
      .enp(w7P_7R),
      .q({V128,V64,V32,V16})
   );

   rom82S129 ic7K
   (
      .clk(CLK10),
      .addr(vcount),
      .en(1'b1),
      .data(w7K_8J)
   );

   ls175 ic9Lb
   (
      .n_clr(RESETn),
      .clk(HBLANKn), 
      .d(w7K_8J), 
      
      .q({IRQCK,dmy0,w8J_8F,VBLANK}),
      .n_q({dmy1,dmy2,VSYNC,VBLANKn})
   );

   //assign COMPSYNCn = HSYNC ^ w8J_8F;
   
endmodule