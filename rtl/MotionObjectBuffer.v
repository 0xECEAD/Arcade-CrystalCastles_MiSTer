module MotionObjectBuffer
(
   input clk, ce5, ce2Hd5,
   input CK1, SR7,
   input [2:0] AR,
   input DIP2,
   input [7:0] addr1,
   input [7:0] addr2,
   output reg [2:0] MV,
   output reg MPI
);

reg API;
always @(posedge clk)                        // ic10J
begin
   if (~CK1 & ce2Hd5)
      API <= SR7;
end

wire ARE = (~AR[0] | ~AR[1] | ~AR[2]);       // ic7D
wire CS1 = (ARE | DIP2);                   // ic9Hd
wire CS2 = (ARE | ~DIP2);                  // ic9Ha

wire [3:0] data_ic10A, data_ic10B;
moram ic10B
(
   .clk(clk),
   .we(ce5),
   .cs(CS2),
   .addr(addr2),
   .din(ic11Ahi),
   .dout(data_ic10B)
);
moram ic10A
(
   .clk(clk),
   .we(ce5),
   .cs(CS1),
   .addr(addr1),
   .din(ic11Alo),
   .dout(data_ic10A)
);
   
wire [3:0] ic11Ahi = DIP2 ? { AR, API } : 4'b1111;
wire [3:0] ic11Alo = ~DIP2 ? { AR, API } : 4'b1111;

always @(posedge clk)     // ic11B
if (~ce5)
begin
   MV <= DIP2 ? data_ic10A[3:1] : data_ic10B[3:1];
   MPI <= DIP2 ? data_ic10A[0] : data_ic10B[0];
end

endmodule