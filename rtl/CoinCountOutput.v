module CoinCountOutput
(
   input reset_n, clk,
   
   input OUT0n, BD0,
   input [2:0] BA, 
    
   output BANK0n, BANK1n, 
   output COINCNTL_L, COINCNTL_R,
   output RECALLn, STORE,
   output STARTLED2, LIGHTBULB
);

reg [7:0] q;
always @(posedge clk or negedge reset_n)        //ic8N
begin
   if (~reset_n)
      q <= #1 8'b00000000;
   else if (~OUT0n)
     case (BA) 
         3'b000: q[0] <= #1 BD0;
         3'b001: q[1] <= #1 BD0;
         3'b010: q[2] <= #1 BD0;
         3'b011: q[3] <= #1 BD0;
         3'b100: q[4] <= #1 BD0;
         3'b101: q[5] <= #1 BD0;
         3'b110: q[6] <= #1 BD0;
         3'b111: q[7] <= #1 BD0;
      endcase 
 end
 
assign BANK0n = q[7];
assign BANK1n = ~q[7];
assign COINCNTL_L = q[6];
assign COINCNTL_R = q[5];
assign RECALLn = q[4];
assign STARTLED2 = q[1];
assign LIGHTBULB = q[0];
assign STORE = ~q[2] & q[3];
 
endmodule
