module PlayerSwitches
(
   input BA9, 
   input IN0n, 
   
   input JMP2, JMP1, SELFTEST, VBLANK, SLAM, COINAUX, COINL, COINR,
   
   output reg [7:0] SBD
);

always @(*)
begin
   if (BA9 & ~IN0n)  SBD <= #1 { JMP2, JMP1, VBLANK, SELFTEST, SLAM, COINAUX, COINL, COINR };
end

endmodule