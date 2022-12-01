`timescale 1ns / 1ps
`default_nettype none

/*

Given a block position and ray position,
as well as t, return the RGB value of the
collision.

*/
module get_pixel_color(
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

    input wire [31:0] t_in,

    output logic [31:0] r_out,
    output logic [31:0] g_out,
    output logic [31:0] b_out,
    output logic rgb_valid
    );
endmodule

`default_nettype wire