// --------------------------------------------------------------------------------------------------------------------------------
// 74ls74    (dual) D positive edge triggered flip-flop, asynchronous preset and clear 

module ls74
(
   input  pre_n,
   input  clr_n,
   input  clk, 
   input  d, 
   output reg q,
   output q_n
);
always @(posedge clk or negedge pre_n or negedge clr_n) 
   begin
      if(~pre_n)
         q <= #1 1;
      else if(~clr_n)
         q <= #1 0;
      else
         q <= #1 d;
   end
   assign q_n = ~q;
endmodule

// --------------------------------------------------------------------------------------------------------------------------------
// 74ls109  (dual) J-NotK positive-edge-triggered flip-flop, clear and preset

module ls109
(
   input  pre_n,
   input  clr_n,
   input  clk, 
   input  j, 
   input  k_n, 
   output reg q,
   output q_n
);
always @(posedge clk or negedge pre_n or negedge clr_n) 
begin
   if(~pre_n)
      q <= #1 1;
   else if(~clr_n)
      q <= #1 0;
   else
      case ({j, k_n})
         2'b01: q <= #1 q;
         2'b00: q <= #1 1'b0;
         2'b11: q <= #1 1'b1;
         2'b10: q <= #1 ~q;
      endcase
   end
   assign q_n = ~q;
endmodule

// --------------------------------------------------------------------------------------------------------------------------------
// 74ls138    3-to-8 line decoder/demultiplexer, inverting outputs

