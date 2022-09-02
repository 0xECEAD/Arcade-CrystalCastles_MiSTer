module BitModeDecoder
(
   input [15:0] BA,
   input WRphi2n,
   output BITWRn, BITMDn, YCOORDn, XCOORDn
);

wire g_n = ~(BA[15:2] == 14'b0000000000);
wire [3:0] y;
ls139 ic2A
(
   .a(BA[0]),
   .b(BA[1]),
   .g_n(g_n),
   .y(y)
);

assign BITWRn = ~(~WRphi2n & ~y[3]);
assign BITMDn = y[2];
assign YCOORDn = ~(~WRphi2n & ~y[1]);
assign XCOORDn = ~(~WRphi2n & ~y[0]);

endmodule
