module ccastles
(
	// clock and reset
   input         clk,
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
   output        HBlank,
	output        HSync,
	output        VBlank,
	output        VSync,
   output [8:0]  RGBout,

   // Sound
   output [7:0]  SOUT,
   
   // User Port
   input   [6:0] USER_IN,
   output  [6:0] USER_OUT
);

	wire [8:0] hc;
   wire CLK5n, HBLANK1n, HBLANK2, HBLANK;
   HorSyncChan hsc
   (
      .CLK10(clk),
      .RESETn(reset_n),
      
      .CLK5n(CLK5n),
      .HBLANK2(HBLANK2),
      .HBLANK1n(HBLANK1n),
      .HBLANK(HBLANK),
      .HSYNC(HSync),
		.hcount(hc)
   );
   
	wire [7:0] vc;
	wire INTACKn,IRQCK;
   VertSyncChan vsc
   (
      .CLK10(clk),
      .RESETn(reset_n),

      .HBLANK(HBLANK),
      .HSYNC(HSync),
		
		.VBLANK(VBlank),
		.VSYNC(VSync),
      .IRQCK(IRQCK),
		.vcount(vc)
   );
   
   wire WDOGn, wd_reset_n;
   Watchdog wd
   (
      .reset_n(reset_n),
		.WDISn(WDISn),
      .WDOGn(WDOGn),
      // ignored DCOK (no power fails on MiSTer)
      .VBLANK(VBlank),
      .WDRESETn(wd_reset_n)
   );

   wire H1n = ~hc[0];
   wire H2 = hc[1];           // 1.25 MHz
   wire [7:0] rom_to_cpu, sbus_to_cpu, sram_to_cpu, bmr_to_cpu, dram_to_cpu, nvram_to_cpu, pokey_to_cpu;
   wire [7:0] bmw_to_dram;
   reg [7:0] DIprep, DIhold;
   wire [7:0] BD;
   wire [15:0] BA;
   wire BRWn, ROM2n, ROM1n, ROM0n, SBUSn, UARTn;
	wire DRWR,WRITEn;
   
   always @(negedge H2) 
   begin
      if (BA[15])
         begin
            if (NRn)               // 0xA000-0xFFFF
               DIprep <= #1 rom_to_cpu;
            else if (SRAMn == 1'b0)          // 0x8000-0x8FFF
               DIprep <= #1 sram_to_cpu;
            else if (NVRAMn == 1'b0)         // 0x9000-0x93FF
               DIprep <= #1 nvram_to_cpu;
            else if (IN0n == 1'b0)           // 0x9400-0x97FF
               DIprep <= #1 sbus_to_cpu;
            else if (CIOn == 1'b0)           // 0x9800-0x9BFF
               DIprep <= #1 pokey_to_cpu;
               
         else if (BA[15:7] == 9'b100111000 & ~BA[0])
            DIprep <= #1 uart_to_cpu;
         else if (BA[15:7] == 9'b100111000 & BA[0])
            DIprep <= #1 {uart_rx_avail, 6'b000000, uart_tx_busy };
               
         end
      else 
         begin 
            if (BITRDn == 1'b0)
               DIprep <= #1 bmr_to_cpu;      // 0x0002
            else
               DIprep <= #1 dram_to_cpu;     // 0x0000-0x7FFF
         end
   end
   always @(posedge H2) DIhold <= #1 DIprep;
   

   MicroProcessor cpu
   (
      .clk(H2),        // runs on 2H
      .RESETn(reset_n & wd_reset_n),       
           
      .H1n(H1n),
      .INTACKn(INTACKn),
      .IRQCK(IRQCK),
      
      .data_to_cpu(DIhold),
      .data_from_cpu(BD),
     
      .BA(BA),
      .BRWn(BRWn),
      .DRWR(DRWR),
      .WRITEn(WRITEn)
   );
  
   wire BANK0n, BANK1n;
   ProgramMemory progmem
   (
      .clk(clk),
      .address(BA[12:0]),
      .rom2_n(ROM2n), .rom1_n(ROM1n), .rom0_n(ROM0n),
      .bank0_n(BANK0n), .bank1_n(BANK1n),
      .data(rom_to_cpu)
   );

   wire CIOn, IN0n, OUT0n, BITRDn;
   wire NRn, BITMDn,CRAMn,NVRAMn,SRAMn;
   wire YINCn, XINCn, AYn, AXn;
   wire PLAYER2, VSLDn, HSLDn, DRLn, DRHn;
   wire BUF1BUF2n;
   AddresDecoder ad
   (
      .RESETn(reset_n), 
      .CLK10(clk), 
      .BA(BA),
      .WRITEn(WRITEn),
      .BD3(BD[3]),
      .BH2(H2),
      .BITMDn(BITMDn),
      .PIXB(PIXB),
      .BRWn(BRWn),
      
      .WDOGn(WDOGn),
      .INTACKn(INTACKn),
      .VSLDn(VSLDn),
      .HSLDn(HSLDn),
      .BUF1BUF2n(BUF1BUF2n),
      .SIREn(),
      .PLAYER2(PLAYER2),
      .STARTLED1(STARTLED1),
      .YINCn(YINCn), .XINCn(XINCn), .AYn(AYn), .AXn(AXn),
      .CIOn(CIOn), .IN0n(IN0n), .OUT0n(OUT0n),
      .BITRDn(BITRDn),
      .DRHn(DRHn), .DRLn(DRLn),
      .CRAMn(CRAMn), .NVRAMn(NVRAMn), .SBUSn(SBUSn), .SRAMn(SRAMn), .UARTn(UARTn),
      .NRn(NRn), .DBUSn(), .ROM2n(ROM2n), .ROM1n(ROM1n),.ROM0n(ROM0n)
   );

   wire BITWRn, XCOORDn, YCOORDn;
   BitModeDecoder bmd
   (
      .BA(BA),
      .WRphi2n(~(H2 & ~BRWn)),
      .BITWRn(BITWRn), 
      .BITMDn(BITMDn), 
      .YCOORDn(YCOORDn), 
      .XCOORDn(XCOORDn)
   );
   
   wire [14:1] DRBA;
   wire PIXA, PIXB;
   AutoIncrement ai
   (
      .RESETn(reset_n),    
      .XCOORDn(XCOORDn), .XINCn(XINCn), .AXn(AXn), 
      .YCOORDn(YCOORDn), .YINCn(YINCn), .AYn(AYn), 
      .BITMDn(BITMDn), .Bphi2(H2),
      .BD(BD), .BA(BA), .DRBA(DRBA),
      .PIXA(PIXA), .PIXB(PIXB)
   );
   
   BitModeReadWrite bmdrw
   (
      .from_dram(dram_to_cpu),
      .PIXA(PIXA),
      .bmr_to_cpu(bmr_to_cpu),      // put on DI bus when BITRDn=0
      
      .from_cpu(BD),
      .bmw_to_dram(bmw_to_dram)    // put on DRAM write bus when BITWRn=0
   );

   wire [7:0] HL;
   HorizontalScrolling hscroll
   (
      .RESETn(reset_n),
      .CLK10(clk), 
      .CLK5(~CLK5n),
      .HBLANK1n(HBLANK1n), .VBLANK(VBlank), 
      .HSLDn(HSLDn), .PLAYER2(PLAYER2),
      .BD(BD),
      .HL(HL)
   );
   
	wire WP0n, WP1n, WP2n, WP3n;
   DynamicRamWriteProtection drwp
   (
      .clk(clk), .CLK5n(~CLK5n),
      .BA(BA), .DRBA(DRBA), .WRITEn(WRITEn),
      .PIXA(PIXA), .PIXB(PIXB), .BITMDn(BITMDn),
      
      .WP0n(WP0n), .WP1n(WP1n), .WP2n(WP2n), .WP3n(WP3n)
   );

   wire DEADSEL, CASn, RASn;
   DynamicRamControl dramctrl
   (
      .RESETn(reset_n), 
      .CLK10(clk), 
      .CLK5n(CLK5n),
      .H1n(H1n),
   
      .RASn(RASn),
      .CASn(CASn),
      .DEADSEL(DEADSEL)
   );
   
   wire [7:0] DRAB;
   AddresSelectors as
   (
      .RESETn(reset_n),
      .DEADSEL(DEADSEL), 
      .B2H(H2),
      .DRBA(DRBA),
      .HL(HL),
      .DRAB(DRAB),
      
      .BD(BD),
      .PLAYER2(PLAYER2), .HSYNCn(~HSync), .VBLANK(VBlank), .VSLDn(VSLDn)
   );

   wire [7:0] data_to_dram = !BITWRn ? bmw_to_dram : BD;
   wire [3:0] BIT;
   DynamicRam dram
   (
      .clk(clk),
      .RASn(RASn), .CASn(CASn), .DRWR(DRWR),
      .DRAB(DRAB),
      .DRLn(DRLn), .DRHn(DRHn),
      .WP0n(WP0n), .WP1n(WP1n), .WP2n(WP2n), .WP3n(WP3n),
      .data_to_dram(data_to_dram), 
      .data_from_dram(dram_to_cpu),
      .PLAYER2(PLAYER2), .CLK5n(CLK5n), .HL(HL),
      .BIT(BIT)
   );
   
   // PositionControl
   
   WorkingRam sram
   (
      .clk(clk),
      .SRAMn(SRAMn), .BRWn(BRWn), .B2H(H2), .WRITEn(WRITEn), 
      .BA(BA), .hcount(hc), .BUF1BUF2n(BUF1BUF2n),
      .data_to_sram(BD),
      .data_from_sram(sram_to_cpu)
   );

   NonVolatileRam nvram
   (
      .clk(clk),
      .NVRAMn(NVRAMn), 
      .WRphi2n(~(H2 & ~BRWn)),
      .BA(BA[7:0]),
      //.DCOKn, .STORE, .RECALLn, .SIREn,    // not used, maybe MiSTer framework can store nvram data?
      .data_to_nvram(BD),
      .data_from_nvram(nvram_to_cpu)
   ); 
   
   // MotionObjectPictureROM
   // MotionObjectVerticalControl
   // MotionObjectBuffer
   // MotionObjectHorizontalControl
   
   wire [8:0] clr_data;
   ColorMemory cmem
   (
      .CLK10(clk),
      .CLK5n(CLK5n),
      
      .CRAMn(CRAMn),
      .BD(BD),
      .BA(BA[5:0]),
      
      .MPI(1'b1), .MV0(1'b1), .MV1(1'b1), .MV2(1'b1),
      .BIT(BIT),
      
      .o(clr_data)
   );
   
   ColorOutput clrout
   (
      .CLK5(~CLK5n), 
      .VBLANK(VBlank), .HBLANK2(HBLANK2), 
      .data(clr_data),
      .RGB(RGBout)
   );

   // TrackBallInput

   AudioOutput ao
   (
      .reset_n(reset_n),
      .clk(H2),
      .BA(BA),
      .CIOn(CIOn),
      .BRWn(BRWn),
      .BD(BD),
		
		.COCKTAIL(COCKTAIL),
		.STARTJMP1(STARTJMP1),
		.STARTJMP2(STARTJMP2),
		
      .pokey_to_cpu(pokey_to_cpu),
      .SOUT(SOUT)
   );
    
   PlayerSwitches ps
   (
      .BA9(BA[9]), 
      .IN0n(IN0n), 
      .JMP2(STARTJMP2), .JMP1(STARTJMP1), .SELFTEST(SELFTEST), .VBLANK(VBlank), .SLAM(1'b0), .COINAUX(1'b0), .COINL(COINL), .COINR(COINR),
      .SBD(sbus_to_cpu)
   );
     
   wire COINCNTL_L;
   CoinCountOutput cco
   (
      .RESETn(reset_n), 
      .OUT0n(OUT0n),
      .BA(BA[2:0]),
      .BD0(BD[0]),
      
      .BANK0n(BANK0n), .BANK1n(BANK1n), 
      .COINCNTL_L(COINCNTL_L), .COINCNTLR(),
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
      else if (~UARTn & BA[0])         // 0x9C01      write clears avail reg
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

   wire WE = ~UARTn & ~BRWn & ~uart_tx_busy && ~WRITEn;
   uart_tx #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) utx (
      .i_Clock(clk),
      .i_Tx_DV(WE),
      .i_Tx_Byte(BD),
      .o_Tx_Active(uart_tx_busy),
      .o_Tx_Serial(TX),
      .o_Tx_Done()
   );

   assign RX = USER_IN[0];
   assign USER_OUT = { 1'b0, uart_rx_avail, RX, VBlank, HBlank, TX, 1'b1 };
`else

    assign USER_OUT = { 1'b0, 1'b0, 1'b0, VBlank, HBlank, 1'b0, 1'b0 };
    
`endif

   assign HBlank = HBLANK2;

endmodule
