// Watchdog


module watchdog(
   
   input WDIS,
   input WDOGn,
   input VBLANK,
   input DCOKn,

   output WDRESETn
);
   
   wire [3:0] count;

   ls193 ic8M
   (
     .clr(DCOKn),
     .n_load(~(~WDIS | ~WDOGn)),
     .up(VBLANK),
     .down(1'b1),
     .p(4'b1000),
     .q(count)
   );
   
   assign WDRESETn = count[3];

endmodule