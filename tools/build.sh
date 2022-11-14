#!/bin/bash

# go to main directory
cd ../

command=$1

if [[ $command == "test" ]]
then
    # run personal compiler
    sed -i 's/curr_time_counter == 650000/curr_time_counter == 10/g' src/game_state.sv
    # end run personal compiler

    iverilog -g2012 -o sim/game_logic_and_renderer_tb.out sim/game_logic_and_renderer_tb.sv src/game_logic_and_renderer.sv src/game_state.sv src/block_positions.sv src/block_selector.sv src/state_processor.sv src/renderer.sv src/block_loader.sv && vvp sim/game_logic_and_renderer_tb.out
elif [[ $command == "build" ]]
then
    # run personal compiler
    sed -i 's/curr_time_counter == 10/curr_time_counter == 650000/g' src/game_state.sv
    # end run personal compiler

    vivado -mode batch -source build.tcl && openFPGALoader -b arty_a7_100t output_files/final.bit
elif [[ $command == "fpga" ]]
then
    openFPGALoader -b arty_a7_100t output_files/final.bit
else
    echo "unknown command."
fi