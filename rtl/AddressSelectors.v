//              A = DEADSEL         B = B2H         
//              
//                 |       CPU            |          VIDEO              |
//              
//                  8b            6b          8b                6b
//                  RASn          CASn        RASn              CASn
//                  ROW           COL         ROW               COL
//                  1 1           1 0         0 1               0 0
//           
//  DRAB[7]         DRBA[8]       0           w3K_4LMNP[1]      0               
//  DRAB[6]         DRBA[7]       DRBA[14]    w3K_4LMNP[0]      w3K_4LMNP[7]      
//  DRAB[5]         DRBA[6]       DRBA[13]    HL[7]             w3K_4LMNP[6]         
//  DRAB[4]         DRBA[5]       DRBA[12]    HL[6]             w3K_4LMNP[5]         
//  DRAB[3]         DRBA[4]       DRBA[11]    HL[5]             w3K_4LMNP[4]         
//  DRAB[2]         DRBA[3]       DRBA[10]    HL[4]             w3K_4LMNP[3]         
//  DRAB[1]         DRBA[2]       DRBA[9]     HL[3]             w3K_4LMNP[2]         
//  DRAB[0]         DRBA[1]       0           HL[2]             0                  
//  
//  
//  Chip 4H4J       DRBA[0]=0                 HL[1]=1
//  Chip 4F4E       DRBA[0]=1                 HL[1]=0
//  
//                                            HL[0]=0        LOW NIBBLE
//                                            HL[0]=1        HIGH NIBBLE
//  
//  
module AddresSelectors
(
   input RESETn,
   input DEADSEL, B2H,
   input [14:1] DRBA,
   input [7:0] HL,
   
   input [7:0] BD,
   input PLAYER2, HSYNCn, VBLANK, VSLDn,
  
   output [7:0] DRAB
);
   wire [7:0] w3K_4LMNP;
   ls153 ic4Lb
   (
      .A(DEADSEL),
      .B(B2H),
      .C3(DRBA[8]),
      .C2(1'b0),
      .C1(w3K_4LMNP[1]),
      .C0(1'b0),
      .Y(DRAB[7])
   );
   ls153 ic4La
   (
      .A(DEADSEL),
      .B(B2H),
      .C3(DRBA[7]),
      .C2(DRBA[14]),
      .C1(w3K_4LMNP[0]),
      .C0(w3K_4LMNP[7]),
      .Y(DRAB[6])
   );
   
   ls153 ic4Mb
   (
      .A(DEADSEL),
      .B(B2H),
      .C3(DRBA[6]),
      .C2(DRBA[13]),
      .C1(HL[7]),
      .C0(w3K_4LMNP[6]),
      .Y(DRAB[5])
   );
   ls153 ic4Ma
   (
      .A(DEADSEL),
      .B(B2H),
      .C3(DRBA[5]),
      .C2(DRBA[12]),
      .C1(HL[6]),
      .C0(w3K_4LMNP[5]),
      .Y(DRAB[4])
   );
   
   ls153 ic4Nb
   (
      .A(DEADSEL),
      .B(B2H),
      .C3(DRBA[4]),
      .C2(DRBA[11]),
      .C1(HL[5]),
      .C0(w3K_4LMNP[4]),
      .Y(DRAB[3])
   );
   ls153 ic4Na
   (
      .A(DEADSEL),
      .B(B2H),
      .C3(DRBA[3]),
      .C2(DRBA[10]),
      .C1(HL[4]),
      .C0(w3K_4LMNP[3]),
      .Y(DRAB[2])
   );
   ls153 ic4Pb
   (
      .A(DEADSEL),
      .B(B2H),
      .C3(DRBA[2]),
      .C2(DRBA[9]),
      .C1(HL[3]),
      .C0(w3K_4LMNP[2]),
      .Y(DRAB[1])
   );
   ls153 ic4Pa
   (
      .A(DEADSEL),
      .B(B2H),
      .C3(DRBA[1]),
      .C2(1'b0),
      .C1(HL[2]),
      .C0(1'b0),
      .Y(DRAB[0])
   );   
   
   potato ic3K
   (
      .clr_n(RESETn),
      .load_n(VSLDn),
      .ce_n(VBLANK),
      .dwnup(PLAYER2),
      .clk(HSYNCn),
      .p(BD),
      .q(w3K_4LMNP)
   );

   
endmodule