module microprocessor
(
   input clk,
   input RESETn,
   input INTACKn, IRQCK,
   
   input [7:0] data_to_cpu,
   output [7:0] data_from_cpu,
   output [15:0] adressbus,
   output RWn
);

   wire IRQn;

   cpu_65c02 ic2D( 
      .clk(clk),                       // CPU clock
      .reset(~RESETn),                 // RST signal, active HIGH
      .AB(adressbus),                  // address bus (combinatorial) 
      .DI(data_to_cpu),                // data bus input
      .DO(data_from_cpu),              // data bus output 
      .WE(RWn),                        // write enable
      .IRQ(~IRQn),                     // interrupt request, active HIGH
      .NMI(1'b0),                      // non-maskable interrupt request (rising edge)
      .RDY(1'b1),                      // Ready signal. Pauses CPU when RDY=0
      .SYNC()
   );

   ls74 ic11Ra
   (
   	.n_pre(INTACKn),
      .n_clr(RESETn),
      .clk(IRQCK), 
      .d(1'b0), 
      .q(IRQn)
   );

endmodule