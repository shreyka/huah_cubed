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

    output logic [4:0] r_out,
    output logic [5:0] g_out,
    output logic [4:0] b_out
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

    // OUTPUTS FROM BLOCK_LOADER
    logic [11:0] [11:0] block_x_blockloader;
    logic [11:0] [11:0] block_y_blockloader;
    logic [11:0] [17:0] block_time_blockloader;
    logic [11:0] block_color_blockloader;
    logic [11:0] [2:0] block_direction_blockloader;
    logic [17:0] curr_time_blockloader;

    // OUTPUTS FROM BLOCK_POSITIONS
    logic [17:0] curr_time_blockpositions;
    logic [11:0] [11:0] block_x_blockpositions;
    logic [11:0] [11:0] block_y_blockpositions;
    logic [11:0] [13:0] block_z_blockpositions;
    logic [11:0] block_color_blockpositions;
    logic [11:0] [2:0] block_direction_blockpositions;
    logic [11:0] block_visible_blockpositions;

    // OUTPUTS FROM BLOCK SELECTOR
    logic [17:0] curr_time_selector;
    logic [10:0] x_out_selector;
    logic [9:0] y_out_selector;
    logic [11:0] block_x_selector;
    logic [11:0] block_y_selector;
    logic [13:0] block_z_selector;
    logic block_color_selector;
    logic [2:0] block_direction_selector;
    logic block_visible_selector;
    
    // OUTPUTS FROM STATE PROCESSOR
    logic block_sliced;
    logic player_hit_by_obstacle;
    logic block_missed;

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
        .player_hit_by_obstacle(player_hit_by_obstacle),
        .block_missed(block_missed),
        .block_position_ready(block_position_ready),

        .state(state),
        .health_out(health),
        .score_out(score),
        .combo_out(combo),
        .curr_time(curr_time),
        .max_time(max_time)
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

        .curr_time_out(curr_time_blockpositions),
        .block_x_out(block_x_blockpositions),
        .block_y_out(block_y_blockpositions),
        .block_z_out(block_z_blockpositions),
        .block_color_out(block_color_blockpositions),
        .block_direction_out(block_direction_blockpositions),
        .block_visible_out(block_visible_blockpositions)
    );

    block_selector block_selector(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .curr_time_in(curr_time_blockpositions),
        .x_in(x_in),
        .y_in(y_in),
        .block_x_in(block_x_blockpositions),
        .block_y_in(block_y_blockpositions),
        .block_z_in(block_z_blockpositions),
        .block_color_in(block_color_blockpositions),
        .block_direction_in(block_direction_blockpositions),
        .block_visible_in(block_visible_blockpositions),

        .curr_time_out(curr_time_selector),
        .x_out(x_out_selector),
        .y_out(y_out_selector),
        .block_x_out(block_x_selector),
        .block_y_out(block_y_selector),
        .block_z_out(block_z_selector),
        .block_color_out(block_color_selector),
        .block_direction_out(block_direction_selector),
        .block_visible_out(block_visible_selector)
    );

    state_processor state_processor(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .block_x(block_x_selector),
        .block_y(block_y_selector),
        .block_z(block_z_selector),
        .block_color(block_color_selector),
        .block_direction(block_direction_selector),
        .block_visible(block_visible_selector),
        .state(state),
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
        .player_hit_by_obstacle(player_hit_by_obstacle),
        .block_missed(block_missed)
    );

    renderer renderer(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .curr_time(curr_time_selector),
        .x_in(x_out_selector),
        .y_in(y_out_selector),
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

        .r_out(r_out),
        .g_out(g_out),
        .b_out(b_out)
    );
endmodule

`default_nettype wire