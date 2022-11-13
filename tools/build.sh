#!/bin/bash

command=$1

if [[ $command == "test" ]]
then
    # run personal compiler
    sed -i '/curr_time_counter == 650000/c\curr_time_counter == 0' test

    iverilog -g2012 -o sim/game_logic_and_renderer_tb.out sim/game_logic_and_renderer_tb.sv src/game_logic_and_renderer.sv src/game_state.sv src/block_positions.sv src/state_processor.sv src/renderer.sv && vvp sim/game_logic_and_renderer_tb.out
elif [[ $command == "build" ]]
then
    # run personal compiler
    sed -i '/TEXT_TO_BE_REPLACED/c\This line is removed by the admin.' test

    vivado -mode batch -source build.tcl && penFPGALoader -b arty_a7_100t output_files/final.bit
fi