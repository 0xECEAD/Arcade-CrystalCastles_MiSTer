module AudioOutput
(
   input reset_n, clk, ce2Hd,
   
   input [15:0] BA,
   input CIOn, BRWn,
   input [7:0] BD,
   
   input         COCKTAIL,
   input         STARTJMP1, STARTJMP2,
     
   output [7:0] pokey_to_cpu,
   output [7:0] SOUT
);

wire cs_pokey3B = ~CIOn & ~BA[9];
wire cs_pokey3D = ~CIOn & BA[9];

wire [5:0] snd1,snd2;
wire [7:0] DIP = { 1'b0, 1'b0, COCKTAIL, STARTJMP2, STARTJMP1, 1'b0, 1'b0, 1'b0 };
wire [7:0] rdt3B, rdt3D;

PokeyW ic3D
(
   .clk(clk),
   .ce(ce2Hd),
   .rst_n(reset_n),
   .ad(BA[3:0]),
   .cs(cs_pokey3D),
   .we(~BRWn),
   .data_to_pokey(BD),
   .data_from_pokey(rdt3D),
   .snd(snd1),
   .p(DIP)
);
   
PokeyW ic3B
(
   .clk(clk),
   .ce(ce2Hd),
   .rst_n(reset_n),
   .ad(BA[3:0]),
   .cs(cs_pokey3B),
   .we(~BRWn),
   .data_to_pokey(BD),
   .data_from_pokey(rdt3B),
   .snd(snd2),
   .p(8'd0)
);

assign SOUT = {2'b00,snd1}+{2'b00,snd2};
assign pokey_to_cpu = cs_pokey3D ? rdt3D : rdt3B;

endmodule