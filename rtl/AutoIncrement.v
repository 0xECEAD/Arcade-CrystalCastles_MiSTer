module AutoIncrement
(
   input clk, reset_n, ce2H,

   input [15:0] BA,
   input [7:0] BD,
   input BITMDn,
   
   input XCOORDn, XINCn, AXn, 
   input YCOORDn, YINCn, AYn, 
   
   output [14:0] DRBA,
   output PIXA
);

assign DRBA = ~BITMDn ? {yCoord,xCoord[7:1]} : BA[14:0];
reg [7:0] xCoord, yCoord;
assign PIXA = xCoord[0];


always @(posedge clk or negedge reset_n) 
begin
   if(~reset_n)
        xCoord <= #1 8'b0000000;
   else if(~XCOORDn)
        xCoord <= #1 BD;
   else if(~AXn & ~BITMDn & ce2H)
      begin
         if (XINCn)
            xCoord <= #1 xCoord - 8'b00000001;
         else
            xCoord <= #1 xCoord + 8'b00000001;
      end
end

always @(posedge clk or negedge reset_n) 
begin
   if(~reset_n)
        yCoord <= #1 8'b0000000;
   else if(~YCOORDn)
        yCoord <= #1 BD;
   else if(~AYn & ~BITMDn & ce2H)
      begin
         if (YINCn)
            yCoord <= #1 yCoord - 8'b00000001;
         else
            yCoord <= #1 yCoord + 8'b00000001;
      end
end

endmodule