module NonVolatileRam
(
   input clk, ce2Hd,
   input NVRAMn, BRWn,
   input [7:0] BA,

   input DCOKn, STORE, RECALLn, SIREn,
   
   input [7:0] data_to_nvram,
   output [7:0] data_from_nvram
);

wire WE = ~NVRAMn & ~BRWn & ce2Hd;

nvram #(.INIT_FILE("nvram.rom")) ic4B4D
(
   .clk(clk),
   
   //.store((STORE & SIREn)), .recall(~RECALLn & ~SIREn),
   
   // NOTE: it is possible to make a shadow ram for storing (copy 256 bytes), it takes 10ms max on real X2212, can be faster in a FPGA.
   // But recall takes only 1us on the X2212, and i don't know a way to implement that in FPGA.
   // Consequence is that in the SELFTEST, the TEST ROMS fail with message : "EEPROM FAILURE AT PC 4B"
   
   .we(WE), .addr(BA), 
   .din(data_to_nvram),
   .dout(data_from_nvram)
);

endmodule