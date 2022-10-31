module MotionObjectPictureRom
(
   input clk, ce5, ce2Hd5,
   input CK1, PLAYER2,
   input MATCHn, SHFT0, SHFT1,
   input [15:0] SR,
   input [4:0] addrlo,
   output reg [2:0] AR
);

reg [7:0] picture;
always @(posedge clk)                           // ic7A
begin
   if (CK1 & ce2Hd5) picture <= SR[7:0];
end

wire [12:0] addr = {picture, addrlo};
wire [7:0] data_ic8D,data_ic8B;
rom2764 #(.INIT_FILE("136022-106.8d.rom")) ic8D
(
   .clk(clk), 
   .addr(addr),
   .data(data_ic8D)
);
rom2764 #(.INIT_FILE("136022-107.8b.rom")) ic8B
(
   .clk(clk), 
   .addr(addr),
   .data(data_ic8B)
);

wire [3:0] nib3 = MATCHn ? 4'b1111 : data_ic8D[3:0];
wire [3:0] nib2 = MATCHn ? 4'b1111 : data_ic8B[7:4];
wire [3:0] nib1 = MATCHn ? 4'b1111 : data_ic8B[3:0];

reg [3:0] data_ic9D;
always @(posedge clk)           // ic9D
if(ce5)
   begin  
      case ({SHFT0, SHFT1})
      2'b00: data_ic9D <= #1 data_ic9D;
      2'b01: data_ic9D <= #1 {data_ic9D[2:0], 1'b0};
      2'b10: data_ic9D <= #1 {1'b0, data_ic9D[3:1]};
      2'b11: data_ic9D <= #1 nib3;
   endcase
end

reg [3:0] data_ic9B;
always @(posedge clk)           // ic9B
if(ce5)
   begin  
      case ({SHFT0, SHFT1})
      2'b00: data_ic9B <= #1 data_ic9B;
      2'b01: data_ic9B <= #1 {data_ic9B[2:0], 1'b0};
      2'b10: data_ic9B <= #1 {1'b0, data_ic9B[3:1]};
      2'b11: data_ic9B <= #1 nib2;
   endcase
end

reg [3:0] data_ic9C;
always @(posedge clk)           // ic9C
if(ce5)
   begin  
      case ({SHFT0, SHFT1})
      2'b00: data_ic9C <= #1 data_ic9C;
      2'b01: data_ic9C <= #1 {data_ic9C[2:0], 1'b0};
      2'b10: data_ic9C <= #1 {1'b0, data_ic9C[3:1]};
      2'b11: data_ic9C <= #1 nib1;
   endcase
end
   
always @(*)     // ic9A
begin
   AR = PLAYER2 ? { data_ic9D[0], data_ic9B[0], data_ic9C[0] } : { data_ic9D[3], data_ic9B[3], data_ic9C[3] };
end

endmodule