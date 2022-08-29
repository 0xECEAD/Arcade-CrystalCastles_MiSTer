module programmemory
(
   input clk,
   input [12:0] adress,
   input rom2_n,
   output [7:0] data
);

   rom2764 #(.INIT_FILE("136022-305.1n.rom")) ic1N
   (
      .clk(clk), 
      .en(~rom2_n),
      .addr(adress),
      .data(data)      
   );

endmodule