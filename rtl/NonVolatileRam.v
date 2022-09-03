module NonVolatileRam
(
   input clk,
   input NVRAMn, WRphi2n,
   input [7:0] BA,

   input DCOKn, STORE, RECALLn, SIREn,
   
   input [7:0] data_to_nvram,
   output [7:0] data_from_nvram
);

wire w5E_4B4D = ~(~NVRAMn & ~WRphi2n);

nvram2212 ic4B
(
   .clk(clk),
   .we_n(w5E_4B4D),
   .addr(BA), 
   .din(data_to_nvram[3:0]),
   .dout(data_from_nvram[3:0])
);

nvram2212 ic4D
(
   .clk(clk),
   .we_n(w5E_4B4D),
   .addr(BA), 
   .din(data_to_nvram[7:4]),
   .dout(data_from_nvram[7:4])
);

endmodule