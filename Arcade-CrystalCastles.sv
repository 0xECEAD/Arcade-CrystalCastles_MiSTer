//============================================================================
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//
//============================================================================

module emu
(
	//Master input clock
	input         CLK_50M,

	//Async reset from top-level module.
	//Can be used as initial reset.
	input         RESET,

	//Must be passed to hps_io module
	inout  [48:0] HPS_BUS,

	//Base video clock. Usually equals to CLK_SYS.
	output        CLK_VIDEO,

	//Multiple resolutions are supported using different CE_PIXEL rates.
	//Must be based on CLK_VIDEO
	output        CE_PIXEL,

	//Video aspect ratio for HDMI. Most retro systems have ratio 4:3.
	//if VIDEO_ARX[12] or VIDEO_ARY[12] is set then [11:0] contains scaled size instead of aspect ratio.
	output [12:0] VIDEO_ARX,
	output [12:0] VIDEO_ARY,

	output  [7:0] VGA_R,
	output  [7:0] VGA_G,
	output  [7:0] VGA_B,
	output        VGA_HS,
	output        VGA_VS,
	output        VGA_DE,    // = ~(VBlank | HBlank)
	output        VGA_F1,
	output [1:0]  VGA_SL,
	output        VGA_SCALER, // Force VGA scaler
	output        VGA_DISABLE, // analog out is off

	input  [11:0] HDMI_WIDTH,
	input  [11:0] HDMI_HEIGHT,
	output        HDMI_FREEZE,

`ifdef MISTER_FB
	// Use framebuffer in DDRAM
	// FB_FORMAT:
	//    [2:0] : 011=8bpp(palette) 100=16bpp 101=24bpp 110=32bpp
	//    [3]   : 0=16bits 565 1=16bits 1555
	//    [4]   : 0=RGB  1=BGR (for 16/24/32 modes)
	//
	// FB_STRIDE either 0 (rounded to 256 bytes) or multiple of pixel size (in bytes)
	output        FB_EN,
	output  [4:0] FB_FORMAT,
	output [11:0] FB_WIDTH,
	output [11:0] FB_HEIGHT,
	output [31:0] FB_BASE,
	output [13:0] FB_STRIDE,
	input         FB_VBL,
	input         FB_LL,
	output        FB_FORCE_BLANK,

`ifdef MISTER_FB_PALETTE
	// Palette control for 8bit modes.
	// Ignored for other video modes.
	output        FB_PAL_CLK,
	output  [7:0] FB_PAL_ADDR,
	output [23:0] FB_PAL_DOUT,
	input  [23:0] FB_PAL_DIN,
	output        FB_PAL_WR,
`endif
`endif

	output        LED_USER,  // 1 - ON, 0 - OFF.

	// b[1]: 0 - LED status is system status OR'd with b[0]
	//       1 - LED status is controled solely by b[0]
	// hint: supply 2'b00 to let the system control the LED.
	output  [1:0] LED_POWER,
	output  [1:0] LED_DISK,

	// I/O board button press simulation (active high)
	// b[1]: user button
	// b[0]: osd button
	output  [1:0] BUTTONS,

	input         CLK_AUDIO, // 24.576 MHz
	output [15:0] AUDIO_L,
	output [15:0] AUDIO_R,
	output        AUDIO_S,   // 1 - signed audio samples, 0 - unsigned
	output  [1:0] AUDIO_MIX, // 0 - no mix, 1 - 25%, 2 - 50%, 3 - 100% (mono)

	//ADC
	inout   [3:0] ADC_BUS,

	//SD-SPI
	output        SD_SCK,
	output        SD_MOSI,
	input         SD_MISO,
	output        SD_CS,
	input         SD_CD,

	//High latency DDR3 RAM interface
	//Use for non-critical time purposes
	output        DDRAM_CLK,
	input         DDRAM_BUSY,
	output  [7:0] DDRAM_BURSTCNT,
	output [28:0] DDRAM_ADDR,
	input  [63:0] DDRAM_DOUT,
	input         DDRAM_DOUT_READY,
	output        DDRAM_RD,
	output [63:0] DDRAM_DIN,
	output  [7:0] DDRAM_BE,
	output        DDRAM_WE,

	//SDRAM interface with lower latency
	output        SDRAM_CLK,
	output        SDRAM_CKE,
	output [12:0] SDRAM_A,
	output  [1:0] SDRAM_BA,
	inout  [15:0] SDRAM_DQ,
	output        SDRAM_DQML,
	output        SDRAM_DQMH,
	output        SDRAM_nCS,
	output        SDRAM_nCAS,
	output        SDRAM_nRAS,
	output        SDRAM_nWE,

`ifdef MISTER_DUAL_SDRAM
	//Secondary SDRAM
	//Set all output SDRAM_* signals to Z ASAP if SDRAM2_EN is 0
	input         SDRAM2_EN,
	output        SDRAM2_CLK,
	output [12:0] SDRAM2_A,
	output  [1:0] SDRAM2_BA,
	inout  [15:0] SDRAM2_DQ,
	output        SDRAM2_nCS,
	output        SDRAM2_nCAS,
	output        SDRAM2_nRAS,
	output        SDRAM2_nWE,
`endif

	input         UART_CTS,
	output        UART_RTS,
	input         UART_RXD,
	output        UART_TXD,
	output        UART_DTR,
	input         UART_DSR,

	// Open-drain User port.
	// 0 - D+/RX
	// 1 - D-/TX
	// 2..6 - USR2..USR6
	// Set USER_OUT to 1 to read from USER_IN.
	input   [6:0] USER_IN,
	output  [6:0] USER_OUT,

	input         OSD_STATUS
);

