module ccastles
(
	// clock and reset
   input         clk,
   input         reset_n,

   // Game Options
   input         WDISn,
   input         SELFTEST,
   input         COCKTAILn,
   // Buttons
   input         START1, START2,
   input         JMP1, JMP2,
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
   
   // Debugging
   output [5:0]  test	
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
   reg [7:0] DI;
   wire [7:0] BD;
   wire [15:0] BA;
   wire BRWn, ROM2n, ROM1n, ROM0n, SBUSn;
	wire DRWR,WRITEn;
   
   always @(posedge H2) 
   begin
      if (BA[15] && NRn)            // 0xA000-0xFFFF
         DI <= #1 rom_to_cpu;
      else if (SRAMn == 1'b0)       // 0x8000-0x8FFF
         DI <= #1 sram_to_cpu;
      else if (IN0n == 1'b0)       // 0x9000-0x9BFF     // TODO split CIOn (pokey1/pokey2/IN0n/NVRAMn)
         DI <= #1 sbus_to_cpu;
      else if (CIOn == 1'b0)       // 0x9000-0x9BFF     // TODO split CIOn (pokey1/pokey2/IN0n/NVRAMn)
         DI <= #1 pokey_to_cpu;
      else if (BITRDn == 1'b0)
         DI <= #1 bmr_to_cpu;       // 0x0002
      else
         DI <= #1 dram_to_cpu;      // 0x0000-0x7FFF
   end

   MicroProcessor cpu
   (
      .clk(H2),        // runs on 2H
      .RESETn(reset_n & wd_reset_n),       
           
      .H1n(H1n),
      .INTACKn(INTACKn),
      .IRQCK(IRQCK),
      
      .data_to_cpu(DI),
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
      .BUF1BUF2n(),
      .SIREn(),
      .PLAYER2(PLAYER2),
      .STARTLED1(STARTLED1),
      .YINCn(YINCn), .XINCn(XINCn), .AYn(AYn), .AXn(AXn),
      .CIOn(CIOn), .IN0n(IN0n), .OUT0n(OUT0n),
      .BITRDn(BITRDn),
      .DRHn(DRHn), .DRLn(DRLn),
      .CRAMn(CRAMn), .NVRAMn(NVRAMn), .SBUSn(SBUSn), .SRAMn(SRAMn),
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
   DynamicRam dram
   (
      .clk(clk),
      .RASn(RASn), .CASn(CASn), .DRWR(DRWR),
      .DRAB(DRAB),
      .DRLn(DRLn), .DRHn(DRHn),
      .WP0n(WP0n), .WP1n(WP1n), .WP2n(WP2n), .WP3n(WP3n),
      .data_to_dram(data_to_dram), 
      .data_from_dram(dram_to_cpu)
      //. BIT2, BIT1, BIT0
   );
   
   // PositionControl
   // WorkingRam
   // NonVolatileRam
   
   // MotionObjectPictureROM
   // MotionObjectVerticalControl
   // MotionObjectBuffer
   // MotionObjectHorizontalControl
   
   wire [8:0] clr_data = BA[9:1];
   ColorMemory cmem
   (
      .CLK10(clk),
      .CLK5n(CLK5n),
      
      .CRAMn(CRAMn),
      .BD(BD),
      .BA(BA[5:0]),
      
      .MPI(BA[4]), .MV0(BA[5]), .MV1(BA[6]), .MV2(BA[7]),
      .BIT0(BA[0]), .BIT1(BA[1]), .BIT2(BA[2]), .BIT3(BA[3]),
      
      .o()
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
		
		.COCKTAILn(COCKTAILn),
		.START1(START1),
		.START2(START2),
		
      .pokey_to_cpu(pokey_to_cpu),
      .SOUT(SOUT)
   );
   
   // CoinCounterAndOutput
   
   PlayerSwitches ps
   (
      .BA9(BA[9]), 
      .IN0n(IN0n), 
      .JMP2(JMP2), .JMP1(JMP1), .SELFTEST(SELFTEST), .VBLANK(VBlank), .SLAM(1'b0), .COINAUX(1'b0), .COINL(COINL), .COINR(COINR),
      .SBD(sbus_to_cpu)
   );
     
   CoinCountOutput cco
   (
      .RESETn(reset_n), 
      .OUT0n(OUT0n),
      .BA(BA[2:0]),
      .BD0(BD[0]),
      
      .BANK0n(BANK0n), .BANK1n(BANK1n), 
      .COINCNTL_L(), .COINCNTLR(),
      .RECALLn(), .STORE(),
      .STARTLED2(STARTLED2), .LIGHTBULB(LIGHTBULB)
   );

   assign HBlank = HBLANK2;
   assign test = { CRAMn, WDOGn, OUT0n, wd_reset_n, VBlank, HBlank };

endmodule
