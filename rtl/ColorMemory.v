module ColorMemory
(
   input   CLK10,
   input   CLK5n,
      
   input CRAMn,
   input [7:0] BD,
   input [5:0] BA,
      
   input MPI, MV0, MV1, MV2,
   input BIT0, BIT1, BIT2, BIT3,
   
   output [8:0] o
);

wire we_n = ~(~CRAMn & ~CLK5n);
wire w10K_10L10M, w10K_10R;
wire w10M_10Ra, w10M_10Rb;
wire w10L_10Ra, w10L_10Rb;

cram82S09 ic10R
 (
   .clk(CLK10),
   .ce_n(1'b0), .we_n(we_n),
   .addr(addr),
   .din( {BA[5], BD} ),
   .dout(o)
);

ls153 ic10Mb
(
   .A(w10K_10L10M),
   .B(CRAMn),
   .C3(MPI),
   .C2(BIT3),
   .C1(BA[3]),
   .C0(BA[3]),
   .Y(w10M_10Rb)
);
ls153 ic10Ma
(
   .A(w10K_10L10M),
   .B(CRAMn),
   .C3(MV2),
   .C2(BIT2),
   .C1(BA[2]),
   .C0(BA[2]),
   .Y(w10M_10Ra)
);

ls153 ic10Lb
(
   .A(w10K_10L10M),
   .B(CRAMn),
   .C3(MV1),
   .C2(BIT1),
   .C1(BA[1]),
   .C0(BA[1]),
   .Y(w10L_10Rb)
);
ls153 ic10La
(
   .A(w10K_10L10M),
   .B(CRAMn),
   .C3(MV0),
   .C2(BIT0),
   .C1(BA[0]),
   .C0(BA[0]),
   .Y(w10L_10Ra)
);

wire dmy1,dmy0;
wire [5:0] addr = { 1'b0, w10K_10R, w10M_10Rb, w10M_10Ra, w10L_10Rb, w10L_10Ra };

rom82S129 #(.INIT_FILE("82s129-136022-111.10k.rom")) ic10K
(
   .clk(CLK10),
   .A({1'b0, CRAMn, BA[4], MV2, MV1, MV0, MPI, BIT3 }),
   .CE_n(1'b0),
   .O({dmy1, dmy0, w10K_10L10M, w10K_10R})
);
endmodule