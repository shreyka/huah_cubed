`timescale 1ns / 1ps
`default_nettype none

/*

Get the RGB value that should
be set at a particular XY coordinate.

*/
module set_pixel_color(
    input wire clk_in,
    input wire rst_in,

    input wire [31:0] block_pos_x,
    input wire [31:0] block_pos_y,
    input wire [31:0] block_pos_z,
    input wire [31:0] block_mat_x,
    input wire [31:0] block_mat_y,
    input wire [31:0] block_mat_z,

    input wire [31:0] ray_x,
    input wire [31:0] ray_y,
    input wire [31:0] ray_z,

    input wire [10:0] x_in,
    input wire [9:0] y_in,

    input wire [31:0] t_in,

    output logic [10:0] x_out,
    output logic [10:0] y_out,
    output logic [3:0] r_out,
    output logic [3:0] g_out,
    output logic [3:0] b_out,
    output logic rgb_valid
    );
endmodule

`default_nettype wire