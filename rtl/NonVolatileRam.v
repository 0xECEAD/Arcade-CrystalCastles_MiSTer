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
   .we(WE),
   .addr(BA), 
   .din(data_to_nvram),
   .dout(data_from_nvram)
);

endmodule