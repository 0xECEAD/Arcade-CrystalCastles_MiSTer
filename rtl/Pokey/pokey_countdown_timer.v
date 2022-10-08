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
module pokey_countdown_timer(clk, ce, enable, enable_underflow, reset_n, wr_en, data_in, data_out);
   parameter   underflow_delay = 3;
   input       clk;
   input       ce;
   input       enable;
   input       enable_underflow;
   input       reset_n;
   
   input       wr_en;
   input [7:0] data_in;
   
   output      data_out;
   
   
   function  to_std_logic;
      input       l;
   begin
      if (l)
         to_std_logic = (1'b1);
      else
         to_std_logic = (1'b0);
   end
   endfunction
   
   reg [7:0]   count_reg;
   reg [7:0]   count_next;
   
   reg         underflow;
   
   reg [1:0]   count_command;
   reg [1:0]   underflow_command;
   
   delay_line #(underflow_delay) underflow0_delay(.clk(clk), .ce(ce), .sync_reset(wr_en), .data_in(underflow), .enable(enable_underflow), .reset_n(reset_n), .data_out(data_out));
   
   
   always @(posedge clk or negedge reset_n)
      if (reset_n == 1'b0)
         count_reg <= {8{1'b0}};
      else if (ce)
         count_reg <= count_next;
   
   
   always @(count_reg or enable or wr_en or count_command or data_in)
   begin
      count_command <= {enable, wr_en};
      case (count_command)
         2'b10 :
            count_next <= (count_reg - 8'b1);
         2'b01, 2'b11 :
            count_next <= data_in;
         default :
            count_next <= count_reg;
      endcase
   end
   
   
   always @(count_reg or enable or underflow_command)
   begin
      underflow_command <= {enable, to_std_logic(count_reg == 8'h00)};
      case (underflow_command)
         2'b11 :
            underflow <= 1'b1;
         default :
            underflow <= 1'b0;
      endcase
   end
   
endmodule
/* verilator lint_on COMBDLY */