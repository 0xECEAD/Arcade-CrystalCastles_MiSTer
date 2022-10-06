// `define RUNDIAGNOSTIC

module ProgramMemory
(
   input clk,
   input [12:0] address,
   input ROM0n,ROM1n,ROM2n,
   input BANK0n, BANK1n,
   output reg [7:0] data_from_rom
);

wire [7:0] data_ic1F, data_ic1H, data_ic1K, data_ic1L, data_ic1N;

rom2764 #(.INIT_FILE("136022-101.1f.rom")) ic1F
(
   .clk(clk), 
   .addr(address),
   .data(data_ic1F)
);

rom2764 #(.INIT_FILE("136022-102.1h.rom")) ic1H
(
   .clk(clk), 
   .addr(address),
   .data(data_ic1H)
);

rom2764 #(.INIT_FILE("136022-303.1k.rom")) ic1K
(
   .clk(clk), 
   .addr(address),
   .data(data_ic1K)
);

rom2764 #(.INIT_FILE("136022-304.1l.rom")) ic1L
(
   .clk(clk), 
   .addr(address),
   .data(data_ic1L)
);

`ifdef RUNDIAGNOSTIC
rom2764 #(.INIT_FILE("diagnose.rom")) ic1N 
`else
rom2764 #(.INIT_FILE("136022-305.1n.rom")) ic1N
`endif
(
   .clk(clk), 
   .addr(address),
   .data(data_ic1N)
);

always @(*)
begin
   if (~ROM1n) data_from_rom = ~BANK0n ? data_ic1L : data_ic1F;
   else if (~ROM0n) data_from_rom = ~BANK0n ? data_ic1K : data_ic1H;
   else /*if (~ROM2n)*/ data_from_rom = data_ic1N;
end

endmodule