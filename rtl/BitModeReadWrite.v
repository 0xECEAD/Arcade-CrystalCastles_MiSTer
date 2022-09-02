module BitModeReadWrite
(
   input [7:0] from_dram,
   input PIXA,
   output [7:0] bmr_to_cpu,
   
   input [7:0] from_cpu,
   output [7:0] bmw_to_dram
);

assign bmr_to_cpu = { PIXA ? from_dram[3:0] : from_dram[7:4], 4'b000 };
assign bmw_to_dram = { from_cpu[7:4], from_cpu[7:4] };

endmodule