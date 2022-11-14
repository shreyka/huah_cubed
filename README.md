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

# Renderer logic

BLOCK LOADER -> contains a BRAM of all the data necessary. will pass out the next 16 blocks at or in front of time t at any given time, called blocks_16

BLOCK POSITIONS -> given blocks_16, calculate if each block is visible, and pass in their z coordinate
    -> PASS TO PROCESSOR AND SELECTOR AT THE SAME TIME

STATE PROCESSOR -> given blocks_16, their visibility and z coordinates, calculate if each block has been sliced or is missed
    -> LATER ON: also calculate if obstacles have been hit

BLOCK SELECTOR -> given XY, blocks_16 and their visibility, calculate which block should be rendered (in opposite order of received)

RENDERER -> given XY, and block data, render the block
    -> LATER ON: also calculate obstacle data

potential problems:
- how can obstacles get factored into the rendering
    -> renderer will later on have a MUX between if it is an obstacle or a block
- how can hands get factored into rendering
    -> render hands first always
- how to render destroyed blocks
    -> pass it into a separate array that keeps track of this information until it is done rendering a destroyed block
- how to raycast given this information
    -> given XY and block to be rendered, you can do the raycasting algorithm to the specific block in space without needing the info of any other block