module MotionObjectVerticalControl
(
   input clk, ce2Hd5,
   input [15:0] SR,
   input [7:0] VC,
   input CK1, PLAYER2,
   
   output [4:0] addr,
   output reg MATCHn
);

wire [7:0] sum = VC + SR[15:8];

reg [3:0] q;
always @(posedge clk)                                       // ic7E
if (CK1 & ce2Hd5)
begin
   MATCHn <= ~(sum[7] & sum[6] & sum[5] & sum[4]);
   q <= sum[3:0];
end
   
wire [3:0] p4 = {4{PLAYER2} };
assign addr = { q ^ p4, ~CK1 ^ PLAYER2 };              // ic8F

endmodule