///////// Default values for ports not used in this core /////////

assign ADC_BUS  = 'Z;
assign {UART_RTS, UART_TXD, UART_DTR} = 0;
assign {SD_SCK, SD_MOSI, SD_CS} = 'Z;
assign {SDRAM_DQ, SDRAM_A, SDRAM_BA, SDRAM_CLK, SDRAM_CKE, SDRAM_DQML, SDRAM_DQMH, SDRAM_nWE, SDRAM_nCAS, SDRAM_nRAS, SDRAM_nCS} = 'Z;
assign {DDRAM_CLK, DDRAM_BURSTCNT, DDRAM_ADDR, DDRAM_DIN, DDRAM_BE, DDRAM_RD, DDRAM_WE} = '0;  

assign VGA_F1 = 0;
assign VGA_SCALER  = 0;
assign VGA_DISABLE = 0;
assign HDMI_FREEZE = 0;

wire [7:0] AOUT;
assign AUDIO_L = {AOUT,AOUT};
assign AUDIO_R = AUDIO_L;
assign AUDIO_S = 0; // unsigned PCM 
assign AUDIO_MIX = 0;

assign LED_DISK = 0;
assign LED_POWER = 0;
assign BUTTONS = 0;

assign LED_USER = LIGHTBULB;


//////////////////////////////////////////////////////////////////

//assign {SDRAM_A, SDRAM_BA, SDRAM_CLK, SDRAM_CKE, SDRAM_DQML, SDRAM_DQMH, SDRAM_nCAS, SDRAM_nRAS, SDRAM_nCS} = 'Z;
//wire [15:0] DEBUG_BA;
//wire DEBUG_RW;
//assign SDRAM_DQ = DEBUG_BA;
//assign SDRAM_nWE = DEBUG_RW;

//////////////////////////////////////////////////////////////////

wire [1:0] ar = status[122:121];

assign VIDEO_ARX = (!ar) ? 12'd4 : (ar - 1'd1);
assign VIDEO_ARY = (!ar) ? 12'd3 : 12'd0;

`include "build_id.v" 
localparam CONF_STR = {
	"A.CrystalCastles;;",
	"-;",
	"O[122:121],Aspect ratio,Original,Full Screen,[ARC1],[ARC2];",          // status[122:121]
	"O1,WatchDog,Disable,Enable;",                                          // status[1]
	"O2,Self Test Mode,Off,On;",                                            // status[2]
	"O3,Cabinet,Upright,Cocktail;",                                         // status[3]
	"-;",
	"O45,TrackBall,Joystick Digital,Joystick Analog,Mouse,SNAC;",           // status[5:4]
	"O67,Sensitivity,25%,50%,100%,200%;",                                   // status[7:6]
	"-;",
	"R0,Reset;",
	"J1,Jump/Start 1,Jump/Start 2,Coin Left,Coin Right,Coin Aux,Slam;",
	"V,v",`BUILD_DATE 
};

////////////////////   HPS   /////////////////////

wire         forced_scandoubler;
wire         direct_video;
wire   [1:0] buttons;
wire [127:0] status;
wire  [21:0] gamma_bus;
wire  [15:0] joystick_0;
wire [15:0] joystick_l_analog_0;
wire [24:0]	ps2_mouse;

wire        ioctl_download;
wire  [7:0] ioctl_index;
wire        ioctl_wr;
wire [15:0] ioctl_addr;
wire  [7:0] ioctl_dout;


