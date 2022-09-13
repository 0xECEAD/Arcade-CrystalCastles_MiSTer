// Vertical Sync Chan
// counts HBLANK's

// HBLANK = 15.625 kHz
// V1 = 7812.5 Hz
// V2 = 3906.25 MHz        MOS6502 clock
// VBLANK = 15625 / 256  =>  61.03 Hz
// count 256 lines,    233 visible


module VertSyncChan(
   
   input CLK10,
   input RESETn,

   input HBLANK,HSYNC,HBLANK1n,

   output VBLANK, VSYNC, IRQCK,
   output [7:0] vcount
);

   wire w7P_7R;
   wire V1,V2,V4,V8;
   wire V16,V32,V64,V128;
   wire HBLANKn, VBLANKn;
   wire w8J_8F;
   wire [3:0] w7K_8J;
   wire dmy0,dmy1,dmy2;

   assign HBLANKn = ~HBLANK;
   assign vcount = {V128,V64,V32,V16,V8,V4,V2,V1};
   
   //wire VBLANK_TEST = (~vcount[7] & ~vcount[6] & ~vcount[5] & ~vcount[4]) | (~vcount[7] & ~vcount[6] & ~vcount[5] & ~vcount[3]);             // 
   //wire VSYNC_TEST = (~vcount[7] & ~vcount[6] & ~vcount[5] & ~vcount[4] & ~vcount[3] & vcount[2] & ~vcount[1]) | (~vcount[7] & ~vcount[6] & ~vcount[5] & ~vcount[4] & ~vcount[3] & vcount[2] & ~vcount[0]);
   //wire IRQCL_TEST = (~vcount[5]);
   
   ls163 ic7P
   (
      .load_n(1'b1),
      .clr_n(RESETn),
      .clk(HBLANKn),
      .p(4'b0000),   
      .ent(1'b1),
      .enp(1'b1),
      .q({V8,V4,V2,V1}),
      .rco(w7P_7R)   
   );

   ls163 ic7R
   (
      .load_n(1'b1),
      .clr_n(RESETn),
      .clk(HBLANKn),
      .p(4'b0000),   
      .ent(w7P_7R),
      .enp(w7P_7R),
      .q({V128,V64,V32,V16})
   );

   rom82S129 #(.INIT_FILE("82s129-136022-108.7k.rom")) ic7K
   (
      .clk(CLK10),
      .A(vcount),
      .CE_n(1'b0),
      .O(w7K_8J)
   );

   ls175 ic9Lb
   (
      .clr_n(RESETn),
      .clk(HBLANK1n),            // in schematic its HBLANKn but that does not exist?
      .d(w7K_8J), 
      
      .q({IRQCK,dmy0,w8J_8F,VBLANK}),
      .q_n({dmy1,dmy2,VSYNC,VBLANKn})
   );

   //assign COMPSYNCn = HSYNC ^ w8J_8F;
   
endmodule