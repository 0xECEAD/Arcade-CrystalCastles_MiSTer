module MicroProcessor
(
   input clk,
   input RESETn, H1n,
   input INTACKn, IRQCK,
   
   input [7:0] data_to_cpu,
   output [7:0] data_from_cpu,
   output [15:0] BA,
   
   output BRWn, DRWR, WRITEn
);

   wire WE, IRQn;

   cpu_65c02 ic2D( 
      .clk(clk),                       // CPU clock
      .reset(~RESETn),                 // RST signal, active HIGH
      .AB(BA),                         // address bus (combinatorial) 
      .DI(data_to_cpu),                // data bus input
      .DO(data_from_cpu),              // data bus output 
      .WE(WE),                         // write enable
      .IRQ(~IRQn),                     // interrupt request, active HIGH
      .NMI(1'b0),                      // non-maskable interrupt request (rising edge)
      .RDY(1'b1),                      // Ready signal. Pauses CPU when RDY=0
      .SYNC()
   );

   ls74 ic11Ra
   (
      .pre_n(INTACKn & RESETn),
      .clr_n(1'b1),
      .clk(IRQCK), 
      .d(1'b0), 
      .q(IRQn)
   );
  
   assign BRWn = ~WE;
   wire WRphi2n = ~(clk & WE);
   assign WRITEn = ~(~WRphi2n & ~H1n);
   assign DRWR = (~WRphi2n & ~BA[15]);

endmodule