`timescale 1ns / 1ps
`default_nettype none

module game_state(
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

    input wire [3:0] health_in,
    input wire [11:0] score_in,
    input wire [2:0] combo_in,

    // for SPI to block_positions
    input wire block_position_ready,

    output logic[1:0]   state,
    output logic[3:0]   health_out,
    output logic[11:0]  score_out,
    output logic[2:0]   combo_out,
    output logic[17:0]  curr_time,
    output logic[17:0]  max_time
    );

    localparam STATE_MENU = 0;
    localparam STATE_PLAYING = 1;
    localparam STATE_WON = 2;
    localparam STATE_LOST = 3;

endmodule

`default_nettype wire