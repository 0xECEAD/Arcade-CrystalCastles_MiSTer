module Clock
(
   input clk,
   input reset_n,
   
   output ce5,
   output ce1H,
   output ce2H, 
   output reg ce2Hd
);

// Instead of dividing clocks down, we do a synchronous design on 10MHz rising edge clock with clock-enable bits.
// Better suited for FPGA and timing analysis. Clock lines only go to clock inputs (except maybe the Pokey- clk).


reg [2:0] count;
always @(posedge clk or negedge reset_n)           // ic9L (sort of)
begin
   if (~reset_n)
     count <= #1 3'b000;
   else 
      count <= #1 count + 3'b001;
end

assign ce5 = count[0];                      // Clock Enable 5MHz
assign ce1H = count == 1 || count == 5;     // Clock Enable 2.5MHz or 1H
assign ce2H = count == 7;                   // Clock Enable 1.25MHz or 2H


always @(posedge clk) ce2Hd <= #1 ce2H;            // delay ce2H with one clock


endmodule