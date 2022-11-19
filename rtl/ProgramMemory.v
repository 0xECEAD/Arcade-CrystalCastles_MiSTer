module ProgramMemory
(
   input clk,
   input [12:0] address,
   input ROM0n,ROM1n,ROM2n,
   input BANK0n, BANK1n,
   output reg [7:0] data_from_rom,
	
	input dn_clk, dn_wr,
	input [15:0] dn_addr,
	input [7:0] dn_data

);

wire [7:0] data_ic1F, data_ic1H, data_ic1K, data_ic1L, data_ic1N;


`ifdef RUNSIMULATION

rom2764 #(.INIT_FILE("136022-101.1f.rom")) ic1F
(
   .clk(clk), 
   .addr(address),
   .data(data_ic1F)
);

rom2764 #(.INIT_FILE("136022-102.1h.rom")) ic1H
(
   .clk(clk), 
   .addr(address),
   .data(data_ic1H)
);

rom2764 #(.INIT_FILE("136022-303.1k.rom")) ic1K
(
   .clk(clk), 
   .addr(address),
   .data(data_ic1K)
);

rom2764 #(.INIT_FILE("136022-304.1l.rom")) ic1L
(
   .clk(clk), 
   .addr(address),
   .data(data_ic1L)
);

rom2764 #(.INIT_FILE("136022-305.1n.rom")) ic1N
(
   .clk(clk), 
   .addr(address),
   .data(data_ic1N)
);

`else

wire prog_rom1F_we = dn_wr & (dn_addr[15:13] == 3'd0);
dprom2764 ic1F
(
   .a_clk(clk), 
   .a_addr(address),
   .a_data(data_ic1F),
	
	.b_clk(dn_clk),
	.b_we(prog_rom1F_we),
	.b_addr(dn_addr[12:0]),
	.b_data(dn_data)
);

wire prog_rom1H_we = dn_wr & (dn_addr[15:13] == 3'd1);
dprom2764 ic1H
(
   .a_clk(clk), 
   .a_addr(address),
   .a_data(data_ic1H),
	
	.b_clk(dn_clk),
	.b_we(prog_rom1H_we),
	.b_addr(dn_addr[12:0]),
	.b_data(dn_data)
);

wire prog_rom1K_we = dn_wr & (dn_addr[15:13] == 3'd4);
dprom2764 ic1K
(
   .a_clk(clk), 
   .a_addr(address),
   .a_data(data_ic1K),
	
	.b_clk(dn_clk),
	.b_we(prog_rom1K_we),
	.b_addr(dn_addr[12:0]),
	.b_data(dn_data)
);

wire prog_rom1L_we = dn_wr & (dn_addr[15:13] == 3'd5);
dprom2764 ic1L
(
   .a_clk(clk), 
   .a_addr(address),
   .a_data(data_ic1L),
	
	.b_clk(dn_clk),
	.b_we(prog_rom1L_we),
	.b_addr(dn_addr[12:0]),
	.b_data(dn_data)
);

wire prog_rom1N_we = dn_wr & (dn_addr[15:13] == 3'd6);
dprom2764 ic1N
(
   .a_clk(clk), 
   .a_addr(address),
   .a_data(data_ic1N),
	
	.b_clk(dn_clk),
	.b_we(prog_rom1N_we),
	.b_addr(dn_addr[12:0]),
	.b_data(dn_data)
);
`endif


always @(*)
begin
   if (~ROM1n) data_from_rom = ~BANK0n ? data_ic1L : data_ic1F;
   else if (~ROM0n) data_from_rom = ~BANK0n ? data_ic1K : data_ic1H;
   else /*if (~ROM2n)*/ data_from_rom = data_ic1N;
end

endmodule