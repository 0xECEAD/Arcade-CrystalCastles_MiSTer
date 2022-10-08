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
module delay_line(clk, ce, sync_reset, data_in, enable, reset_n, data_out);
	parameter       count = 1;
	input           clk;
   input           ce;
	input           sync_reset;
	input           data_in;
	input           enable;
	input           reset_n;
	
	output          data_out;
	
	reg [count-1:0] shift_reg;
	reg [count-1:0] shift_next;
	
	always @(posedge clk or negedge reset_n)
		if (reset_n == 1'b0)
			shift_reg <= {count{1'b0}};
		else if (ce)
			shift_reg <= shift_next;
	
	
	always @(shift_reg or enable or data_in or sync_reset)
	begin
		shift_next <= shift_reg;
		
		if (enable == 1'b1)
			shift_next <= {data_in, shift_reg[count - 1:1]};
		
		if (sync_reset == 1'b1)
			shift_next <= {count{1'b0}};
	end
	
	assign data_out = shift_reg[0] & enable;
	
endmodule
/* verilator lint_on COMBDLY */