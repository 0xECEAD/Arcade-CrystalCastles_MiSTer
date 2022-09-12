// Adress Decoder:

//                    5432 1098 7654 3210
//                    1111 1100 0000 0000
// Range              AAAA AAAA AAAA AAAA
// -----------|---------------------------|-------
//  E000-FFFF |  8k | 111x xxxx xxxx xxxx  | ROM2 (1N)
//  C000-DFFF |  8k | 110x xxxx xxxx xxxx  | ROM1 (1L / 1F)
//  A000-BFFF |  8k | 101x xxxx xxxx xxxx  | ROM0 (1J / 1K)
//  8000-9FFF |  8k | 100* xxxx xxxx xxxx  | NRn
                 
//  8000-8FFF |  4k | 1000 xxxx xxxx xxxx  | SRAMn
//  9000-9FFF |  4k | 1001 **xx xxxx xxxx  | ic5R-6Rn
                 
//  9C00-9FFF |  1k | 1001 11** *xxx xxxx  | ic6Rn-6Ln
//  9800-9BFF |  1k | 1001 10*x xxxx xxxx  | CIOn   => Pokey1 & 2 (* = BA9)   | SBUSn
//  9400-97FF |  1k | 1001 01xx xxxx xxxx  | IN0n                             | 
//  9000-93FF |  1k | 1001 00xx xxxx xxxx  | NVRAMn (256b)                    | 

//  9F80-9FFF | 128 | 1001 1111 1xxx xxxx  | CRAMn        | WRITEn
//  9F00-9F7F | 128 | 1001 1111 0xxx xxxx  | OUT1n        | 
//  9E80-9EFF | 128 | 1001 1110 1xxx xxxx  | OUT0n        | 
//  9E00-9E7F | 128 | 1001 1110 0xxx xxxx  | WDOGn        | 
//  9D80-9DFF | 128 | 1001 1101 1xxx xxxx  | INTACKn      | 
//  9D00-9D7F | 128 | 1001 1101 0xxx xxxx  | VSLDn        | 
//  9C80-9CFF | 128 | 1001 1100 1xxx xxxx  | HSLDn        | 
//  9C00-9C7F | 128 | 1001 1100 0xxx xxxx  | - recall?    | 

//  0000-7FFF | 32k | 0000 1100 0xxx xxxx  |  



module AddresDecoder
(
   input CLK10, RESETn,
   input [15:0] BA,
   input WRITEn, BD3, BH2, BITMDn, PIXB, BRWn,
   
   output WDOGn, INTACKn,
   output VSLDn, HSLDn,
   output BUF1BUF2n, SIREn,
   output PLAYER2, STARTLED1, 
   output YINCn, XINCn, AYn, AXn, 

   output CIOn, IN0n, OUT0n, OUT1n, 
   output BITRDn, DRHn, DRLn,
   output CRAMn, NVRAMn, SBUSn, SRAMn, UARTn,
   output NRn, DBUSn, ROM2n, ROM1n, ROM0n
);

   ls139 ic4Ra
   (
      .a(BA[13]),
      .b(BA[14]),
      .g_n(~BA[15]),
      .y({ROM2n, ROM1n, ROM0n, NRn})
   );

   wire w6R_6L6M5M;
   assign SRAMn = ~(~NRn & ~BA[12]);
   wire w5R_6R = ~(~NRn & BA[12]);
   assign SBUSn = ~(~w5R_6R & w6R_6L6M5M);

   ls139 ic46Rb
   (
      .a(BA[10]),
      .b(BA[11]),
      .g_n(w5R_6R),
      .y({w6R_6L6M5M, CIOn, IN0n, NVRAMn})
   );

   wire dmy;
   ls138 ic6M
   (
      .a(BA[7]),
      .b(BA[8]),
      .c(BA[9]),
      .g1(1'b1),
      .g2a_n(WRITEn),
      .g2b_n(w6R_6L6M5M),
      .y({CRAMn,OUT1n,OUT0n,WDOGn,INTACKn,VSLDn,HSLDn,UARTn})
   ); 

   rom82S129 #(.INIT_FILE("82s129-136022-109.6l.rom")) ic6L
   (
      .clk(CLK10),
      .A({BH2,BA[15], BITMDn, BA[0], PIXB, BRWn, w6R_6L6M5M, 1'b0}),
      .CE_n(1'b0),
      .O({BITRDn, DRHn, DRLn, DBUSn})
   );
   
   ls259 ic6P
   (
      .a(BA[0]),
      .b(BA[1]),
      .c(BA[2]),
      .d(BD3),
      .g_n(OUT1n),
      .clr_n(RESETn),
      .q({BUF1BUF2n,STARTLED1,SIREn,PLAYER2,YINCn,XINCn,AYn,AXn})
   ); 

endmodule