module SyncChain
(
   input clk, ce5,
   input reset_n,
   
   output reg HSYNC, 
   output VSYNC, VBLANK, HBLANK0,
   output reg HBLANK1, HBLANK2,
   output reg [8:0] hcount,
   output reg [7:0] vcount,
   
   output IRQCLK
);

always @(posedge clk or negedge reset_n)                 // ic's 7N 7M 7P 7R 7K 8J
begin
   if (~reset_n)
   begin
      hcount <= #1 9'b000000000;
      vcount <= #1 8'b00000000;
      HSYNC <= #1 1'b0;
      HBLANK1 <= #1 1'b0;
      HBLANK2 <= #1 1'b0;
   end
   else 
      if (ce5)
      begin
         hcount <= #1  hcount + 9'b000000001;
        
         if (hcount==320-1) begin hcount <= #1 9'b000000000; vcount <= #1 vcount + 8'b00000001; HSYNC <= #1 0; end

         if (hcount==272-1) HSYNC <= #1 1'b1;
         if (hcount==304-1) HSYNC <= #1 1'b0;

         if (hcount==260-1) begin HBLANK1 <= #1 1'b1; HBLANK2 <= #1 1'b1; end
         
         if (hcount==4-1)   HBLANK1 <= #1 1'b0;
         if (hcount==8-1)   HBLANK2 <= #1 1'b0;
      end
end

assign HBLANK0 = hcount[8];          // LO=0..255 HI=256..319
assign VBLANK = (~vcount[7] & ~vcount[6] & ~vcount[5] & ~vcount[4]) | (~vcount[7] & ~vcount[6] & ~vcount[5] & ~vcount[3]);             // HI=0..23    LO=24..255
assign VSYNC = (~vcount[7] & ~vcount[6] & ~vcount[5] & ~vcount[4] & ~vcount[3] & vcount[2] & ~vcount[1]) | (~vcount[7] & ~vcount[6] & ~vcount[5] & ~vcount[4] & ~vcount[3] & vcount[2] & ~vcount[0]);       // HI=4..6     LO=7..255/0..3
assign IRQCLK = ~vcount[5];       // every 64 lines (4x per frame)

endmodule