module AutoIncOutput
(
   input reset_n, clk,
   
   input OUT1n, BD3,
   input [2:0] BA, 
    
   output BUF1BUF2n, STARTLED1, 
   output SIREn, PLAYER2,
   output YINCn, XINCn,
   output AYn, AXn
);

reg [7:0] q;
always @(posedge clk or negedge reset_n)        //ic6P
begin
   if (~reset_n)
      q <= #1 8'b00000000;
   else if (~OUT1n)
     case (BA) 
         3'b000: q[0] <= #1 BD3;
         3'b001: q[1] <= #1 BD3;
         3'b010: q[2] <= #1 BD3;
         3'b011: q[3] <= #1 BD3;
         3'b100: q[4] <= #1 BD3;
         3'b101: q[5] <= #1 BD3;
         3'b110: q[6] <= #1 BD3;
         3'b111: q[7] <= #1 BD3;
      endcase 
 end
 
assign BUF1BUF2n = q[7];
assign STARTLED1 = q[6];
assign SIREn = q[5];
assign PLAYER2 = q[4];
assign YINCn = q[3];
assign XINCn = q[2];
assign AYn = q[1];
assign AXn = q[0];
 
endmodule
