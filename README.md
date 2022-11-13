# HUAH HUAH HUAH

## Variable constraints:

X ranges from 0 to 3599

Y ranges from 0 to 3599

Z ranges from 0 to 10799

hcount ranges from 0 to 1023

vcount ranges from 0 to 767

pixel_color is either 0 or 1, for red or blue

state can be one of 4 states:

    localparam STATE_MENU = 0;
    localparam STATE_PLAYING = 1;
    localparam STATE_WON = 2;
    localparam STATE_LOST = 3;

health ranges from 0 to 10, where 0 is dead and 10 is full health

score ranges from 0 to 4095

- each block gets you 1 point * combo

combo ranges from 1 to 8 (translate from 0-7 in code)

curr_time/max_time ranges from 0 to 262143

- each timestep represents 10 milliseconds
- this means we have 100 frames per second in the game

## helpful commands

### build the project

vivado -mode batch -source build.tcl

### deploy the project

openFPGALoader -b arty_a7_100t output_files/final.bit