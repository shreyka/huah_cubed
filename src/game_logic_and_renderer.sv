`timescale 1ns / 1ps
`default_nettype none

/*

TESTING:

IVERILOG COMMAND:

iverilog -g2012 -o sim/renderer_tb.out src/game_logic_and_renderer.sv src/game_state.sv src/block_positions.sv src/state_processor.sv src/renderer.sv && vvp game_logic_and_renderer_tv.out

*/

/*

THIS MODULE:

- encapsulates all the game logic and renderer info
- requires parsed camera data to function
- outputs: pixel for each XY

*/
module game_logic_and_renderer(
    input wire clk_in,
    input wire rst_in,
    
    input wire [10:0] x_in,
    input wire [9:0] y_in,
    input wire enable_three_dim_sw1,
    input wire enable_three_dim,

    input wire [11:0] hand_x_left_bottom,
    input wire [11:0] hand_y_left_bottom,
    input wire [13:0] hand_z_left_bottom,
    input wire [11:0] hand_x_left_top,
    input wire [11:0] hand_y_left_top,
    input wire [13:0] hand_z_left_top,
    input wire [11:0] hand_x_right_bottom,
    input wire [11:0] hand_y_right_bottom,
    input wire [13:0] hand_z_right_bottom,
    input wire [11:0] hand_x_right_top,
    input wire [11:0] hand_y_right_top,
    input wire [13:0] hand_z_right_top,
    input wire [11:0] head_x,
    input wire [11:0] head_y,
    input wire [13:0] head_z,

    output logic [3:0] r_out,
    output logic [3:0] g_out,
    output logic [3:0] b_out,
    output logic [15:0] TEST_LED,

    //this is temporary so that we can see score without a screen
    output logic [11:0] score_out
    );

    ////////////////////////////////////////////////////
    // REQUIRED LOGIC/WIRES
    //
    // SECTION: GAME LOGIC AND RENDERER
    //

    // INPUTS TO GAME_STATE
    logic block_position_ready;

    // OUTPUTS FROM GAME_STATE
    logic [1:0] state;
    logic [3:0] health;
    logic [11:0] score;
    logic [2:0] combo;
    logic [17:0] curr_time;
    logic [17:0] max_time;
    logic [11:0] [7:0] sliced_blocks;

    // OUTPUTS FROM BLOCK_LOADER
    logic [11:0] [11:0] block_x_blockloader;
    logic [11:0] [11:0] block_y_blockloader;
    logic [11:0] [17:0] block_time_blockloader;
    logic [11:0] block_color_blockloader;
    logic [11:0] [2:0] block_direction_blockloader;
    logic [11:0] [7:0] block_ID_blockloader;
    logic [17:0] curr_time_blockloader;

    // OUTPUTS FROM BLOCK_POSITIONS
    logic [17:0] curr_time_blockpositions;
    logic [11:0] [11:0] block_x_blockpositions;
    logic [11:0] [11:0] block_y_blockpositions;
    logic [11:0] [13:0] block_z_blockpositions;
    logic [11:0] block_color_blockpositions;
    logic [11:0] [2:0] block_direction_blockpositions;
    logic [11:0] [7:0] block_ID_blockpositions;
    logic [11:0] block_visible_blockpositions;

    // BLOCK SELECTOR GENERIC OUTPUT
    logic [17:0] curr_time_selector;
    logic [10:0] x_out_selector;
    logic [9:0] y_out_selector;
    logic [11:0] block_x_selector;
    logic [11:0] block_y_selector;
    logic [13:0] block_z_selector;
    logic block_color_selector;
    logic [2:0] block_direction_selector;
    logic [7:0] block_ID_selector;
    logic block_visible_selector;

    // OUTPUT FROM BLOCK SELECTOR 2D
    logic [17:0] curr_time_selector_two_dim;
    logic [10:0] x_out_selector_two_dim;
    logic [9:0] y_out_selector_two_dim;
    logic [11:0] block_x_selector_two_dim;
    logic [11:0] block_y_selector_two_dim;
    logic [13:0] block_z_selector_two_dim;
    logic block_color_selector_two_dim;
    logic [2:0] block_direction_selector_two_dim;
    logic [7:0] block_ID_selector_two_dim;
    logic block_visible_selector_two_dim;

    // OUTPUT FROM BLOCK SELECTOR 3D
    logic [17:0] curr_time_selector_three_dim;
    logic [10:0] x_out_selector_three_dim;
    logic [9:0] y_out_selector_three_dim;
    logic [11:0] block_x_selector_three_dim;
    logic [11:0] block_y_selector_three_dim;
    logic [13:0] block_z_selector_three_dim;
    logic block_color_selector_three_dim;
    logic [2:0] block_direction_selector_three_dim;
    logic [7:0] block_ID_selector_three_dim;
    logic block_visible_selector_three_dim;

    // OUTPUT FROM SABER HISTORY
    logic [11:0] prev_hand_x_left_bottom;
    logic [11:0] prev_hand_y_left_bottom;
    logic [13:0] prev_hand_z_left_bottom;
    logic [11:0] prev_hand_x_left_top;
    logic [11:0] prev_hand_y_left_top;
    logic [13:0] prev_hand_z_left_top;
    logic [11:0] prev_hand_x_right_bottom;
    logic [11:0] prev_hand_y_right_bottom;
    logic [13:0] prev_hand_z_right_bottom;
    logic [11:0] prev_hand_x_right_top;
    logic [11:0] prev_hand_y_right_top;
    logic [13:0] prev_hand_z_right_top;
    
    // OUTPUTS FROM STATE PROCESSOR
    logic block_sliced;
    logic [11:0] block_x_state_processor;
    logic [11:0] block_y_state_processor;
    logic [13:0] block_z_state_processor;
    logic block_color_state_processor;
    logic [2:0] block_direction_state_processor;
    logic [7:0] block_ID_state_processor;
    logic player_hit_by_obstacle;
    logic block_missed;

    // TEMP
    assign score_out = score;

    // OUTPUTS FROM BROKEN BLOCKS  
    logic [9:0] [11:0] broken_blocks_x;
    logic [9:0] [11:0] broken_blocks_y;
    logic [9:0] [13:0] broken_blocks_z;
    logic [9:0] broken_blocks_color;
    logic [9:0] [11:0] broken_blocks_width;
    logic [9:0] [11:0] broken_blocks_height;

    // OUTPUT FROM 2D RENDERER
    logic [3:0] r_out_two_dim, g_out_two_dim, b_out_two_dim;

    // OUTPUT FROM 3D RENDERER
    logic [3:0] r_out_three_dim, g_out_three_dim, b_out_three_dim;

    ////////////////////////////////////////////////////
    // MODULES
    //
    // SECTION: GAME STATE AND RENDERER
    //

    /*
    Game state controls most of the logic
    Most everything else branches from the game state

    LAYER 0:
    GAME STATE
    BLOCK POSITIONS
    LAYER 1:
    STATE_PROCESSER -> RENDERER
    */

    game_state game_state(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .block_sliced(block_sliced),
        .block_ID(block_ID_state_processor),
        .player_hit_by_obstacle(player_hit_by_obstacle),
        .block_missed(block_missed),
        .block_position_ready(block_position_ready),

        .state(state),
        .health_out(health),
        .score_out(score),
        .combo_out(combo),
        .curr_time(curr_time),
        .max_time(max_time),
        .sliced_blocks(sliced_blocks)
    );

    block_loader block_loader(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .curr_time_in(curr_time),

        .block_x(block_x_blockloader),
        .block_y(block_y_blockloader),
        .block_time(block_time_blockloader),
        .block_color(block_color_blockloader),
        .block_direction(block_direction_blockloader),
        .block_ID(block_ID_blockloader),
        .curr_time_out(curr_time_blockloader)
    );

    block_positions block_positions(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .curr_time_in(curr_time_blockloader),
        .block_x_in(block_x_blockloader),
        .block_y_in(block_y_blockloader),
        .block_time_in(block_time_blockloader),
        .block_color_in(block_color_blockloader),
        .block_direction_in(block_direction_blockloader),
        .block_ID_in(block_ID_blockloader),

        .curr_time_out(curr_time_blockpositions),
        .block_x_out(block_x_blockpositions),
        .block_y_out(block_y_blockpositions),
        .block_z_out(block_z_blockpositions),
        .block_color_out(block_color_blockpositions),
        .block_direction_out(block_direction_blockpositions),
        .block_ID_out(block_ID_blockpositions),
        .block_visible_out(block_visible_blockpositions)
    );

    three_dim_block_selector three_dim_block_selector(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .curr_time_in(curr_time_blockpositions),
        .x_in(x_in),
        .y_in(y_in),
        .sliced_blocks(sliced_blocks),
        .block_x_in(block_x_blockpositions),
        .block_y_in(block_y_blockpositions),
        .block_z_in(block_z_blockpositions),
        .block_color_in(block_color_blockpositions),
        .block_direction_in(block_direction_blockpositions),
        .block_ID_in(block_ID_blockpositions),
        .block_visible_in(block_visible_blockpositions),

        .curr_time_out(curr_time_selector_three_dim),
        .x_out(x_out_selector_three_dim),
        .y_out(y_out_selector_three_dim),
        .block_x_out(block_x_selector_three_dim),
        .block_y_out(block_y_selector_three_dim),
        .block_z_out(block_z_selector_three_dim),
        .block_color_out(block_color_selector_three_dim),
        .block_direction_out(block_direction_selector_three_dim),
        .block_ID_out(block_ID_selector_three_dim),
        .block_visible_out(block_visible_selector_three_dim)
    );

    logic [22:0] curr_time_counter;

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            curr_time_counter <= 0;
            TEST_LED <= 0;
        end else begin
            if(curr_time_counter >= 6500000 && x_out_selector_three_dim == 200 && y_out_selector_three_dim == 200) begin //100 ms
                TEST_LED <= {7'b1111111, block_visible_selector_three_dim == 0 ? 8'b0 : block_ID_selector_three_dim, block_visible_selector_three_dim};
                curr_time_counter <= 0;
            end else begin
                if(curr_time_counter < 6500000) begin
                    curr_time_counter <= curr_time_counter + 1;
                end
            end
        end
    end

    // block_selector block_selector(
    //     .clk_in(clk_in),
    //     .rst_in(rst_in),
    //     .curr_time_in(curr_time_blockpositions),
    //     .x_in(x_in),
    //     .y_in(y_in),
    //     .sliced_blocks(sliced_blocks),
    //     .block_x_in(block_x_blockpositions),
    //     .block_y_in(block_y_blockpositions),
    //     .block_z_in(block_z_blockpositions),
    //     .block_color_in(block_color_blockpositions),
    //     .block_direction_in(block_direction_blockpositions),
    //     .block_ID_in(block_ID_blockpositions),
    //     .block_visible_in(block_visible_blockpositions),

    //     .curr_time_out(curr_time_selector_two_dim),
    //     .x_out(x_out_selector_two_dim),
    //     .y_out(y_out_selector_two_dim),
    //     .block_x_out(block_x_selector_two_dim),
    //     .block_y_out(block_y_selector_two_dim),
    //     .block_z_out(block_z_selector_two_dim),
    //     .block_color_out(block_color_selector_two_dim),
    //     .block_direction_out(block_direction_selector_two_dim),
    //     .block_ID_out(block_ID_selector_two_dim),
    //     .block_visible_out(block_visible_selector_two_dim)
    // );

    // assign curr_time_selector = enable_three_dim_sw1 ? curr_time_selector_three_dim : curr_time_selector_two_dim;
    // assign x_out_selector = enable_three_dim_sw1 ? x_out_selector_three_dim : x_out_selector_two_dim;
    // assign y_out_selector = enable_three_dim_sw1 ? y_out_selector_three_dim : y_out_selector_two_dim;
    // assign block_x_selector = enable_three_dim_sw1 ? block_x_selector_three_dim : block_x_selector_two_dim;
    // assign block_y_selector = enable_three_dim_sw1 ? block_y_selector_three_dim : block_y_selector_two_dim;
    // assign block_z_selector = enable_three_dim_sw1 ? block_z_selector_three_dim : block_z_selector_two_dim;
    // assign block_color_selector = enable_three_dim_sw1 ? block_color_selector_three_dim : block_color_selector_two_dim;
    // assign block_direction_selector = enable_three_dim_sw1 ? block_direction_selector_three_dim : block_direction_selector_two_dim;
    // assign block_ID_selector = enable_three_dim_sw1 ? block_ID_selector_three_dim: block_ID_selector_two_dim;
    // assign block_visible_selector = enable_three_dim_sw1 ? block_visible_selector_three_dim: block_visible_selector_two_dim;

    assign curr_time_selector = curr_time_selector_three_dim;
    assign x_out_selector = x_out_selector_three_dim;
    assign y_out_selector = y_out_selector_three_dim;
    assign block_x_selector = block_x_selector_three_dim;
    assign block_y_selector = block_y_selector_three_dim;
    assign block_z_selector = block_z_selector_three_dim;
    assign block_color_selector = block_color_selector_three_dim;
    assign block_direction_selector = block_direction_selector_three_dim;
    assign block_ID_selector = block_ID_selector_three_dim;
    assign block_visible_selector = block_visible_selector_three_dim;

    saber_history saber_history(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .curr_time(curr_time),
        .hand_x_left_bottom(hand_x_left_bottom),
        .hand_y_left_bottom(hand_y_left_bottom),
        .hand_z_left_bottom(hand_z_left_bottom),
        .hand_x_left_top(hand_x_left_top),
        .hand_y_left_top(hand_y_left_top),
        .hand_z_left_top(hand_z_left_top),
        .hand_x_right_bottom(hand_x_right_bottom),
        .hand_y_right_bottom(hand_y_right_bottom),
        .hand_z_right_bottom(hand_z_right_bottom),
        .hand_x_right_top(hand_x_right_top),
        .hand_y_right_top(hand_y_right_top),
        .hand_z_right_top(hand_z_right_top),

        .prev_hand_x_left_bottom(prev_hand_x_left_bottom),
        .prev_hand_y_left_bottom(prev_hand_y_left_bottom),
        .prev_hand_z_left_bottom(prev_hand_z_left_bottom),
        .prev_hand_x_left_top(prev_hand_x_left_top),
        .prev_hand_y_left_top(prev_hand_y_left_top),
        .prev_hand_z_left_top(prev_hand_z_left_top),
        .prev_hand_x_right_bottom(prev_hand_x_right_bottom),
        .prev_hand_y_right_bottom(prev_hand_y_right_bottom),
        .prev_hand_z_right_bottom(prev_hand_z_right_bottom),
        .prev_hand_x_right_top(prev_hand_x_right_top),
        .prev_hand_y_right_top(prev_hand_y_right_top),
        .prev_hand_z_right_top(prev_hand_z_right_top)
    );

    state_processor state_processor(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .curr_time(curr_time),
        .block_x(block_x_selector),
        .block_y(block_y_selector),
        .block_z(block_z_selector),
        .block_color(block_color_selector),
        .block_direction(block_direction_selector),
        .block_ID(block_ID_selector),
        .block_visible(block_visible_selector),
        .state(state),
        .prev_hand_x_left_bottom(prev_hand_x_left_bottom),
        .prev_hand_y_left_bottom(prev_hand_y_left_bottom),
        .prev_hand_z_left_bottom(prev_hand_z_left_bottom),
        .prev_hand_x_left_top(prev_hand_x_left_top),
        .prev_hand_y_left_top(prev_hand_y_left_top),
        .prev_hand_z_left_top(prev_hand_z_left_top),
        .prev_hand_x_right_bottom(prev_hand_x_right_bottom),
        .prev_hand_y_right_bottom(prev_hand_y_right_bottom),
        .prev_hand_z_right_bottom(prev_hand_z_right_bottom),
        .prev_hand_x_right_top(prev_hand_x_right_top),
        .prev_hand_y_right_top(prev_hand_y_right_top),
        .prev_hand_z_right_top(prev_hand_z_right_top),
        .hand_x_left_bottom(hand_x_left_bottom),
        .hand_y_left_bottom(hand_y_left_bottom),
        .hand_z_left_bottom(hand_z_left_bottom),
        .hand_x_left_top(hand_x_left_top),
        .hand_y_left_top(hand_y_left_top),
        .hand_z_left_top(hand_z_left_top),
        .hand_x_right_bottom(hand_x_right_bottom),
        .hand_y_right_bottom(hand_y_right_bottom),
        .hand_z_right_bottom(hand_z_right_bottom),
        .hand_x_right_top(hand_x_right_top),
        .hand_y_right_top(hand_y_right_top),
        .hand_z_right_top(hand_z_right_top),
        .head_x(head_x),
        .head_y(head_y),
        .head_z(head_z),

        .block_sliced(block_sliced),
        .block_x_out(block_x_state_processor),
        .block_y_out(block_y_state_processor),
        .block_z_out(block_z_state_processor),
        .block_color_out(block_color_state_processor),
        .block_direction_out(block_direction_state_processor),
        .block_ID_out(block_ID_state_processor),
        .player_hit_by_obstacle(player_hit_by_obstacle),
        .block_missed(block_missed)
    );

    broken_blocks broken_blocks(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .curr_time(curr_time),
        .block_sliced(block_sliced),
        .block_x(block_x_state_processor),
        .block_y(block_y_state_processor),
        .block_z(block_z_state_processor),
        .block_ID_in(block_ID_state_processor),
        .block_color(block_color_state_processor),
        .block_direction(block_direction_state_processor),

        .broken_blocks_x(broken_blocks_x),
        .broken_blocks_y(broken_blocks_y),
        .broken_blocks_z(broken_blocks_z),
        .broken_blocks_color(broken_blocks_color),
        .broken_blocks_width(broken_blocks_width),
        .broken_blocks_height(broken_blocks_height)
    );

    three_dim_renderer three_dim_renderer(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .curr_time(curr_time_selector),
        .x_in_block(x_out_selector),
        .y_in_block(y_out_selector),
        .x_in_rgb(x_in),
        .y_in_rgb(y_in),
        .block_x(block_x_selector),
        .block_y(block_y_selector),
        .block_z(block_z_selector),
        .block_color(block_color_selector),
        .block_direction(block_direction_selector),
        .block_visible(block_visible_selector),
        .state(state),
        .max_time(max_time),
        .score_in(score),
        .health_in(health),
        .combo_in(combo),
        .broken_blocks_x(broken_blocks_x),
        .broken_blocks_y(broken_blocks_y),
        .broken_blocks_z(broken_blocks_z),
        .broken_blocks_color(broken_blocks_color),
        .broken_blocks_width(broken_blocks_width),
        .broken_blocks_height(broken_blocks_height),
        .hand_x_left_bottom(hand_x_left_bottom),
        .hand_y_left_bottom(hand_y_left_bottom),
        .hand_z_left_bottom(hand_z_left_bottom),
        .hand_x_left_top(hand_x_left_top),
        .hand_y_left_top(hand_y_left_top),
        .hand_z_left_top(hand_z_left_top),
        .hand_x_right_bottom(hand_x_right_bottom),
        .hand_y_right_bottom(hand_y_right_bottom),
        .hand_z_right_bottom(hand_z_right_bottom),
        .hand_x_right_top(hand_x_right_top),
        .hand_y_right_top(hand_y_right_top),
        .hand_z_right_top(hand_z_right_top),
        .head_x(head_x),
        .head_y(head_y),
        .head_z(head_z),

        .r_out(r_out_three_dim),
        .g_out(g_out_three_dim),
        .b_out(b_out_three_dim)
    );

    // renderer renderer(
    //     .clk_in(clk_in),
    //     .rst_in(rst_in),
    //     .curr_time(curr_time_selector),
    //     .x_in(x_in),
    //     .y_in(y_in),
    //     .block_x(block_x_selector),
    //     .block_y(block_y_selector),
    //     .block_z(block_z_selector),
    //     .block_color(block_color_selector),
    //     .block_direction(block_direction_selector),
    //     .block_visible(block_visible_selector),
    //     .state(state),
    //     .max_time(max_time),
    //     .score_in(score),
    //     .health_in(health),
    //     .combo_in(combo),
    //     .broken_blocks_x(broken_blocks_x),
    //     .broken_blocks_y(broken_blocks_y),
    //     .broken_blocks_z(broken_blocks_z),
    //     .broken_blocks_color(broken_blocks_color),
    //     .broken_blocks_width(broken_blocks_width),
    //     .broken_blocks_height(broken_blocks_height),
    //     .hand_x_left_bottom(hand_x_left_bottom),
    //     .hand_y_left_bottom(hand_y_left_bottom),
    //     .hand_z_left_bottom(hand_z_left_bottom),
    //     .hand_x_left_top(hand_x_left_top),
    //     .hand_y_left_top(hand_y_left_top),
    //     .hand_z_left_top(hand_z_left_top),
    //     .hand_x_right_bottom(hand_x_right_bottom),
    //     .hand_y_right_bottom(hand_y_right_bottom),
    //     .hand_z_right_bottom(hand_z_right_bottom),
    //     .hand_x_right_top(hand_x_right_top),
    //     .hand_y_right_top(hand_y_right_top),
    //     .hand_z_right_top(hand_z_right_top),
    //     .head_x(head_x),
    //     .head_y(head_y),
    //     .head_z(head_z),

    //     .r_out(r_out_two_dim),
    //     .g_out(g_out_two_dim),
    //     .b_out(b_out_two_dim)
    // );

    // assign r_out = enable_three_dim ? r_out_three_dim : r_out_two_dim;
    // assign g_out = enable_three_dim ? g_out_three_dim : g_out_two_dim;
    // assign b_out = enable_three_dim ? b_out_three_dim : b_out_two_dim;
    assign r_out = r_out_three_dim;
    assign g_out = g_out_three_dim;
    assign b_out = b_out_three_dim;
endmodule

`default_nettype wire