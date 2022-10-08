/*---------------------------------------------------------------------------
-- (c) 2013 mark watson
-- I am happy for anyone to use this for non-commercial use.
-- If my vhdl files are used commercially or otherwise sold,
-- please contact me for explicit permission at scrameta (gmail).
-- This applies for source and binary form and derived works.
--
-- Converted to Verilog from original VHDL
--------------------------------------------------------------------------*/

`timescale 1 ps / 1 ps
/* verilator lint_off COMBDLY */
module synchronizer(clk, ce, raw, sync);
   input      clk;
   input      ce;
   input      raw;
   output     sync;
   
   wire [2:0] ff_next;
   reg [2:0]  ff_reg;
   
   always @(posedge clk)
       if (ce)
         ff_reg <= ff_next;
   
   assign ff_next = {raw, ff_reg[2:1]};
   
   assign sync = ff_reg[0];
   
endmodule
/* verilator lint_on COMBDLY */