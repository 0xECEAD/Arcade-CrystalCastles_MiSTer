module CCastles   
(
   // clock and reset
   input         clk,         // 10MHz
   input         reset_n,

   // Game Options
   input         WDISn,
   input         SELFTEST,
   input         COCKTAIL,
   // Buttons
   input         STARTJMP1, STARTJMP2,
   input         COINL, COINR,
   // Outputs
   output        STARTLED1, STARTLED2,
   output        LIGHTBULB,
   
   // Video
   output        HBLANK,
   output        HSYNC,
   output        VBLANK,
   output        VSYNC,
   output [8:0]  RGBout,

   // Sound
   output [7:0]  SOUT,
   
   // User Port
   input   [6:0] USER_IN,
   output  [6:0] USER_OUT
);


wire ce5, ce1H, ce2H, ce2Hd;
Clock clkgen
(
   .clk(clk), .reset_n(reset_n),
   .ce5(ce5), .ce1H(ce1H), .ce2H(ce2H), .ce2Hd(ce2Hd)
);

wire IRQCLK;
wire [8:0] hc;
wire [7:0] vc;
SyncChain sc
(
   .clk(clk), .reset_n(reset_n), .ce5(ce5),
   
   .hcount(hc), .vcount(vc),
   .HSYNC(HSYNC), .HBLANK(HBLANK),
   .VSYNC(VSYNC), .VBLANK(VBLANK),
   .IRQCLK(IRQCLK)
);

wire WDOGn, wd_reset_n;
Watchdog wd
(
   .clk(clk), .reset_n(reset_n),
   
   .WDISn(WDISn),
   .WDOGn(WDOGn),
   .VBLANK(VBLANK),
   .WDRESETn(wd_reset_n)
);

wire BANK0n, BANK1n;
ProgramMemory rom
(
   .clk(clk),
   .address(BA[12:0]),
   .ROM2n(ROM2n), .ROM1n(ROM1n), .ROM0n(ROM0n),
   .BANK0n(BANK0n), .BANK1n(BANK1n),
   .data_from_rom(rom_to_cpu)
);

wire [15:0] BA;
wire [7:0] BD;
reg [7:0] DI;
wire INTACKn, BRWn;
MicroProcessor cpu
(
   .clk(clk), .ce2H(ce2H), .ce2Hd(ce2Hd),
   .reset_n(reset_n & wd_reset_n),       
        
   .INTACKn(INTACKn),
   .IRQCLK(IRQCLK),
   .BRWn(BRWn),
   
   .BA(BA),
   .data_to_cpu(DI),
   .data_from_cpu(BD)  
);


wire [7:0] rom_to_cpu, sram_to_cpu, bmr_to_cpu, dram_to_cpu, nvram_to_cpu, pokey_to_cpu;
wire [7:0] playerSwitches = { STARTJMP2, STARTJMP1, VBLANK, SELFTEST, 1'b0, 1'b0, COINL, COINR };         // ic11C

