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
module pokey_poly_4(clk, ce, reset_n, enable, init, bit_out);
   input     clk;
   input     ce;
   input     reset_n;
   input     enable;
   input     init;
   
   output    bit_out;
   
   reg [3:0] shift_reg;
   reg [3:0] shift_next;
   
   always @(posedge clk or negedge reset_n)
      if (reset_n == 1'b0)
         shift_reg <= 4'b1010;
      else  if (ce)
         shift_reg <= shift_next;
   
   
   always @(shift_reg or enable or init)
   begin
      shift_next <= shift_reg;
      if (enable == 1'b1)
         shift_next <= {((shift_reg[1] ~^ shift_reg[0]) & (~(init))), shift_reg[3:1]};
   end
   
   assign bit_out = shift_reg[0];
   
endmodule
/* verilator lint_on COMBDLY */