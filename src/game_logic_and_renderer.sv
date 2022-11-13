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
    logic block_sliced;
    logic player_hit_by_obstacle;
    logic block_missed;
    logic block_position_ready;

    // OUTPUTS FROM GAME_STATE
    logic [1:0] state;
    logic [3:0] health;
    logic [11:0] score;
    logic [2:0] combo;
    logic [17:0] curr_time;
    logic [17:0] max_time;

    // INPUTS TO BLOCK_POSITIONS
    // TODO: how do we know how many blocks exist?
    // -> temp solution: assume 5 blocks total, each in each frame
    logic [7:0] curr_block_index_in;

    // OUTPUTS FROM BLOCK_POSITIONS
    logic block_visible;
    logic [7:0] curr_block_index_out;
    logic [11:0] block_x;
    logic [11:0] block_y;
    logic [13:0] block_z;
    logic block_color;
    logic [2:0] block_direction;

    // INIT LOGIC
    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            curr_block_index_in <= 0;
        end else begin
            // loop all blocks in order
            if (curr_block_index_in == 5) begin
                curr_block_index_in <= 0;
            end else begin
                curr_block_index_in <= curr_block_index_in + 1;
            end
        end
    end

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

    block_positions block_positions(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .curr_block_index_in(curr_block_index_in),
        .curr_time(curr_time),

        .block_visible(block_visible),
        .curr_block_index_out(curr_block_index_out),
        .block_x(block_x),
        .block_y(block_y),
        .block_z(block_z),
        .block_color(block_color),
        .block_direction(block_direction),
        .block_position_ready(block_position_ready)
    );

    state_processor state_processor(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .block_visible(block_visible),
        .curr_block_index_in(curr_block_index_out),
        .block_x(block_x),
        .block_y(block_y),
        .block_z(block_z),
        .block_color(block_color),
        .block_direction(block_direction),
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
        .x_in(x_in),
        .y_in(y_in),
        .block_visible(block_visible),
        .curr_block_index_in(curr_block_index_out),
        .block_x(block_x),
        .block_y(block_y),
        .block_z(block_z),
        .block_color(block_color),
        .block_direction(block_direction),
        .state(state),
        .curr_time(curr_time),
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