module DynamicRam
(
   input clk, ce2Hd, ce5,
   input [14:0] DRBA,
   input DRAMn, BRWn, BITMDn, PIXA,
   
   input [7:0] BD,
   output [7:0] dram_to_cpu,

   input [7:0] hs,
   input [7:0] vs,
   input PLAYER2,
   output reg [3:0] BIT
);

wire [7:0] dout;
wire [7:0] bmw_to_dram = PIXA ? { BD[7:4], dout[3:0] } : { dout[7:4], BD[7:4]};
wire [7:0] data_to_dram = ~BITMDn ? bmw_to_dram : BD;

wire WE = ~DRAMn & ~BRWn & ce2Hd;

wire [14:0] addr = ce5 ? {vs,hs[7:1]} : DRBA;


dram #(.INIT_FILE("empty32k.ram")) ic4H4J4F4E
(
   .clk(clk),
   .we(WE),
   .addr(addr), 
   .din(data_to_dram),
   .dout(dout)
);

reg ce2Hd2;
reg [7:0] bmrd_to_cpu;
always @(posedge clk)
begin
   ce2Hd2 <= #1 ce2Hd;
   if (ce2Hd2) bmrd_to_cpu <= #1 { PIXA ? dout[7:4] : dout[3:0], 4'b000 };             // 0x0002
   if (ce5) BIT <= #1 hs[0] ? dout[7:4] : dout[3:0];
end

assign dram_to_cpu = ~BITMDn ? bmrd_to_cpu : dout;

endmodule