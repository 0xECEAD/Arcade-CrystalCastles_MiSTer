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
//  9C00-9C7F | 128 | 1001 1100 0xxx xxxx  | UARTn        

//  0000-7FFF | 32k | 0000 1100 0xxx xxxx  | DRAM 



module AddresDecoder
(
   input clk, ce2H, ce2Hd,

   input [15:0] BA,
   input BRWn,

   output NRn, ROM2n, ROM1n, ROM0n,

   output WDOGn, INTACKn, VSLDn, HSLDn, UARTn,
   output CIOn, IN0n, OUT0n, OUT1n, 
   output CRAMn, NVRAMn, SBUSn, SRAMn,
   
   output BITMDn, XCOORDn, YCOORDn   
);

assign ROM2n = ~(BA[15:13] == 3'b111);       // ic4Ra
assign ROM1n = ~(BA[15:13] == 3'b110);
assign ROM0n = ~(BA[15:13] == 3'b101);
assign NRn   = ~(BA[15:13] == 3'b100);

assign SRAMn = ~(~NRn & ~BA[12]);
wire w5R_6R = ~(~NRn & BA[12]);
assign SBUSn = ~(~w5R_6R & w6R_6L6M5M);

wire   w6R_6L6M5M = ~(~w5R_6R & BA[11:10] == 2'b11);       //  ic46Rb
assign CIOn       = ~(~w5R_6R & BA[11:10] == 2'b10);
assign IN0n       = ~(~w5R_6R & BA[11:10] == 2'b01);
assign NVRAMn     = ~(~w5R_6R & BA[11:10] == 2'b00);

assign CRAMn   = ~(~w6R_6L6M5M & BA[9:7] == 3'b111 & ~BRWn & ce2Hd);         //  ic6M
assign OUT1n   = ~(~w6R_6L6M5M & BA[9:7] == 3'b110 & ~BRWn & ce2Hd);
assign OUT0n   = ~(~w6R_6L6M5M & BA[9:7] == 3'b101 & ~BRWn & ce2Hd);
assign WDOGn   = ~(~w6R_6L6M5M & BA[9:7] == 3'b100 & ~BRWn & ce2Hd);
assign INTACKn = ~(~w6R_6L6M5M & BA[9:7] == 3'b011 & ~BRWn & ce2Hd);
assign VSLDn   = ~(~w6R_6L6M5M & BA[9:7] == 3'b010 & ~BRWn & ce2Hd);
assign HSLDn   = ~(~w6R_6L6M5M & BA[9:7] == 3'b001 & ~BRWn & ce2Hd);
assign UARTn   = ~(~w6R_6L6M5M & BA[9:7] == 3'b000);

assign XCOORDn = ~(BA == 16'h0000 & ~BRWn & ce2Hd);               // ic2R
assign YCOORDn = ~(BA == 16'h0001 & ~BRWn & ce2Hd);
assign BITMDn  = ~(BA == 16'h0002);


endmodule