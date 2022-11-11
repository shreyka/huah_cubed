`timescale 1ns / 1ps
`default_nettype none

module renderer(
    input wire block_visible,
    input wire [7:0] curr_block_index_in,
    input wire [11:0] block_x,
    input wire [11:0] block_y,
    input wire [13:0] block_z,
    input wire block_color,
    input wire [2:0] block_direction,

    input wire [1:0] state,
    input wire [17:0] curr_time,
    input wire [17:0] max_time,
    input wire [11:0] score_in,
    input wire [3:0] health_in,

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

    output logic [10:0] x_out,
    output logic [9:0] y_out,
    output logic [4:0] r_out,
    output logic [5:0] g_out,
    output logic [4:0] b_out
    );

endmodule

`default_nettype wire