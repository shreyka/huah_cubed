`timescale 1ns / 1ps
`default_nettype none

/*

Given a block state and the hand/head states, output whether the block has been sliced, whether the player has been hit by an obstacle, and whether the block has been missed

*/
module state_processor(
    input wire clk_in,
    input wire rst_in,

    input wire block_visible,
    input wire [7:0] curr_block_index_in,
    input wire [11:0] block_x,
    input wire [11:0] block_y,
    input wire [13:0] block_z,
    input wire block_color,
    input wire [2:0] block_direction,

    input wire [1:0] state,

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

    output logic block_sliced,
    output logic player_hit_by_obstacle,
    output logic block_missed
    );

    //TODO: temporarily, this will always just say that the player didn't do anything

    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            block_sliced <= 0;
            player_hit_by_obstacle <= 0;
            block_missed <= 0;
        end else begin
            block_sliced <= 0;
            player_hit_by_obstacle <= 0;
            block_missed <= block_z == 0;
        end
    end
endmodule

`default_nettype wire