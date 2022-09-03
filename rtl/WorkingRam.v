module WorkingRam
(
   input clk,
   input SRAMn, BRWn, B2H, WRITEn, 
   input [15:0] BA,
   input [8:0] hcount,
   input BUF1BUF2n,
   
   input [7:0] data_to_sram,
   output [7:0] data_from_sram  
);
   
wire [3:0] ic6H = B2H ? { SRAMn, BA[11:9] } : 4'b1111;
wire [3:0] ic6F = B2H ? BA[8:5] : {BUF1BUF2n,hcount[8:6]};
wire [3:0] ic6E = B2H ? BA[4:1] : hcount[5:2];
wire [10:0] addr = { ic6H[2:0], ic6F, ic6E };
wire w7H_6B6D = ~ic6H[3] & ~BRWn;
wire SRHn = ~( ~BA[0] & ~ic6H[3] );
wire SRHWn = ~( ~SRHn & ~WRITEn ); 
wire SRLn = ~( BA[0] & ~ic6H[3] );
wire SRLWn = ~( ~SRLn & ~WRITEn ); 

wire [7:0] data_from_6B, data_from_6D;

sram6116 ic6B
(
   .clk(clk),
   .we_n(SRLWn),
   .addr(addr), 
   .din(data_to_sram),
   .dout(data_from_6B)
);

sram6116 ic6D
(
   .clk(clk),
   .we_n(SRHWn),
   .addr(addr), 
   .din(data_to_sram),
   .dout(data_from_6D)
);

assign data_from_sram = SRHn ? data_from_6B : data_from_6D;

endmodule

