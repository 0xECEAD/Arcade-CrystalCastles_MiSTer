# Crystal Castles
An FPGA implementation of the __Crystal Castles__ arcade hardware by __Atari__ for the MiSTer platform.
<br>(work in progress)


## General Description
Author: Enceladus<br>
From: Atari 1983<br>
Date: Aug-Sep 2022<br>
Version: v0.1 (playable)<br>
SDRAM: no<br>

## Info
Game Clock: 10 MHz<br>
Pixel Clock: 5 Mhz<br>
Horizontal: counter 320, visible 256, hsync => 15.625 kHz<br>
Vertical: counter 256, visible 232, vsync => 61.03 Hz<br>
VGA scan doubler working (forced_scandoubler=1 in mister.ini)<br>

## Known Issues
Sprites sometime draw dirt on screen (left).<br>
Garbage on screen (bottom) when vertical scrolling.<br>
In cocktail mode, the player 2 inverted screen is not positioned correctly and sprites are incorrect.<br>

## Controller
This version uses an actual TrackBall connected to the SNAC connector.<br>
USER_IN[0]=Jump/Start, USER_IN[1]=Coin Left. Both switch to GND.<br>
USER_IN[2]=Vertical Quadrature encoder A, USER_IN[3]=Vertical Quadrature encoder B,<br>
USER_IN[4]=Horizontal Quadrature encoder A, USER_IN[5]=Horizontal Quadrature encoder B.<br>

## Credits, acknowledgments, and thanks
- [__Enceladus__](https://github.com/0xecead): Core design and implementation.
- Original 6502 core by Arlet Ottens, 65C02 extensions by David Banks and Ed Spittles.
- Atari Pokey by Mark Watson (c) 2013 (VHDL), conversion to Verilog by (?).

## Modifications
- Pokey: Added clock-enable (CE), don't mix clock and combinatorial logic in an FPGA.


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