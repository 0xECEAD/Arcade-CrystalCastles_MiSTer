# Crystal Castles
Arcade port for MiSTer
(work in progress, lots to do)

## General Description
Author: Enceladus
From: Atari 1983
Date: August 2022  
Version: v0

## Info
Game Clock: 10 MHz
Pixel Clock: 5 Mhz
Horizontal: counter 320, visible 256, hsync=> 15.625 kHz
Vertical: counter 256, visible 232, vsync=> 61.03 Hz
VGA scan doubler working (forced_scandoubler=1 in mister.ini)


# Quartus Version
Cores must be developed in **Quartus v17.0.x**. It's recommended to have updates, so it will be **v17.0.2**. Newer versions won't give any benefits to FPGA used in MiSTer, however they will introduce incompatibilities in project settings and it will make harder to maintain the core and collaborate with others. **So please stick to good old 17.0.x version.** You may use either Lite or Standard license.

# Attention
ROMs are not included. In order to use this arcade, you need to provide the correct ROMs.

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