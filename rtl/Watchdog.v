module Watchdog
(
	input reset_n,
   input WDISn,
   input WDOGn,
   input VBLANK,

   output WDRESETn
);
   
   reg [3:0] count;

   always @(posedge VBLANK or negedge reset_n or negedge WDISn or negedge WDOGn)
	begin
	   if (reset_n == 1'b0 || WDISn == 1'b0 || WDOGn == 1'b0)
			count <= 4'b0000;
		else 
			count <= count + 4'b0001;
	end
   assign WDRESETn = ~count[3];

endmodule