hps_io #(.CONF_STR(CONF_STR)) hps_io
(
	.clk_sys(clk_sys),
	.HPS_BUS(HPS_BUS),
	.EXT_BUS(),

	.ioctl_download(ioctl_download),
	.ioctl_index(ioctl_index),
	.ioctl_wr(ioctl_wr),
	.ioctl_addr(ioctl_addr),
	.ioctl_dout(ioctl_dout),
	//.ioctl_din(ioctl_din),
	//.ioctl_upload(ioctl_upload),
	//.ioctl_wait(ioctl_wait),

	.forced_scandoubler(forced_scandoubler),
	.gamma_bus(gamma_bus),
	.direct_video(direct_video),
	.video_rotated(1'b0),

	.buttons(buttons),
	.status(status),
	.status_menumask({direct_video}),
	
	.joystick_0(joystick_0),
	.joystick_l_analog_0(joystick_l_analog_0),
	.ps2_mouse(ps2_mouse)   
);

///////////////////////   CLOCKS   ///////////////////////////////

wire clk_sys, clk_game;
pll pll
(
	.refclk(CLK_50M),
	.rst(0),
	.outclk_0(clk_sys),
	.outclk_1(clk_game)
);

//////////////////////////////////////////////////////////////////

wire HBlank;
wire HSync;
wire VBlank;
wire VSync;
reg ce_pix;
wire [8:0] rgb;		// 3r3G3b

arcade_video #(256,9) arcade_video
(
	.*,
	.clk_video(clk_sys),
	.RGB_in(rgb),
	.HBlank(HBlank),
	.VBlank(VBlank),
	.HSync(HSync),
	.VSync(VSync),
	.fx(3'b000)
);

wire m_startjump1  = joystick_0[4] | ps2_mouse[0] | tb1JMP;
wire m_startjump2  = joystick_0[5];
wire m_coin1p   = joystick_0[6] | tb1COIN;
wire m_coin2p   = joystick_0[7];
wire m_coinAux  = joystick_0[8];
wire m_slam  = joystick_0[9];

wire LIGHTBULB;
wire rom_download = ioctl_download & ioctl_index == 8'd0;
wire reset = RESET | status[0] | buttons[1] | rom_download;

assign USER_OUT = { 1'b0, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1 };
wire tb1JMP = ~USER_IN[0];
wire tb1COIN = ~USER_IN[1];
wire tb1VD = USER_IN[2];
wire tb1VC = USER_IN[3];
wire tb1HD = USER_IN[4];
wire tb1HC = USER_IN[5];
wire tbeVD, tbeVC, tbeHD, tbeHC;


TrackballEmu tbemu
(
	.clk(clk_sys),
	.joystick_digital(joystick_0[3:0]),
	.joystick_analog(joystick_l_analog_0),
	.ps2_mouse(ps2_mouse),
   
	.mode(status[5:4]),
	.sensitivity(status[7:6]),
   
	.v_dir_in(tb1VD), .v_clk_in(tb1VC),
	.h_dir_in(tb1HD),	.h_clk_in(tb1HC),

	.v_dir_out(tbeVD), .v_clk_out(tbeVC),
	.h_dir_out(tbeHD), .h_clk_out(tbeHC)
);


CCastles ccastles
(
	.clk(clk_game),
	.reset_n(~reset),
   
	.WDISn(status[1]),
   .SELFTEST(status[2]),
   .COCKTAIL(status[3]),
	
   .STARTJMP1(m_startjump1), .STARTJMP2(m_startjump2),
   .COINL(m_coin1p), .COINR(m_coin2p), .COINA(m_coinAux), .SLAM(m_slam),
	.LIGHTBULB(LIGHTBULB),
	
	.HBLANK(HBlank),
	.HSYNC(HSync),
	.VBLANK(VBlank),
	.VSYNC(VSync),

   .SOUT(AOUT),
	.RGBout(rgb),
   
	.tb1VD(tbeVD), .tb1VC(tbeVC), 
   .tb1HD(tbeHD), .tb1HC(tbeHC),
	
	.dn_clk(clk_sys),
	.dn_wr(ioctl_wr & rom_download),
	.dn_addr(ioctl_addr[15:0]),
	.dn_data(ioctl_dout)
);

reg [1:0] cnt;
always @(posedge clk_sys) 
begin
   cnt <= cnt + 2'b01;
	ce_pix <= forced_scandoubler ? cnt[0] : cnt[1];
end


endmodule
