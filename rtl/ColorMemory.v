module ColorMemory
(
   input   clk, ce5,
      
   input CRAMn,
   input [7:0] BD,
   input [5:0] BA,
      
   input MPI,
   input [2:0] MV,
   input [3:0] BIT,
   
   output [8:0] o
);

wire sel = (~MV[2] & ~MV[1] & ~MV[0]) | (~MV[2] & ~MPI) | (~MV[2] & ~BIT[3]) | (~MV[1] & ~MPI) | (~MV[1] & ~BIT[3]) | (~MV[0] & ~MPI) | (~MV[0] & ~BIT[3]);
wire A4 = (MV[0] & MPI & BIT[3]) | (MV[1] & MPI & BIT[3]) | (MV[2] & MPI & BIT[3]) | (MV[2] & MV[1] & MV[0]);
wire A3 = sel ? MPI : BIT[3];
wire A2 = sel ? MV[2] : BIT[2];
wire A1 = sel ? MV[1] : BIT[1];
wire A0 = sel ? MV[0] : BIT[0];
wire [4:0] addr = CRAMn ? { A4, A3, A2, A1, A0 } : BA[4:0];
wire [8:0] rbg;

cram82S09 ic10R
 (
   .clk(clk),
   .we(~CRAMn),
   .addr(addr),
   .din( {BA[5], BD} ),
   .dout(rbg)
);

assign o = { ~rbg[8:6], ~rbg[2:0], ~rbg[5:3] };

endmodule