# Crystal Castles
An FPGA implementation of the __Crystal Castles__ arcade hardware by __Atari__ for the MiSTer platform.
<br>(work in progress)


## General Description
Author: Enceladus<br>
From: Atari 1983<br>
Date: Aug-Nov 2022<br>
Version: v1.0a (playable)<br>
SDRAM: no<br>

## Info
Game Clock: 10 MHz<br>
Pixel Clock: 5 Mhz<br>
Horizontal: counter 320, visible 252, hsync => 15.625 kHz<br>
Vertical: counter 256, visible 232, vsync => 61.03 Hz<br>
VGA scan doubler working (forced_scandoubler=1 in mister.ini)<br>

## Known Issues
Garbage on screen (bottom) when vertical scrolling.<br>
In cocktail mode, the player 2 upside down screen and sprites are not positioned correctly.<br>

## Controller
This version can be played with an actual TrackBall connected to the SNAC connector (best experience!).<br>
USER_IN[0]=Jump/Start, USER_IN[1]=Coin Left. Both switch to GND.<br>
USER_IN[2]=Vertical Quadrature encoder A, USER_IN[3]=Vertical Quadrature encoder B,<br>
USER_IN[4]=Horizontal Quadrature encoder A, USER_IN[5]=Horizontal Quadrature encoder B.<br>
<br>
Emulation of a TrackBall is also provided for digital joystick, analog joystick or mouse. <br>
You can set the sensitivity for your device in the OSD menu.


## Credits, acknowledgments, and thanks
- [__Enceladus__](https://github.com/0xecead): Core design and implementation.
- Original 6502 core by Arlet Ottens, 65C02 extensions by David Banks and Ed Spittles.
- Atari Pokey by Mark Watson (c) 2013 (VHDL), conversion to Verilog by (?).
- Trackball Emulator based on work by [__Jim Gregory__](https://github.com/JimmyStones).

## Modifications
- Pokey: Added clock-enable (CE) to make clock divider redundant.
- Trackball Emulator: Adopted for 4x Quadrature, Added option for a true TrackBall on the SNAC connector.

## FPGA implementation
- Created using original schematics, and insight from own tools and tests with a custom diagnostic rom.
- TTL74 logic has been simplified, and re-engineered where necessary. 
- 82S129 PROMs were replaced by their equivalent logic expressions.
- Clock dividers were replaced with equivalent clock-enable signals. So the game clock (10MHz) only connects to clock inputs, and logic signals only connect to logic inputs (not clocks). This results in a cleaner FPGA synchronous design (citation needed).



# Quartus Version
Cores must be developed in **Quartus v17.0.x**. It's recommended to have updates, so it will be **v17.0.2**. Newer versions won't give any benefits to FPGA used in MiSTer, however they will introduce incompatibilities in project settings and it will make harder to maintain the core and collaborate with others. **So please stick to good old 17.0.x version.** You may use either Lite or Standard license.

# Attention
**TODO** ROMs are not included. In order to use this arcade, you need to provide the correct ROMs.

To simplify the process .mra files are provided in the releases folder, that
specifies the required ROMs with checksums. The ROMs .zip filename refers to the
corresponding file of the M.A.M.E. project.

Please refer to https://github.com/MiSTer-devel/Main_MiSTer/wiki/Arcade-Roms for
information on how to setup and use the environment.

Quickreference for folders and file placement:

/_Arcade/<game name>.mra
/_Arcade/cores/<game rbf>.rbf
/_Arcade/mame/<mame rom>.zip
/_Arcade/hbmame/<hbmame rom>.zip