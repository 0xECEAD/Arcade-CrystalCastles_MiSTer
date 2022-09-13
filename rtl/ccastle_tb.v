`timescale 1 ns / 10 ps

`define RUNSIMULATION
`define RUNDIAGNOSTIC

module ccastles_tb();

    // Generate clock signal: 1 / ((2 * 50) * 1 ns) = 10 MHz
    reg reset_n, clk10;
    always begin
        #50
        clk10 = ~clk10;
    end
    
   // Reset signal
   initial begin
      clk10 = 0;
      reset_n = 1;
      #15
      reset_n = 0;
      #300
      reset_n = 1;
   end


  
   // Generate Stimuli
   //reg [15:0] BA; always @(posedge clk10) if (~reset_n) begin H2 <= 0; BA <= 0; end else  H2 <= #1 ~H2;
   //reg H2; always @(posedge H2) BA <= #1 BA + 16;

   // Instantiate the unit under test (UUT)
   ccastles uut(
      .clk(clk10),
      .reset_n(reset_n),
      
      .WDISn(1'b1),
      .SELFTEST(1'b1),
      .COCKTAIL(1'b0),
      .STARTJMP1(1'b0), .STARTJMP2(1'b0),
      .COINL(1'b0), .COINR(1'b0)
      
   );

   // AddresDecoder addrdecod
   // (
      // .RESETn(reset_n), 
      // .CLK10(clk10), 
      // .BA(BA),
      // .WRITEn(1'b0),
      // .BD3(1'b0),
      // .BH2(H2),
      // .BITMDn(1'b1),
      // .PIXB(1'b0),
      // .BRWn(1'b1)
   // );

    
   // Run simulation (output to .vcd file)
   initial begin
    
      // Create simulation output file 
      $dumpfile("ccastle_tb.vcd");
      $dumpvars(0, ccastles_tb);
        
      // Wait for 18 ms (16.39 ms per frames)
      //#18000000
      #4000000
        
      // Notify and end simulation
      $display("Finished!");
      $finish;
   end
    
endmodule