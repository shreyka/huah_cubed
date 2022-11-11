`timescale 1ns / 1ps
`default_nettype none

module state_processor(
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

endmodule

`default_nettype wire