module ColorOutput
(
   input CLK5, 
   input VBLANK, HBLANK2, 
   input [8:0] data,
  
   output reg [8:0] RGB
);

wire clr_n = ~(HBLANK2 | VBLANK);

always @(posedge CLK5)
begin
   if (clr_n == 1'b0) RGB <= #1 9'd0;
   else RGB <= #1 data;
end

endmodule