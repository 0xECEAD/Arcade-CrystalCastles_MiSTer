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
// TMS4416      16k x 4b DRAM (x4)     combined into single 32k x 8b SRAM

module dram # ( parameter INIT_FILE = "init.txt" )
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

initial begin
   $readmemh(INIT_FILE, mem);
end


endmodule   


// --------------------------------------------------------------------------------------------------------------------------------
// CDW6116      200ns TriState SRAM (2k x 8b)   

module sram # ( parameter INIT_FILE = "init.txt" )
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

initial begin
   $readmemh(INIT_FILE, mem);
end
  
endmodule



// --------------------------------------------------------------------------------------------------------------------------------
// X2212      Non volatile RAM   256x4 (2x)           combined into single 256 x 8b SRAM

module nvram # ( parameter INIT_FILE = "init.txt" )
(
   input clk,
   input we,
   input [7:0] addr,
   input [7:0] din,
   output reg [7:0] dout
);

reg [7:0] mem [0:255];

always @(posedge clk) 
begin
   if (we) 
      mem[addr] <= din;
   else 
      dout <= mem[addr];
end

initial begin
   $readmemh(INIT_FILE, mem);
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
reg [8:0] mem [0:32];

always @(posedge clk) 
begin
   if (we) 
      mem[addr] <= din;
   else
      dout <= mem[addr];
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

