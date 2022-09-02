module CoinCountOutput
(
   input RESETn, OUT0n, BD0,
   input [2:0] BA, 
    
   output BANK0n, BANK1n, 
   output COINCNTL_L, COINCNTLR,
   output RECALLn, STORE,
   output STARTLED2, LIGHTBULB
);
   
   wire Q2,Q3;
   ls259 ic8N
   (
      .a(BA[0]),
      .b(BA[1]),
      .c(BA[2]),
      .d(BD0),
      .g_n(OUT0n),
      .clr_n(RESETn),
      .q({BANK0n,COINCNTL_L,COINCNTLR,RECALLn,Q3,Q2,STARTLED2,LIGHTBULB})
   ); 

   assign BANK1n = ~BANK0n;
   assign STORE = ~Q2 & Q3;
   
endmodule