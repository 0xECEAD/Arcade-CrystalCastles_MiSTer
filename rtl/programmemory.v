module ProgramMemory
(
   input clk,
   input [12:0] address,
   input rom0_n,rom1_n,rom2_n,
   input bank0_n, bank1_n,
   output reg [7:0] data
);
   wire [7:0] data_ic1F, data_ic1H, data_ic1K, data_ic1L, data_ic1N;

   rom2764 #(.INIT_FILE("136022-101.1f.rom")) ic1F
   (
      .clk(clk), 
      .en(1'b1),
      .addr(address),
      .data(data_ic1F)
   );

   rom2764 #(.INIT_FILE("136022-102.1h.rom")) ic1H
   (
      .clk(clk), 
      .en(1'b1),
      .addr(address),
      .data(data_ic1H)
   );
   
   rom2764 #(.INIT_FILE("136022-303.1k.rom")) ic1K
   (
      .clk(clk), 
      .en(1'b1),
      .addr(address),
      .data(data_ic1K)
   );

   rom2764 #(.INIT_FILE("136022-304.1l.rom")) ic1L
   (
      .clk(clk), 
      .en(1'b1),
      .addr(address),
      .data(data_ic1L)
   );


   //rom2764 #(.INIT_FILE("diagnose.rom")) ic1N
   rom2764 #(.INIT_FILE("136022-305.1n.rom")) ic1N
   (
      .clk(clk), 
      .en(1'b1),
      .addr(address),
      .data(data_ic1N)
   );

   always @(*)
   begin
      if (~rom1_n) data = ~bank0_n ? data_ic1L : data_ic1F;
      else if (~rom0_n) data = ~bank0_n ? data_ic1K : data_ic1H;
      else /*if (~rom2_n)*/ data = data_ic1N;
   end

endmodule