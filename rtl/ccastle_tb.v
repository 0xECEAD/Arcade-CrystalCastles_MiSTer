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

   // Instantiate the unit under test (UUT)
   CCastles uut
   (
      .clk(clk10),
      .reset_n(reset_n),
      
      .WDISn(1'b1),
      .SELFTEST(1'b1), .COCKTAIL(1'b0),
      .STARTJMP1(1'b0), .STARTJMP2(1'b0),
      .COINL(1'b0), .COINR(1'b0)     
   );

    
   // Run simulation (output to .vcd file)
   initial begin
    
      // Create simulation output file 
      $dumpfile("ccastle_tb.vcd");
      $dumpvars(0, ccastles_tb);
        
      // Wait for 84 ms (16.39 ms per frams) about 5 frames
      //#84000000

      // Wait for 4 ms
      #4000000
        
      // Notify and end simulation
      $display("Finished!");
      $finish;
   end
    
endmodule