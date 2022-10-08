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
module syncreset_enable_divider(clk, ce, syncreset, reset_n, enable_in, enable_out);
   parameter       count = 1;
   parameter       resetcount = 0;
   input           clk;
   input           ce;
   input           syncreset;
   input           reset_n;
   input           enable_in;
   
   output          enable_out;
   
   parameter       width = $clog2(count);
   reg [width-1:0] count_reg;
   reg [width-1:0] count_next;
   
   reg             enabled_out_next;
   reg             enabled_out_reg;
   
   always @(posedge clk or negedge reset_n)
      if (reset_n == 1'b0)
      begin
         count_reg <= {width{1'b0}};
         enabled_out_reg <= 1'b0;
      end
      else if (ce)
      begin 
         count_reg <= count_next;
         enabled_out_reg <= enabled_out_next;
      end
   
   
   always @(count_reg or enable_in or enabled_out_reg or syncreset)
   begin
      count_next <= count_reg;
      enabled_out_next <= enabled_out_reg;
      
      if (enable_in == 1'b1)
      begin
         count_next <= (count_reg + 1);
         enabled_out_next <= 1'b0;
         
         if (count_reg == (count - 1))
         begin
            count_next <= 0;
            enabled_out_next <= 1'b1;
         end
      end
      
      if (syncreset == 1'b1)
         count_next <= resetcount;
   end
   
   assign enable_out = enabled_out_reg & enable_in;
   
endmodule
/* verilator lint_on COMBDLY */