// Timing:
//
// Note: synchronous memory: read data follows address in next clock cycle
//
//    ce5    ce2H  ce2Hd ce2Hd2  ce2Hd3       |  addr
                                           
// 0   0       0     1     0       0          |  cpu/bm         BIT <= vmem lo
// 1   1       0     0     1       0          |  vs/hs          cpu_read <= dout
// 2   0       0     0     0       1          |  cpu/bm         BIT <= vmem hi          if(write)   WE=1, data_to_dram = BD or BMR_TO_DRAM
// 3   1       0     0     0       0          |  vs/hs          
// 4   0       0     0     0       0          |  cpu/bm         BIT <= vmem lo
// 5   1       0     0     0       0          |  vs/hs
// 6   0       0     0     0       0          |  cpu/bm         BIT <= vmem hi
// 7   1       1     0     0       0          |  vs/hs
//    
// 
// 
// 






module DynamicRam
(
   input clk, ce5, ce2Hd2, ce2Hd3,
   input [14:0] DRBA,
   input DRAMn, BRWn, BITMDn, PIXA,
   
   input [7:0] BD,
   output [7:0] dram_to_cpu,

   input [7:0] hs,
   input [7:0] vs,
   output reg [3:0] BIT
);

wire [7:0] bmw_to_dram = PIXA ? { BD[7:4], cpu_read[3:0] } : { cpu_read[7:4], BD[7:4]};
wire [7:0] data_to_dram = ~BITMDn ? bmw_to_dram : BD;

wire WE = ~BRWn & ce2Hd3 & ((BITMDn & ~DRAMn) | (~BITMDn & DRBA[14:12] != 3'b000));

wire [14:0] addr = ce5 ? {vs,hs[7:1]} : DRBA;

wire [7:0] dout;
dram ic4H4J4F4E
(
   .clk(clk),
   .we(WE),
   .addr(addr), 
   .din(data_to_dram),
   .dout(dout)
);

reg [7:0] cpu_read;
always @(posedge clk)
begin
   if (ce2Hd2) cpu_read <= #1 dout; 
   if (~ce5) BIT <= #1 hs[0] ? dout[3:0] : dout[7:4];
end

assign dram_to_cpu = ~BITMDn ? { PIXA ? cpu_read[7:4] : cpu_read[3:0], 4'b000 } : cpu_read;

endmodule