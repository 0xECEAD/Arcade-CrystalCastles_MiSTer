module MotionObjectPictureRom
(
   input clk, CLK5,
   input CK1, PLAYER2,
   input MATCHn, SHFT0, SHFT1,
   input [15:0] SR,
   input [4:0] addrlo,
   
   output reg [2:0] AR
);

   reg [7:0] picture;
   always @(posedge CK1)                           // ic7A
   begin
      picture <= SR[7:0];
   end
   
   wire [12:0] addr = {picture, addrlo};
   wire [7:0] data_ic8D,data_ic8B;
   rom2764 #(.INIT_FILE("136022-106.8d.rom")) ic8D
   (
      .clk(clk), 
      .en(1'b1),
      .addr(addr),
      .data(data_ic8D)
   );
   rom2764 #(.INIT_FILE("136022-107.8b.rom")) ic8B
   (
      .clk(clk), 
      .en(1'b1),
      .addr(addr),
      .data(data_ic8B)
   );

   wire [3:0] nib3 = MATCHn ? 4'b1111 : data_ic8D[3:0];
   wire [3:0] nib2 = MATCHn ? 4'b1111 : data_ic8B[7:4];
   wire [3:0] nib1 = MATCHn ? 4'b1111 : data_ic8B[3:0];

   wire [3:0] data_ic9D;
   ls194 ic9D
   (
      .clk(CLK5),
      .s0(SHFT1), .s1(SHFT0),
      .clear_n(1'b1), .r(1'b0), .l(1'b0),
      .p(nib3),
      .q(data_ic9D)
   );

   wire [3:0] data_ic9B;
   ls194 ic9B
   (
      .clk(CLK5),
      .s0(SHFT1), .s1(SHFT0),
      .clear_n(1'b1), .r(1'b0), .l(1'b0),
      .p(nib2),
      .q(data_ic9B)
   );

   wire [3:0] data_ic9C;
   ls194 ic9C
   (
      .clk(CLK5),
      .s0(SHFT1), .s1(SHFT0),
      .clear_n(1'b1), .r(1'b0), .l(1'b0),
      .p(nib1),
      .q(data_ic9C)
   );

   always @(negedge CLK5)     // ic9A
   begin
      AR <= PLAYER2 ? { data_ic9D[0], data_ic9B[0], data_ic9C[0] } : { data_ic9D[3], data_ic9B[3], data_ic9C[3] };
   end


endmodule