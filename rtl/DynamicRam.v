module DynamicRam
(
   input clk,
   input RASn, CASn, DRWR,
   input [7:0] DRAB,
   input DRLn, DRHn,
   input WP0n, WP1n, WP2n, WP3n,
   
   input [7:0] data_to_dram,
   output [7:0] data_from_dram,

   input PLAYER2, CLK5n,
   input [7:0] HL,
   output reg [3:0] BIT
);

wire [3:0] data_from_4H;
dram4416 #(.INIT_FILE("empty16k.ram")) ic4H
(
   .clk(clk),
   .rasn(RASn), .casn(CASn),
   .gn(DRWR), .wn(WP0n),
   .a(DRAB), 
   .din(data_to_dram[3:0]),
   .dout(data_from_4H)
);
wire [3:0] data_from_4J;
dram4416 #(.INIT_FILE("empty16k.ram")) ic4J
(
   .clk(clk),
   .rasn(RASn), .casn(CASn),
   .gn(DRWR), .wn(WP1n),
   .a(DRAB), 
   .din(data_to_dram[7:4]),
   .dout(data_from_4J)
);
wire [3:0] data_from_4F;
dram4416 #(.INIT_FILE("empty16k.ram")) ic4F
(
   .clk(clk),
   .rasn(RASn), .casn(CASn),
   .gn(DRWR), .wn(WP2n),
   .a(DRAB), 
   .din(data_to_dram[3:0]),
   .dout(data_from_4F)
);
wire [3:0] data_from_4E;
dram4416 #(.INIT_FILE("empty16k.ram")) ic4E
(
   .clk(clk),
   .rasn(RASn), .casn(CASn),
   .gn(DRWR), .wn(WP2n),
   .a(DRAB), 
   .din(data_to_dram[7:4]),
   .dout(data_from_4E)
);

wire [7:0] lo_byte = { data_from_4J, data_from_4H };
wire [7:0] hi_byte = { data_from_4E, data_from_4F };
assign data_from_dram = DRHn ? lo_byte : hi_byte;

wire clk2 = PLAYER2 ^ HL[1];

reg [7:0] ic5F_5J, ic5H_5J;
always @(posedge clk2)
begin
   ic5F_5J <= #1 hi_byte;
   ic5H_5J <= #1 lo_byte;
end

always @(posedge CLK5n)
begin
   if (HL[1])
      BIT <= #1 HL[0] ? ic5H_5J[7:4]  : ic5H_5J[3:0];
   else 
      BIT <= #1 HL[0] ? ic5F_5J[7:4]  : ic5F_5J[3:0];
end



endmodule