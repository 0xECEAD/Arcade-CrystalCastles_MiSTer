`timescale 1 ns / 10 ps

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
      .SELFTEST(1'b1),
      .COCKTAILn(1'b0),
      .START1(1'b0), .START2(1'b0),
      .JMP1(1'b0), .JMP2(1'b0),
      .COINL(1'b0), .COINR(1'b0)     
   );

    
   // Run simulation (output to .vcd file)
   initial begin
    
      // Create simulation output file 
      $dumpfile("ccastle_tb.vcd");
      $dumpvars(0, ccastles_tb);
        
      // Wait for 18 ms (16.39 ms per frams)
      #18000000
        
      // Notify and end simulation
      $display("Finished!");
      $finish;
   end
    
endmodule