always @(posedge clk) 
begin
   if (BA[15])
      begin
         if (NRn)                            // 0xA000-0xFFFF
            DI <= #1 rom_to_cpu;
         else if (~SRAMn)                    // 0x8000-0x8FFF
            DI <= #1 sram_to_cpu;
         else if (NVRAMn == 1'b0)            // 0x9000-0x93FF
            DI <= #1 nvram_to_cpu;
         else if (~IN0n & BA[9])             // 0x9400-0x97FF
            DI <= #1 playerSwitches;
         else if (~CIOn)                     // 0x9800-0x9BFF
            DI <= #1 pokey_to_cpu;
            
`ifdef RUNDIAGNOSTIC               
         else if (~UARTn & ~BA[0])
            DI <= #1 uart_to_cpu;
         else if (~UARTn & BA[0])
            DI <= #1 {uart_rx_avail, 6'b000000, uart_tx_busy };
`endif
      end  
   else 
      DI <= #1 dram_to_cpu;                  // 0x0000-0x7FFF
end

wire CIOn, IN0n, OUT0n, OUT1n;
wire CRAMn, NVRAMn, SBUSn, SRAMn, UARTn;
wire NRn, ROM0n, ROM1n, ROM2n;
wire VSLDn, HSLDn, BITMDn, XCOORDn, YCOORDn;
AddresDecoder ad
(
   .clk(clk), .ce2H(ce2H), .ce2Hd(ce2Hd),
   .BA(BA), .BRWn(BRWn),
   
   .NRn(NRn), .ROM2n(ROM2n), .ROM1n(ROM1n), .ROM0n(ROM0n),
   
   .WDOGn(WDOGn), .INTACKn(INTACKn), .VSLDn(VSLDn), .HSLDn(HSLDn), .UARTn(UARTn),
   .CIOn(CIOn), .IN0n(IN0n), .OUT0n(OUT0n), .OUT1n(OUT1n), 
   .CRAMn(CRAMn), .NVRAMn(NVRAMn), .SBUSn(SBUSn), .SRAMn(SRAMn),
   
   .BITMDn(BITMDn), .XCOORDn(XCOORDn), .YCOORDn(YCOORDn)
);


wire [14:0] DRBA;
wire PIXA;
AutoIncrement ai
(
   .clk(clk), .reset_n(reset_n), .ce2Hd(ce2Hd),
   .BITMDn(BITMDn), .BD(BD), .BA(BA),
   
   .XCOORDn(XCOORDn), .XINCn(XINCn), .AXn(AXn), 
   .YCOORDn(YCOORDn), .YINCn(YINCn), .AYn(AYn), 
   .DRBA(DRBA), .PIXA(PIXA)
);


reg [7:0] hs;
wire HBLANK1 = HBLANK;     // TODO delay 4H  (16 pixels? )
always @(posedge clk or negedge reset_n) 
begin
   if(~reset_n)
        hs <= #1 8'b0000000;
   else if (~HSLDn)
        hs <= #1 BD;
   else if(ce5 & ~VBLANK & ~HBLANK1)
      begin
         if (PLAYER2)
            hs <= #1 hs - 8'b00000001;
         else
            hs <= #1 hs + 8'b00000001;
      end
end

reg [7:0] vs;
reg HSYNCd;
always @(posedge clk or negedge reset_n) 
begin
   if(~reset_n)
        vs <= #1 8'b0000000;
   else if (~VSLDn)
        vs <= #1 BD;
   else 
      begin
         HSYNCd <= #1 HSYNC;
         if (HSYNCd & ~HSYNC)
         begin
            if (PLAYER2)
               vs <= #1 vs - 8'b00000001;
            else
               vs <= #1 vs + 8'b00000001;
            end
      end
end


wire [3:0] BIT;
DynamicRam dram
(
   .clk(clk), .ce2Hd(ce2Hd), .ce5(ce5),
   .DRAMn(BA[15]), .BRWn(BRWn),
   .BITMDn(BITMDn), .PIXA(PIXA),
   .DRBA(DRBA), .BD(BD), 
   .hs(hs), .vs(vs),
   .dram_to_cpu(dram_to_cpu),
   .BIT(BIT)
);


WorkingRam sram
(
   .clk(clk), .ce2Hd(ce2Hd),
   .BA(BA),
   .SRAMn(SRAMn), .BRWn(BRWn),
   //.hcount(hc), .BUF1BUF2n(BUF1BUF2n),
   .data_to_sram(BD),
   .data_from_sram(sram_to_cpu)
);

NonVolatileRam nvram
(
   .clk(clk), .ce2Hd(ce2Hd),
   .NVRAMn(NVRAMn), .BRWn(BRWn),
   .BA(BA[7:0]),
   //.DCOKn, .STORE, .RECALLn, .SIREn,    // not used, maybe MiSTer framework can store nvram data?
   .data_to_nvram(BD),
   .data_from_nvram(nvram_to_cpu)
); 


AudioOutput ao
(
   .clk(clk), .reset_n(reset_n), .ce2Hd(ce2Hd),
   
   .BA(BA), .BD(BD),
   .CIOn(CIOn), .BRWn(BRWn),
   
   .COCKTAIL(COCKTAIL),
   .STARTJMP1(STARTJMP1),
   .STARTJMP2(STARTJMP2),
   
   .pokey_to_cpu(pokey_to_cpu),
   .SOUT(SOUT)
);

wire [8:0] clr_data;
ColorMemory cmem
(
   .clk(clk), .ce5(ce5),
   .CRAMn(CRAMn), .BD(BD), .BA(BA[5:0]),
   
   .MV(4'b1111),
   .BIT(BIT),
  
   .o(clr_data)
);


wire YINCn, XINCn, AYn, AXn;
wire BUF1BUF2n, PLAYER2, SIREn;
AutoIncOutput aio
(
   .clk(clk), .reset_n(reset_n), 
   .OUT1n(OUT1n),
   .BA(BA[2:0]), .BD3(BD[3]),
   
   .BUF1BUF2n(BUF1BUF2n), .STARTLED1(STARTLED1), 
   .SIREn(SIREn), .PLAYER2(PLAYER2),
   .YINCn(YINCn), .XINCn(XINCn),
   .AYn(AYn), .AXn(AXn)
);

wire COINCNTL_L;
CoinCountOutput cco
(
   .clk(clk), .reset_n(reset_n), 
   .OUT0n(OUT0n),
   .BA(BA[2:0]), .BD0(BD[0]),
   
   .BANK0n(BANK0n), .BANK1n(BANK1n), 
   .COINCNTL_L(COINCNTL_L), .COINCNTL_R(),
   .RECALLn(), .STORE(),
   .STARTLED2(STARTLED2), .LIGHTBULB(LIGHTBULB)
);


`ifdef RUNDIAGNOSTIC

// 10000000 / 115200 = 87 clocks per bit.
parameter c_CLKS_PER_BIT = 87;

wire RX, TX;
wire uart_rx_done, uart_tx_busy;
reg uart_rx_avail;
wire [7:0] uart_to_cpu;

always @(posedge clk or negedge reset_n) 
begin
   if(~reset_n)
        uart_rx_avail <= #1 1'b0;
   else if (~UARTn & BA[0] & ~BRWn)         // 0x9C01      write clears avail reg
        uart_rx_avail <= #1 1'b0;
   else if (uart_rx_done)
        uart_rx_avail <= #1 1'b1;
end

uart_rx #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) urx (
   .i_Clock(clk),
   .i_Rx_Serial(RX),
   .o_Rx_DV(uart_rx_done),
   .o_Rx_Byte(uart_to_cpu)
);

wire WE = ~UARTn & ~BRWn & ~uart_tx_busy && ce2Hd;
uart_tx #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) utx (
   .i_Clock(clk),
   .i_Tx_DV(WE),
   .i_Tx_Byte(BD),
   .o_Tx_Active(uart_tx_busy),
   .o_Tx_Serial(TX),
   .o_Tx_Done()
);

assign RX = USER_IN[0];
assign USER_OUT = { 1'b0, uart_rx_avail, RX, VBLANK, HBLANK, TX, 1'b1 };
`else
    assign USER_OUT = { 1'b0, 1'b0, 1'b0, VBLANK, HBLANK, 1'b0, 1'b0 };
`endif

assign RGBout = HBLANK | VBLANK ? 9'b000000000 : clr_data; 

endmodule

