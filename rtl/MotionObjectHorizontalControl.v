module MotionObjectHorizontalControl
(
   input CLK5n,
   input [15:0] SR,
   input LD1n, LD2n, CL1n, CL2n,
   output [7:0] addr1, addr2
);

   wire carry2;
   ls163 ic10F
   (
      .load_n(LD2n),
      .clr_n(CL2n),
      .clk(CLK5n),
      .p(SR[11:8]),
      .ent(1'b1), 
      .enp(1'b1),
      .q(addr2[3:0]),
      .rco(carry2)
   );
   ls163 ic10E
   (
      .load_n(LD2n),
      .clr_n(CL2n),
      .clk(CLK5n),
      .p(SR[15:12]),
      .ent(carry2), 
      .enp(carry2),
      .q(addr2[7:4])
   );

   wire carry1;
   ls163 ic10D
   (
      .load_n(LD1n),
      .clr_n(CL1n),
      .clk(CLK5n),
      .p(SR[11:8]),
      .ent(1'b1), 
      .enp(1'b1),
      .q(addr1[3:0]),
      .rco(carry1)
   );
   ls163 ic10C
   (
      .load_n(LD1n),
      .clr_n(CL1n),
      .clk(CLK5n),
      .p(SR[15:12]),
      .ent(carry1), 
      .enp(carry1),
      .q(addr1[7:4])
   );

endmodule