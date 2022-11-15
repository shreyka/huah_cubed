#!/bin/bash

# go to main directory
cd ../

command=$1

function compile_for_test () {
    # run personal compiler
    sed -i 's/curr_time_counter == 650000/curr_time_counter == 10/g' src/game_state.sv
    sed -i 's|.INIT_FILE("out.mem")|.INIT_FILE("data/out.mem")|g' src/block_loader.sv
    # end run personal compiler
}

function compile_for_build () {
    # run personal compiler
    sed -i 's/curr_time_counter == 10/curr_time_counter == 650000/g' src/game_state.sv
    # sed -i 's|.INIT_FILE("data/out.mem")|.INIT_FILE("out.mem")|g' src/block_loader.sv
    # end run personal compiler
}

if [[ $command == "test" ]]
then
    if [[ $2 == "all" ]]
    then
        compile_for_test

        iverilog -g2012 -o sim/game_logic_and_renderer_tb.out sim/game_logic_and_renderer_tb.sv src/game_logic_and_renderer.sv src/game_state.sv src/block_positions.sv src/block_selector.sv src/state_processor.sv src/renderer.sv src/block_loader.sv src/xilinx_single_port_ram_read_first.v src/saber_history.sv && vvp sim/game_logic_and_renderer_tb.out
    elif [[ $2 == "loader" ]]
    then
        compile_for_test
        
        iverilog -g2012 -o sim/block_loader_tb.out sim/block_loader_tb.sv src/block_loader.sv src/xilinx_single_port_ram_read_first.v && vvp sim/block_loader_tb.out
    elif [[ $2 == "controller" ]]
    then
        iverilog -g2012 -o sim/hand_controller_tb.out sim/hand_controller_tb.sv src/hand_controller.sv && vvp sim/hand_controller_tb.out
    elif [[ $2 == "selector" ]]
    then
        iverilog -g2012 -o sim/block_selector_tb.out sim/block_selector_tb.sv src/block_selector.sv src/block_positions.sv && vvp sim/block_selector_tb.out
    else
        echo "Unknown test case..."
    fi
elif [[ $command == "build" ]]
then
    compile_for_build

    if [[ $2 == "bc" ]]
    then
        eval "$(ssh-agent)" > /dev/null 2>&1
        ssh-add ~/.ssh/id_rsa_6111 > /dev/null 2>&1
        time python3 lab-bc.py -o output_files && openFPGALoader -b arty_a7_100t output_files/out.bit
    else
        time vivado -mode batch -source build.tcl && openFPGALoader -b arty_a7_100t output_files/final.bit
    fi
elif [[ $command == "fpga" ]]
then
    openFPGALoader -b arty_a7_100t output_files/final.bit
else
    echo "unknown command."
fi