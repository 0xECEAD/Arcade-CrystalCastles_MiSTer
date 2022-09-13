module AutoIncrement
(
   input RESETn,
   input XCOORDn, XINCn, AXn, 
   input YCOORDn, YINCn, AYn, 
   input BITMDn, Bphi2,
   input [7:0] BD,
   input [15:0] BA,
   
   output [14:1] DRBA,
   output PIXA, PIXB
);

wire w3P_3N, w2P_3P3N3M3L, w3M_3L;
wire [1:0] w3P_2P;
wire [3:0] w3N_2N, w3M_2M, w3L_2L;

ls191 ic3P
(
   .clear_n(RESETn),
   .load_n(XCOORDn),
   .dwnup_n(XINCn),
   .g_n(AXn), 
   .clk(~w2P_3P3N3M3L),
   .p(BD[3:0]),  
   .q({w3P_2P, PIXB, PIXA}),
   .rco_n(w3P_3N)
);
ls191 ic3N
(
   .clear_n(RESETn),
   .load_n(XCOORDn),
   .dwnup_n(XINCn),
   .g_n(w3P_3N), 
   .clk(~w2P_3P3N3M3L),
   .p(BD[7:4]),  
   .q(w3N_2N)
);
ls191 ic3M
(
   .clear_n(RESETn),
   .load_n(YCOORDn),
   .dwnup_n(YINCn),
   .g_n(AYn), 
   .clk(~w2P_3P3N3M3L),
   .p(BD[3:0]),  
   .q(w3M_2M),
   .rco_n(w3M_3L)
);
ls191 ic3L
(
   .clear_n(RESETn),
   .load_n(YCOORDn),
   .dwnup_n(YINCn),
   .g_n(w3M_3L), 
   .clk(~w2P_3P3N3M3L),
   .p(BD[7:4]),  
   .q(w3L_2L)
);

wire dmy;
ls157 ic2P
(
   .a({w3P_2P, Bphi2, 1'b0}),
   .b({BA[2],BA[1], 1'b0, 1'b0}),
   .g_n(1'b0), .sel(BITMDn),
   .y({DRBA[2], DRBA[1], w2P_3P3N3M3L, dmy})
); 
ls157 ic2N
(
   .a(w3N_2N),
   .b(BA[6:3]),
   .g_n(1'b0), .sel(BITMDn),
   .y(DRBA[6:3])
); 
ls157 ic2M
(
   .a(w3M_2M),
   .b(BA[10:7]),
   .g_n(1'b0), .sel(BITMDn),
   .y(DRBA[10:7])
); 
ls157 ic2L
(
   .a(w3L_2L),
   .b(BA[14:11]),
   .g_n(1'b0), .sel(BITMDn),
   .y(DRBA[14:11])
); 

endmodule