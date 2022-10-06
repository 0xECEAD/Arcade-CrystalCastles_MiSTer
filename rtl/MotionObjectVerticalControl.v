module MotionObjectVerticalControl
(
   input [15:0] SR,
   input [7:0] VC,
   input CK1, PLAYER2,
   
   output [4:0] addr,
   output reg MATCHn
);

   wire carry;
   wire [3:0] sum1, sum2;
   ls283 ic7C
   (
      .a(VC[7:4]),
      .b(SR[15:12]),
      .ci(carry),
      .sum(sum2)
   );
   ls283 ic7B
   (
      .a(VC[3:0]),
      .b(SR[11:8]),
      .ci(1'b0),
      .co(carry),
      .sum(sum1)
   );

   reg [3:0] q;
   always @(posedge CK1)                                       // ic7E
   begin
      MATCHn <= ~(sum2[3] & sum2[2] & sum2[1] & sum2[0]);
      q <= sum1;
   end
   
   assign addr = { q ^ PLAYER2, ~CK1 ^ PLAYER2 };              // ic8F

endmodule