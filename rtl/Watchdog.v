module Watchdog
(
   input clk,
   input reset_n,
   
   input WDISn,
   input WDOGn,
   input VBLANK,

   output WDRESETn
);
   
reg [3:0] count;

reg VBLANK2;
always @(posedge clk or negedge reset_n)        // ic8M
begin
   if (~reset_n)
      count <= #1 4'b0000;
   else 
   begin 
      VBLANK2 <= #1 VBLANK;
      if (~WDOGn)
         count <= #1 4'b0000;
      else if (~VBLANK2 & VBLANK & WDISn)
         count <= #1 count + 4'b0001;
   end
end
assign WDRESETn = ~count[3];

endmodule