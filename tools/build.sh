#!/bin/bash

# go to main directory
cd ../

command=$1

function compile_for_test () {
    # run personal compiler
    # sed -i 's/curr_time_counter == 650000/curr_time_counter == 10/g' src/game_state.sv
    # sed -i 's|.INIT_FILE("out.mem")|.INIT_FILE("data/out.mem")|g' src/block_loader.sv
    # end run personal compiler
    echo "skipped"
}

function compile_for_build () {
    # run personal compiler
    # sed -i 's/curr_time_counter == 10/curr_time_counter == 650000/g' src/game_state.sv
    # sed -i 's|.INIT_FILE("data/out.mem")|.INIT_FILE("out.mem")|g' src/block_loader.sv
    # end run personal compiler
    echo "skipped"
}

if [[ $command == "test" ]]
then
    if [[ $2 == "all" ]]
    then
        # compile_for_test

        iverilog -g2012 -Isrc src/game_logic_and_renderer.sv src/game_state.sv src/block_positions.sv src/block_selector.sv src/state_processor.sv src/renderer.sv src/block_loader.sv src/xilinx_single_port_ram_read_first.v src/saber_history.sv src/broken_blocks.sv src/three_dim_renderer.sv src/three_dim_block_selector.sv src/float_functions.sv src/xilinx_true_dual_port_read_first_1_clock_ram.v src/get_intersecting_block.sv src/eye_to_pixel.sv src/does_ray_block_intersect.sv stubs/*.v src/get_pixel_rgb_formatted.sv src/get_pixel_color.sv
    elif [[ $2 == "loader" ]]
    then
        compile_for_test
        
        iverilog -g2012 -o sim/block_loader_tb.out -Isrc sim/block_loader_tb.sv src/block_loader.sv src/xilinx_single_port_ram_read_first.v && vvp sim/block_loader_tb.out
    elif [[ $2 == "controller" ]]
    then
        iverilog -g2012 -o sim/hand_controller_tb.out -Isrc sim/hand_controller_tb.sv src/hand_controller.sv && vvp sim/hand_controller_tb.out
    elif [[ $2 == "selector" ]]
    then
        iverilog -g2012 -o sim/block_selector_tb.out -Isrc sim/block_selector_tb.sv src/block_selector.sv src/block_positions.sv && vvp sim/block_selector_tb.out
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
    elif [[ $2 == "gui" ]]
    then
        vivado -source build.tcl | tee output.log
    else
        time vivado -mode batch -source build.tcl && openFPGALoader -b arty_a7_100t output_files/final.bit
    fi
elif [[ $command == "fpga" ]]
then
    openFPGALoader -b arty_a7_100t output_files/final.bit
elif [[ $command == "fpga-tl" ]]
then
    openFPGALoader -b arty_a7_100t /media/koops/VIVADO/huah_cubed_ip/huah_cubed_ip/huah_cubed_ip.runs/impl_1/top_level.bit
else
    echo "unknown command."
fi
