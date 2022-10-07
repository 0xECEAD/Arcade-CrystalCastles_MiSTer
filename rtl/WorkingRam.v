module WorkingRam
(
   input clk, cm2H, ce2Hd5,
   input [15:0] BA,
   input SRAMn, BRWn,
   
   input [8:0] HC,
   input BUF1BUF2n,
   
   input [7:0] data_to_sram,
   output [7:0] data_from_sram,
   
   output [15:0] SR
);
   
wire [10:0] addr = cm2H ? BA[11:1] : {3'b111, BUF1BUF2n, HC[8:2]} ;

wire WE6B = ~SRAMn & ~BA[0] & ~BRWn & ce2Hd5;
wire WE6D = ~SRAMn & BA[0] & ~BRWn & ce2Hd5;

wire [7:0] data_from_6B, data_from_6D;
sram ic6B
(
   .clk(clk),
   .we(WE6B),
   .addr(addr), 
   .din(data_to_sram),
   .dout(data_from_6B)
);

sram ic6D
(
   .clk(clk),
   .we(WE6D),
   .addr(addr), 
   .din(data_to_sram),
   .dout(data_from_6D)
);

assign data_from_sram = BA[0] ? data_from_6D : data_from_6B;
assign SR = { data_from_6D , data_from_6B };

endmodule

