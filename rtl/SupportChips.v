// --------------------------------------------------------------------------------------------------------------------------------
// AM2764      8K x 8-Bit EPROM

module rom2764 # ( parameter INIT_FILE = "rom.txt" )
(
   input clk,
   input [12:0] addr,
   output reg [7:0] data
);

reg [7:0] mem [0:8191];

always @(posedge clk) data <= mem[addr];

initial begin
   $readmemh(INIT_FILE, mem);
end

endmodule   


// --------------------------------------------------------------------------------------------------------------------------------
// AM2764      8K x 8-Bit EPROM				Dual port version for Rom Downloader

module dprom2764
(
   input a_clk,
   input [12:0] a_addr,
   output reg [7:0] a_data,
	
   input b_clk, b_we,
   input [12:0] b_addr,
   input [7:0] b_data
);

reg [7:0] mem [0:8191];

always @(posedge a_clk) a_data <= mem[a_addr];
always @(posedge b_clk) if (b_we) mem[b_addr] <= b_data;

endmodule   

// --------------------------------------------------------------------------------------------------------------------------------
// TMS4416      16k x 4b DRAM (x4)     combined into single 32k x 8b SRAM

module dram
 (
   input clk,
   input we,
   input [14:0] addr,
   input [7:0] din,
   output reg [7:0] dout
);
reg [7:0] mem [0:32767];

always @(posedge clk) 
begin
   if (we) 
      mem[addr] <= din;
   else
      dout <= #1 mem[addr];
end
endmodule   


// --------------------------------------------------------------------------------------------------------------------------------
// CDW6116      200ns TriState SRAM (2k x 8b)   

module sram
(
   input clk,
   input we, 
   input [10:0] addr,
   input [7:0] din,
   output reg [7:0] dout
);

reg [7:0] mem [0:2047];

always @(posedge clk) 
begin
   if (we) 
      mem[addr] <= din;
   else
      dout <= mem[addr];
end
endmodule



// --------------------------------------------------------------------------------------------------------------------------------
// X2212      Non volatile RAM   256x4 (2x)           combined into single 256 x 8b SRAM (with shadow for store/recall operations)

module nvram 
(
   input clk, we, reset_n,
   input store, recall,
   input [7:0] addr,
   input [7:0] din,
   output [7:0] dout
);

reg [7:0] mem1 [0:255];
reg [7:0] mem2 [0:255];
reg bank, store_d, recall_d, storing;
reg [8:0] counter;

always @(posedge clk or negedge reset_n) 
begin
   if (~reset_n)
   begin
      bank <= #1 0;
      storing <= #1 0;
      counter <= #1 9'b000000000;
   end
   else
   begin
      store_d <= #1 store;
      recall_d <= #1 recall;
      
      if (~recall_d && recall) bank <= #1 ~bank;
      if (~storing & ~store_d && store) storing <= #1 1'b1;
      if (storing) counter <= #1 counter + 9'b000000001;
      if (counter == 9'b111111111) storing <= #1 1'b0;
   end
end

// bank:  0 = mem1(ram), mem2(shadow)     => copy mem1=>mem2
//        1 = mem2(ram), mem1(shadow)     => copy mem2=>mem1

reg [7:0] dout1, dout2;
wire [7:0] a = storing ? counter[8:1] : addr;
assign dout = bank ? dout2 : dout1;
wire we1 = storing ? bank & counter[0] : ~bank & we;
wire [7:0] din1 = storing ? dout2 : din;
wire we2 = storing ? ~bank & counter[0] : bank & we;
wire [7:0] din2 = storing ? dout1 : din;

always @(posedge clk) 
begin
   if (we1) mem1[a] <= din1;
   else dout1 <= mem1[a];
end

always @(posedge clk) 
begin
   if (we2) mem2[a] <= din2;
   else dout2 <= mem2[a];
end

initial begin
   $readmemh("nvram.rom", mem2);         // nvram content in shadow, game recalls at boot
end

endmodule   


// --------------------------------------------------------------------------------------------------------------------------------
// 137199-001      55ns TriState SRAM (1k x 4b)

module moram
(
   input clk,
   input we, cs,
   input [7:0] addr,
   input [3:0] din,
   output reg [3:0] dout
);

reg [3:0] mem [0:255];

always @(posedge clk) 
begin
   if (we & cs) 
      mem[addr] <= din;
   else
      dout <= mem[addr];
end

endmodule   




// --------------------------------------------------------------------------------------------------------------------------------
// 82S09            64 X 9 RAM      Color RAM

module cram82S09
(
   input clk,

   input we,
   input [4:0] addr,
   input [8:0] din,
   output reg [8:0] dout
);
reg [8:0] mem [0:31];

always @(posedge clk) 
begin
   if (we) 
      mem[addr] <= din;
   else
      dout <= mem[addr];
end

initial begin
   $readmemh("cram.rom", mem);         // initial colors at boot
end

endmodule   


// --------------------------------------------------------------------------------------------------------------------------------
// Pokey-IP wrapper

module PokeyW
(
   input clk, 
   input ce,
   input rst_n,
   input [3:0] ad,
   input cs,
   input we,
   input [7:0]  data_to_pokey,
   output [7:0] data_from_pokey,
   output [5:0] snd,
   input  [7:0] p
);

wire [3:0] ch0,ch1,ch2,ch3;
pokey core 
(
   .reset_n(rst_n),
   .clk(clk), .ce(ce),
   .addr(ad),
   .data_in(data_to_pokey),
   .data_out(data_from_pokey),
   .wr_en(we & cs),
   .enable_179(1'b1),
   .pot_in(~p),
   
   .channel_0_out(ch0),
   .channel_1_out(ch1),
   .channel_2_out(ch2),
   .channel_3_out(ch3)
);
assign snd = {2'b00,ch0}+{2'b00,ch1}+{2'b00,ch2}+{2'b00,ch3};
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
   output [7:0] count
);

reg [2:0] a_delayed, b_delayed;
always @(posedge clk) a_delayed <= {a_delayed[1:0], A};
always @(posedge clk) b_delayed <= {b_delayed[1:0], B};

wire ce = a_delayed[1] ^ a_delayed[2] ^ b_delayed[1] ^ b_delayed[2];
wire dir = a_delayed[1] ^ b_delayed[2];

reg [8:0] counter;
always @(posedge clk or negedge reset_n)
begin
   if (~reset_n)
      counter <= 0;
   else if(ce)
      begin
         if(dir) counter <= counter + 9'b000000001; else counter <= counter - 9'b000000001;
      end
end
assign count = counter[8:1];
endmodule