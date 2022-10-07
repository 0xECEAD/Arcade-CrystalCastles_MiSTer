module MicroProcessor
(
   input clk, ce2H,
   input reset_n,
   input INTACKn, IRQCLK,
   
   input [7:0] data_to_cpu,
   output [7:0] data_from_cpu,
   output [15:0] BA,
   
   output BRWn
);

wire WE;
reg IRQ;
assign BRWn = ~WE;

cpu_65c02 ic2D( 
   .clk(clk),                       // CPU clock
   .reset(~reset_n),                // RST signal, active HIGH
   .AB(BA),                         // address bus (combinatorial) 
   .DI(data_to_cpu),                // data bus input
   .DO(data_from_cpu),              // data bus output 
   .WE(WE),                         // write enable
   .IRQ(IRQ),                       // interrupt request, active HIGH
   .NMI(1'b0),                      // non-maskable interrupt request (rising edge)
   .RDY(ce2H),                      // Ready signal. Pauses CPU when RDY=0
   .SYNC()
);


reg IRQCLK2;
always @(posedge clk or negedge reset_n)           // ic11R
begin 
   if (~reset_n)
   begin
      IRQ <= #1 1'b0;
      IRQCLK2 <= #1 1'b1;
   end
   else if (~INTACKn)
      IRQ <= #1 1'b0;
   else 
   begin 
      IRQCLK2 <= #1 IRQCLK;
      if (~IRQCLK2 & IRQCLK) 
         IRQ <= #1 1'b1;
   end
end

endmodule