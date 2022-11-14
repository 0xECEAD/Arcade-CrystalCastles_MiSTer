module NonVolatileRam
(
   input clk, ce2Hd, reset_n,
   input NVRAMn, BRWn,
   input [7:0] BA,

   input STORE, RECALLn, SIREn,
   
   input [7:0] data_to_nvram,
   output [7:0] data_from_nvram
);

wire WE = ~NVRAMn & ~BRWn & ce2Hd;

nvram ic4B4D
(
   .clk(clk), .reset_n(reset_n),
   
   .store((STORE & SIREn)), .recall(~RECALLn & ~SIREn),
   
   // Implement nvram by having a shadow ram for storing (copy 256 bytes), it takes 10ms max on a real X2212, 
   // and only 512 clock cycles in the FPGA (51.2 µs @ 10MHz).
   // Recall takes 1 µs on the X2212, in the FPGA it just toggles to the shadow ram (in one clock cycle) and back.
   
   .we(WE), .addr(BA), 
   .din(data_to_nvram),
   .dout(data_from_nvram)
);

endmodule