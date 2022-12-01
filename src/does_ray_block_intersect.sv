`timescale 1ns / 1ps
`default_nettype none

/*

Given a ray and a block position, return
if they intersect with each other.

This module is separated into 6 stages.

*/
module does_ray_block_intersect(
    input wire clk_in,
    input wire rst_in,
    
    input wire [31:0] ray_x,
    input wire [31:0] ray_y,
    input wire [31:0] ray_z,
    input wire [31:0] block_pos_x,
    input wire [31:0] block_pos_y,
    input wire [31:0] block_pos_z,
    input wire [31:0] t_in,
    input wire valid_in,

    output logic intersects_data_out,
    output logic [31:0] t_out,
    output logic valid_out
    );

    ////////////////////////////////////////////////////
    // VARIABLE CONSTANTS
    //
    // precomputed constants go here
    //

    logic [31:0] block_size;
    // 100
    assign block_size = 32'b01000010110010000000000000000000;

    ////////////////////////////////////////////////////
    // REQUIRED VARIABLES
    //
    // module variables go here
    //

    logic [31:0] tmin, tmax;

    // stage 0
    logic [31:0] block_min_x, block_min_y, block_min_z;
    logic block_min_valid;
    logic [31:0] block_max_x, block_max_y, block_max_z;
    logic block_max_valid;

    // stage 1
    logic [31:0] min_e, max_e;
    logic [31:0] tx1, tx2;
    logic minmaxe_tx12_valid;

    // stage 2
    logic [31:0] min_tx12_lt, max_tx12_lt;

    ////////////////////////////////////////////////////
    // MODULE LOGIC
    //
    // the entire chain of events go here
    //

    vec_sub block_min_sub(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .v1_x(block_pos_x),
        .v1_y(block_pos_y),
        .v1_z(block_pos_z),
        .v2_x(block_size),
        .v2_y(block_size),
        .v2_z(block_size),
        .v_valid(valid_in),

        .res_data_x(block_min_x),
        .res_data_y(block_min_y),
        .res_data_z(block_min_z),
        .res_valid(block_min_valid)
    );

    vec_add block_max_add(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .v1_x(block_pos_x),
        .v1_y(block_pos_y),
        .v1_z(block_pos_z),
        .v2_x(block_size),
        .v2_y(block_size),
        .v2_z(block_size),
        .v_valid(valid_in),

        .res_data_x(block_max_x),
        .res_data_y(block_max_y),
        .res_data_z(block_max_z),
        .res_valid(block_max_valid)
    );

    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            tmin <= 32'b11001011000110001001011010000000; //-10000000
            tmax <= 32'b01001011000110001001011010000000; // 10000000
        end else begin

        end
    end
endmodule

`default_nettype wire