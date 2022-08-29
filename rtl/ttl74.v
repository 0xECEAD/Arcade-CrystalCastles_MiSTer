module ls74
(
	input  n_pre,
	input  n_clr,
	input  clk, 
	input  d, 
	output reg q,
   output n_q
);
always @(posedge clk or negedge n_pre or negedge n_clr) 
   begin
      if(!n_pre)
         q <= 1;
      else if(!n_clr)
         q <= 0;
      else
         q <= #1 d;
   end
   assign n_q = ~q;
endmodule


module ls109
(
	input  n_pre,
	input  n_clr,
	input  clk, 
	input  j, 
	input  k_n, 
	output reg q,
   output n_q
);
always @(posedge clk or negedge n_pre or negedge n_clr) 
begin
	if(!n_pre)
		q <= #1 1;
	else if(!n_clr)
		q <= #1 0;
	else
		case ({j, k_n})
         2'b01: q <= #1 q;
         2'b00: q <= #1 1'b0;
         2'b11: q <= #1 1'b1;
         2'b10: q <= #1 ~q;
		endcase
   end
   assign n_q = ~q;
endmodule



module ls160
(
	input n_load,
	input n_clr,
   input clk,
   
   input [3:0] p,   
   input ent, enp,
   
   output reg [3:0] q,
   output rco
);
always @(posedge clk or negedge n_clr)
   begin
		if(!n_clr)
         q <= #1 4'b0000;
		else if(!n_load)
         q <= p;
      else if(ent & enp)
         if (rco)
				q <= #1 4'b0000;
         else
				q <= #1 q + 4'b0001;
   end
   assign rco = ent & q == 4'b1001;
endmodule



module ls163
(
	input n_load,
	input n_clr,
   input clk,
   
   input [3:0] p,
   input ent, enp,
   
   output reg [3:0] q,
   output rco
);

always @(posedge clk) 
   begin
		if(!n_clr)
			q <= 4'b0000;
      else if(!n_load)
         q <= p;
      else if(ent & enp)
         q <= #1 q + 4'b0001;
   end
   assign rco = ent & q == 4'b1111;
endmodule

module ls175
(
	input  n_clr,
	input  clk, 
	input [3:0] d, 
	output reg [3:0] q,
   output [3:0] n_q
);
always @(posedge clk or negedge n_clr) 
   begin
      if(!n_clr)
         q <= 0;
      else
         q <= #1 d;
   end
   assign n_q = ~q;
endmodule

 module rom82S129
 (
   input clk,
   input en,
   input [7:0] addr,
   output reg [3:0] data
);

   reg [3:0] mem [0:256];

   always @(posedge clk) 
   begin
      if (en == 1'b1) 
         data <= mem[addr];
   end

   initial begin
      $readmemh("82s129-136022-108.7k.rom", mem);			// read hex values, one per line (use // for comment)
   end

endmodule	


module rom2764 # 
(
   parameter INIT_FILE = "rom.txt"
)
 (
   input clk,
   input en,
   input [12:0] addr,
   output reg [7:0] data
);

   reg [7:0] mem [0:8192];

   always @(posedge clk) 
   begin
      if (en == 1'b1) 
         data <= mem[addr];
   end

   initial begin
      $readmemh(INIT_FILE, mem);			// read hex values, one per line (use // for comment)
   end

endmodule	



module ls193
(
  input clr,			// async
  input n_load,		// async
  input up,
  input down,
  input [3:0] p,
  output co_n,
  output bo_n,
  output reg [3:0] q
);


always @(posedge clr or negedge n_load or posedge up or posedge down)
begin
  if (clr)
    q <= #1 4'b0000;
  else if (~n_load)
    q <= #1 p;
  else if (up)
    q <= #1 q + 4'b0001;
  else if (down)
    q <= #1 q - 4'b0001;
end

assign co_n = ~up & q == 4'b1111;
assign bo_n = ~down & q == 4'b0000;

endmodule