#!/bin/bash

# go to main directory
cd ../

command=$1

function compile_for_test () {
    # run personal compiler
    # sed -i 's/curr_time_counter == 650000/curr_time_counter == 10/g' src/game_state.sv
    # sed -i 's|.INIT_FILE("out.mem")|.INIT_FILE("data/out.mem")|g' src/block_loader.sv
    # end run personal compiler
    echo ""
}

function compile_for_build () {
    # run personal compiler
    # sed -i 's/curr_time_counter == 10/curr_time_counter == 650000/g' src/game_state.sv
    # sed -i 's|.INIT_FILE("data/out.mem")|.INIT_FILE("out.mem")|g' src/block_loader.sv
    # end run personal compiler
    echo ""
}

if [[ $command == "test" ]]
then
    iverilog -g2012 -o sim/three_dim_renderer_tb.out sim/three_dim_renderer_tb.sv src/three_dim_renderer.sv src/xilinx_true_dual_port_read_first_1_clock_ram.v && vvp sim/three_dim_renderer_tb.out
elif [[ $command == "build" ]]
then
    if [[ $2 == "bc" ]]
    then
        eval "$(ssh-agent)" > /dev/null 2>&1
        ssh-add ~/.ssh/id_rsa_6111 > /dev/null 2>&1
        time python3 lab-bc.py -o output_files && openFPGALoader -b arty_a7_100t output_files/out.bit
    elif [[ $2 == "gui" ]]
    then
        vivado -source build.tcl | tee output.log
    else
        time vivado -mode batch -source build.tcl && openFPGALoader -b arty_a7_100t output_files/final.bit
    fi
elif [[ $command == "fpga" ]]
then
    openFPGALoader -b arty_a7_100t output_files/final.bit
else
    echo "unknown command."
fi