module ls138
(
   input a,b,c,
   input g1,g2a_n,g2b_n,
   output reg [7:0] y
); 
wire en = g1 & ~g2a_n & ~g2b_n;
wire [2:0] sel = {c,b,a};
always @(en,sel) 
begin 
   if (en == 1'b1) 
   case (sel) 
      3'b000: y <= #1 8'b11111110;
      3'b001: y <= #1 8'b11111101;
      3'b010: y <= #1 8'b11111011;
      3'b011: y <= #1 8'b11110111;
      3'b100: y <= #1 8'b11101111;
      3'b101: y <= #1 8'b11011111;
      3'b110: y <= #1 8'b10111111;
      3'b111: y <= #1 8'b01111111;
      default: y <= #1 8'b11111111;
   endcase 
   else y <= #1 8'b11111111;
end 
endmodule


// --------------------------------------------------------------------------------------------------------------------------------
// 74ls139    (dual) 2-to-4 line decoder/demultiplexer, inverting outputs

module ls139
(
   input a,b,
   input g_n,
   output reg [3:0] y
); 
wire en = ~g_n;
wire [1:0] sel = {b,a};
always @(en,sel) 
begin 
   if (en == 1'b1) 
   case (sel) 
      2'b00: y <= #1 4'b1110;
      2'b01: y <= #1 4'b1101;
      2'b10: y <= #1 4'b1011;
      2'b11: y <= #1 4'b0111;
      default: y <= #1 4'b1111;
   endcase 
   else y <= #1 4'b1111;
end 
endmodule


// --------------------------------------------------------------------------------------------------------------------------------
// 74ls153    (dual) 4-line to 1-line data selector/multiplexer, non-inverting outputs

module ls153
(     
   input A,B,
   input C0,C1,C2,C3,
   output Y
);
   assign #3 Y = ( B & A & C3) | ( B & !A & C2) | (!B &  A & C1) | (!B & !A & C0);
endmodule

// --------------------------------------------------------------------------------------------------------------------------------
// 74ls157  (quad) 2-line to 1-line data selector/multiplexer, non-inverting outputs

module ls157
(
   input [3:0] a, b,
   input g_n, sel,
   output [3:0] y
); 
assign #3 y = g_n ? 4'b000 : sel ? b : a;
endmodule

// --------------------------------------------------------------------------------------------------------------------------------
// 74ls160  synchronous presettable 4-bit decade counter, asynchronous clear

module ls160
(
   input load_n,
   input clr_n,
   input clk,
   
   input [3:0] p,   
   input ent, enp,
   
   output reg [3:0] q,
   output rco
);
always @(posedge clk or negedge clr_n)
   begin
      if(!clr_n)
         q <= #1 4'b0000;
      else if(!load_n)
         q <= p;
      else if(ent & enp)
         if (rco)
            q <= #1 4'b0000;
         else
            q <= #1 q + 4'b0001;
   end
   assign rco = ent & q == 4'b1001;
endmodule

// --------------------------------------------------------------------------------------------------------------------------------
// 74ls163  synchronous presettable 4-bit binary counter, synchronous clear 

module ls163
(
   input load_n,
   input clr_n,
   input clk,
   
   input [3:0] p,
   input ent, enp,
   
   output reg [3:0] q,
   output rco
);

always @(posedge clk) 
   begin
      if(!clr_n)
         q <= 4'b0000;
      else if(!load_n)
         q <= p;
      else if(ent & enp)
         q <= #1 q + 4'b0001;
   end
   assign rco = ent & q == 4'b1111;
endmodule

// --------------------------------------------------------------------------------------------------------------------------------
// 74ls169  synchronous presettable 4-bit up/down binary counter

module ls169
(
   input clr_n,
   input load_n,
   input clk,
   input updwn,
   input [3:0] p,
   input ent_n, enp_n,
   
   output reg [3:0] q,
   output rco_n
);

always @(posedge clk or negedge clr_n) 
   begin
      if(~clr_n)
         q <= #1 4'b0000;
      else if(~load_n)
         q <= #1 p;
      else if(~ent_n & ~enp_n & updwn)
         q <= #1 q + 4'b0001;
      else if(~ent_n & ~enp_n & ~updwn)
         q <= #1 q - 4'b0001;
   end
   assign rco_n = ent_n | (updwn & q != 4'b1111) | (~updwn & q != 4'b0000);
endmodule

// --------------------------------------------------------------------------------------------------------------------------------
// 74ls174  hex D flip-flop, common asynchronous clear


// --------------------------------------------------------------------------------------------------------------------------------
// 74ls175  (quad) D edge-triggered flip-flop, complementary outputs and asynchronous clear 

module ls175
(
   input  clr_n,
   input  clk, 
   input [3:0] d, 
   output reg [3:0] q,
   output [3:0] q_n
);
always @(posedge clk or negedge clr_n) 
   begin
      if(!clr_n)
         q <= 0;
      else
         q <= #1 d;
   end
   assign q_n = ~q;
endmodule

// --------------------------------------------------------------------------------------------------------------------------------
// 74ls191  synchronous presettable up/down 4-bit binary counter

module ls191
(
   input clear_n,
   input load_n,
   input dwnup_n,
   input g_n, clk,
   input [3:0] p,
   
   output reg [3:0] q,
   output rco_n
);

always @(posedge clk or negedge load_n or negedge clear_n) 
   begin
      if(!clear_n)
         q <= #1 4'b0000;
      else if(!load_n)
         q <= #1 p;
      else if(~g_n && dwnup_n)
         q <= #1 q - 4'b0001;
      else if(~g_n && ~dwnup_n)
         q <= #1 q + 4'b0001;
   end
   assign rco_n = g_n | ~dwnup_n & q != 4'b1111 | dwnup_n & q != 4'b0000;
endmodule


// --------------------------------------------------------------------------------------------------------------------------------
// 74ls193  synchronous presettable up/down 4-bit binary counter, clear

// --------------------------------------------------------------------------------------------------------------------------------
// 74ls194  4-bit bidirectional universal shift register

module ls194
(
   input clear_n,
   input clk,
   input s0,s1,
   input r,l,
   input [3:0] p,
   output reg [3:0] q
);

always @(posedge clk or negedge clear_n) 
   begin
      if(!clear_n)
         q <= #1 4'b0000;
      else case ({s1, s0})
         2'b00: q <= #1 q;
         2'b01: q <= #1 {q[2:0],r};
         2'b10: q <= #1 {l, q[3:1]};
         2'b11: q <= #1 p;
      endcase
   end
endmodule



// --------------------------------------------------------------------------------------------------------------------------------
// 74ls257  quad 2-line to 1-line data selector/multiplexer, non-inverting, TS


// --------------------------------------------------------------------------------------------------------------------------------
// 74ls259   8-bit bit addressable input latch with clr

module ls259
(
    input a,b,c,
   input d,
   input g_n,
   input clr_n,
   output reg [7:0] q
); 
wire [2:0] sel = {c,b,a};
always @(*) 
begin 
   if (clr_n == 1'b0) 
      q <= #1 8'b00000000;
   else if (g_n == 1'b0)
   case (sel) 
      3'b000: q[0] <= #1 d;
      3'b001: q[1] <= #1 d;
      3'b010: q[2] <= #1 d;
      3'b011: q[3] <= #1 d;
      3'b100: q[4] <= #1 d;
      3'b101: q[5] <= #1 d;
      3'b110: q[6] <= #1 d;
      3'b111: q[7] <= #1 d;
   endcase 
end 
endmodule

// --------------------------------------------------------------------------------------------------------------------------------
// 74ls273   8-bit register, asynchronous clear 

// --------------------------------------------------------------------------------------------------------------------------------
// 74ls283   4-bit binary full adder (has carry in function)

module ls283
(
   input [3:0] a,
   input [3:0] b,
   input ci,
   
   output reg [3:0] sum,
   output reg co
);

always @(*) 
   begin
      {co, sum} = a + b + ci;
   end
endmodule



// --------------------------------------------------------------------------------------------------------------------------------
// 74ls298   quad 2-input multiplexer, storage 

// --------------------------------------------------------------------------------------------------------------------------------
// 74ls374   octal register, TS

// --------------------------------------------------------------------------------------------------------------------------------
// 137304-1001    Track Ball Interface

// --------------------------------------------------------------------------------------------------------------------------------
// X2212      Non volatile RAM

module nvram2212
(
   input clk,
   input we_n,
   input [7:0] addr,
   input [3:0] din,
   output reg [3:0] dout
);
   reg [3:0] mem [0:255];

   always @(posedge clk) 
   begin
      if (we_n == 1'b0) 
         mem[addr] <= din;
      else 
         dout <= mem[addr];
   end

endmodule   


// --------------------------------------------------------------------------------------------------------------------------------
// CDW6116      200ns TriState SRAM (2k x 8b)

module sram6116 # ( parameter INIT_FILE = "init.txt" )
(
   input clk,
   input we_n, 
   input [10:0] addr,
   input [7:0] din,
   output reg [7:0] dout
);
   reg [7:0] mem [0:2047];

   always @(posedge clk) 
   begin
      if (we_n == 1'b0) 
         mem[addr] <= din;
      else
         dout <= mem[addr];
   end
   
   initial begin
      $readmemh(INIT_FILE, mem);
   end

   
endmodule


// --------------------------------------------------------------------------------------------------------------------------------
// 82S129      Bus PROM (256 x 4b)

module rom82S129 # ( parameter INIT_FILE = "rom.txt" )
(
   input clk,
   input CE_n,
   input [7:0] A,
   output reg [3:0] O
);
   reg [3:0] mem [0:255];

   always @(posedge clk) 
   begin
      if (CE_n == 1'b0) 
         O <= mem[A];
   end

   initial begin
      $readmemh(INIT_FILE, mem);         // read hex values, one per line (use // for comment)
   end

endmodule   

// --------------------------------------------------------------------------------------------------------------------------------
// 137199-001      55ns TriState SRAM (1k x 4b)

module moram
(
   input clk,
   input we_n, cs_n,
   input [7:0] addr,
   input [3:0] din,
   output reg [3:0] dout
);
   reg [3:0] mem [0:255];

   always @(posedge clk) 
   begin
      if (~we_n & ~cs_n) 
         mem[addr] <= din;
      else
         dout <= cs_n ? 4'b1111 : mem[addr];
   end

endmodule   



// --------------------------------------------------------------------------------------------------------------------------------
// 82S09            64 X 9 RAM

module cram82S09
(
   input clk,

   input ce_n, we_n,
   input [5:0] addr,
   input [8:0] din,
   output reg [8:0] dout
);
   reg [8:0] mem [0:63];

   always @(posedge clk) 
   begin
      if (we_n == 1'b0) 
         mem[addr] <= din;
      else if (ce_n == 1'b0) 
         dout <= mem[addr];
   end

endmodule   



// --------------------------------------------------------------------------------------------------------------------------------
// POTATO   137321-1111         Custom, Vertical Scroll

module potato
(
   input clr_n,
   input load_n,
   input ce_n,
   input dwnup,
   input clk,
   input [7:0] p,
   output reg [7:0] q
);

always @(posedge clk or negedge clr_n or negedge load_n) 
   begin
      if(~clr_n)
         q <= #1 8'b0000;
      else if(~load_n)
         q <= #1 p;
      else if(~ce_n & ~dwnup)
         q <= #1 q + 8'b0001;
      else if(~ce_n & dwnup)
         q <= #1 q - 8'b0001;
   end
endmodule



// --------------------------------------------------------------------------------------------------------------------------------
// AM2764      8K x 8-Bit EPROM

module rom2764 # ( parameter INIT_FILE = "rom.txt" )
(
   input clk,
   input en,
   input [12:0] addr,
   output reg [7:0] data
);
   reg [7:0] mem [0:8191];

   always @(posedge clk) 
   begin
      if (en == 1'b1) 
         data <= mem[addr];
   end

   initial begin
      $readmemh(INIT_FILE, mem);         // read hex values, one per line (use // for comment)
   end

endmodule   

// --------------------------------------------------------------------------------------------------------------------------------
// TMS4416      16k x 4b DRAM

module dram4416 # ( parameter INIT_FILE = "init.txt" )
 (
   input clk,
   
   input rasn, casn,
   input gn, wn,
   input [7:0] a,
   input [3:0] din,
   output reg [3:0] dout
);
   reg [3:0] mem [0:16383];
   reg [13:0] addr;

   always @(negedge rasn) addr[7:0] = a;
   always @(negedge casn) addr[13:8] = a[6:1];

   always @(posedge clk) 
   begin
      if (wn == 1'b0 & casn == 1'b0) 
         mem[addr] <= din;
      else if (gn == 1'b0 & casn == 1'b0) 
         dout <= mem[addr];
   end

initial begin
   $readmemh(INIT_FILE, mem);
end

endmodule   


// --------------------------------------------------------------------------------------------------------------------------------
// Pokey-IP wrapper

module PokeyW
(
   input            clk,
   input            rst_n,
   input  [3:0]   ad,
   input            cs,
   input            we,
   input  [7:0]   data_to_pokey,
   output [7:0]   data_from_pokey,

   output [5:0]   snd,
   input  [7:0]   p
);

`ifdef RUNSIMULATION

reg [7:0] mem [0:15];
reg [5:0] snd_o;
reg [7:0] data_out;
always @(posedge clk)
begin
   if (~rst_n)
   begin
      snd_o <= 0;
   end
end
assign snd = snd_o;

always @(posedge clk) 
begin
   if (we & cs) 
      mem[ad] <= data_to_pokey;
   else data_out <= mem[ad];
end
assign data_from_pokey = data_out;

`else

wire [3:0] ch0,ch1,ch2,ch3;
pokey core 
(
   .RESET_N(rst_n),
   .CLK(clk),
   .ADDR(ad),
   .DATA_IN(data_to_pokey),
   .DATA_OUT(data_from_pokey),
   .WR_EN(we & cs),
   .ENABLE_179(1'b1),
   .POT_IN(~p),
   
   .CHANNEL_0_OUT(ch0),
   .CHANNEL_1_OUT(ch1),
   .CHANNEL_2_OUT(ch2),
   .CHANNEL_3_OUT(ch3)
);
assign snd = {2'b00,ch0}+{2'b00,ch1}+{2'b00,ch2}+{2'b00,ch3};

`endif
endmodule


// --------------------------------------------------------------------------------------------------------------------------------
// LETA
module LETA
(
   input clk, reset_n,
   input X1, Y1, X2, Y2, X3, Y3, X4, Y4,
   input [1:0] addr,
   output reg [7:0] data
);

wire [7:0] data1,data2,data3,data4;
quad_decoder qd1 ( .clk(clk), .reset_n(reset_n), .A(X1), .B(Y1), .count(data1));
quad_decoder qd2 ( .clk(clk), .reset_n(reset_n), .A(X2), .B(Y2), .count(data2));
quad_decoder qd3 ( .clk(clk), .reset_n(reset_n), .A(X3), .B(Y3), .count(data3));
quad_decoder qd4 ( .clk(clk), .reset_n(reset_n), .A(X4), .B(Y4), .count(data4));

always @(posedge clk)
begin
  case(addr)
    2'b00: data = data1;
    2'b01: data = data2;
    2'b10: data = data3;
    2'b11: data = data4;
  endcase
end

endmodule

// --------------------------------------------------------------------------------------------------------------------------------
// Quadrature decoder

module quad_decoder
(
   input clk, reset_n,
   input A, B, 
   output reg [7:0] count
);

reg [2:0] a_delayed, b_delayed;
always @(posedge clk) a_delayed <= {a_delayed[1:0], A};
always @(posedge clk) b_delayed <= {b_delayed[1:0], B};

wire ce = a_delayed[1] ^ a_delayed[2] ^ b_delayed[1] ^ b_delayed[2];
wire dir = a_delayed[1] ^ b_delayed[2];

always @(posedge clk or negedge reset_n)
begin
   if (~reset_n)
      count <= 0;
   else if(ce)
      begin
         if(dir) count<=count + 8'b00000001; else count<=count - 8'b00000001;
      end
end

endmodule