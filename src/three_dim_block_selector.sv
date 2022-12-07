`timescale 1ns / 1ps
`default_nettype none

/*

Given the 12 closest blocks and XY coordinates,
pass out up to one block's data that should
be rendered on this XY coordinate

Essentially a MUX

ThIS IS THE PROBLEM CHILD

*/
module three_dim_block_selector(
    input wire clk_in,
    input wire rst_in,

    input wire [17:0] curr_time_in,

    input wire [10:0] x_in,
    input wire [9:0] y_in,

    input wire [11:0] [7:0] sliced_blocks,

    input wire [11:0] [11:0] block_x_in,
    input wire [11:0] [11:0] block_y_in,
    input wire [11:0] [13:0] block_z_in,
    input wire [11:0] block_color_in,
    input wire [11:0] [2:0] block_direction_in, 
    input wire [11:0] [7:0] block_ID_in, 
    input wire [11:0] block_visible_in,

    output logic [17:0] curr_time_out,
    output logic [10:0] x_out,
    output logic [9:0] y_out,

    output logic [11:0] block_x_out,
    output logic [11:0] block_y_out,
    output logic [13:0] block_z_out,
    output logic block_color_out,
    output logic [2:0] block_direction_out,
    output logic [7:0] block_ID_out,
    output logic block_visible_out
    );

    logic [31:0] ray_out_x, ray_out_y, ray_out_z;
    logic [3:0] select_index;
    logic [31:0] best_t;
    logic res_valid;
    logic [10:0] x_out_inter;
    logic [9:0] y_out_inter;
    get_intersecting_block get_intersecting_block(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .x_in(x_in),
        .y_in(y_in),
        .valid_in(1'b1),

        .block_x_notfloat_in(block_x_in),
        .block_y_notfloat_in(block_y_in),
        .block_z_notfloat_in(block_z_in),

        .ray_out_x(ray_out_x),
        .ray_out_y(ray_out_y),
        .ray_out_z(ray_out_z),
        .x_out(x_out_inter),
        .y_out(y_out_inter),
        .best_block(select_index),
        .best_t(best_t),
        .valid_out(res_valid)
    );

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
        end else begin
            //passthrough
            curr_time_out <= curr_time_in;

            x_out <= x_out_inter;
            y_out <= y_out_inter;

            // assume the 12 block positions cannot update faster than we can compute
            if(res_valid && select_index < 12) begin
                block_x_out <= block_x_in[select_index];
                block_y_out <= block_y_in[select_index];
                block_z_out <= block_z_in[select_index];
                block_color_out <= block_color_in[select_index];
                block_direction_out <= block_direction_in[select_index];
                block_ID_out <= block_ID_in[select_index];
                block_visible_out <= 1;
            end else begin
                block_visible_out <= 0;
            end
        end
    end    

endmodule

`default_nettype wire