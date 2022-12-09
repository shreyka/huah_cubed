`timescale 1ns / 1ps
`default_nettype none

/*

Given the 12 closest blocks and XY coordinates,
pass out up to one block's data that should
be rendered on this XY coordinate

Essentially a MUX

AUGMENTED: we also want to check if the saber intersects using the same logic

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

    input wire [11:0] hand_x_left_top,
    input wire [11:0] hand_y_left_top,
    input wire [13:0] hand_z_left_top,

    output logic [17:0] curr_time_out,
    output logic [10:0] x_out,
    output logic [9:0] y_out,

    output logic [31:0] ray_out_x,
    output logic [31:0] ray_out_y,
    output logic [31:0] ray_out_z,
    output logic [31:0] t_out,

    output logic [11:0] block_x_out,
    output logic [11:0] block_y_out,
    output logic [13:0] block_z_out,
    output logic block_color_out,
    output logic [2:0] block_direction_out,
    output logic [7:0] block_ID_out,
    output logic block_visible_out,
    output logic saber_visible_out,
    output logic valid_out
    );

    // current block state
    logic [3:0] current_block_index;

    logic res_valid;
    logic [31:0] ray_out_x_int, ray_out_y_int, ray_out_z_int;
    logic [3:0] block_index_out;
    logic [31:0] t_out_inter;
    logic [10:0] x_out_inter;
    logic [9:0] y_out_inter;

    logic [3:0] best_block_index;
    logic [31:0] best_ray_x, best_ray_y, best_ray_z;
    logic [31:0] best_t;
    logic [10:0] x_in_begin;
    logic [9:0] y_in_begin;
    logic valid_in;

    logic ray_block_intersect_out;
    get_intersecting_block get_intersecting_block(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .x_in(x_in),
        .y_in(y_in),
        .valid_in(valid_in),

        .block_index_in(current_block_index),
        .block_x_notfloat_in(current_block_index == 12 ? hand_x_left_top : block_x_in[current_block_index]),
        .block_y_notfloat_in(current_block_index == 12 ? hand_y_left_top : block_y_in[current_block_index]),
        .block_z_notfloat_in(current_block_index == 12 ? hand_z_left_top : block_z_in[current_block_index]),
        .block_visible_in   (current_block_index == 12 ? 1'b1 : block_visible_in[current_block_index]),

        .ray_out_x(ray_out_x_int),
        .ray_out_y(ray_out_y_int),
        .ray_out_z(ray_out_z_int),
        .x_out(x_out_inter),
        .y_out(y_out_inter),
        .ray_block_intersect_out(ray_block_intersect_out),
        .best_t(t_out_inter),
        .block_index_out(block_index_out),
        .valid_out(res_valid)
    );

    assign ray_out_x = best_ray_x;
    assign ray_out_y = best_ray_y;
    assign ray_out_z = best_ray_z;
    assign t_out = best_t;

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            current_block_index <= 0;
            x_in_begin <= 1024;
            y_in_begin <= 768;
            valid_in <= 0;
        end else begin
            // state machine, check in between
            if (res_valid) begin
                if(ray_block_intersect_out) begin
                    // check saber condition, trumps all others
                    if(best_block_index == 12) begin
                        best_block_index <= best_block_index;
                    // other blocks
                    end else if(block_index_out < best_block_index) begin
                        best_block_index <= block_index_out;
                        best_ray_x <= ray_out_x_int;
                        best_ray_y <= ray_out_y_int;
                        best_ray_z <= ray_out_z_int;
                        best_t <= t_out_inter;
                    end
                end
            end

            // last state, plus the saber
            if (current_block_index == 12) begin
                current_block_index <= 0;
                best_block_index <= 15; //higher than any other blocks

                // disable until next xy is sent in
                valid_in <= 0;
                valid_out <= 1;
                // output best value for this pixel
                if(best_block_index == 12) begin
                    // saber edge condition
                    saber_visible_out <= 1;
                    block_visible_out <= 0;
                end else if(best_block_index < 12) begin
                    saber_visible_out <= 0;

                    block_x_out <= block_x_in[best_block_index];
                    block_y_out <= block_y_in[best_block_index];
                    block_z_out <= block_z_in[best_block_index];
                    block_color_out <= block_color_in[best_block_index];
                    block_direction_out <= block_direction_in[best_block_index];
                    block_ID_out <= block_ID_in[best_block_index];
                    block_visible_out <= 1;
                end else begin
                    saber_visible_out <= 0;
                    block_visible_out <= 0;
                end
            end else if(valid_in) begin
                // increment state
                valid_out <= 0;
                current_block_index <= current_block_index + 1;
            end else if(x_in_begin != x_in || y_in_begin != y_in) begin
                // reset state
                current_block_index <= 0;
                x_in_begin <= x_in;
                y_in_begin <= y_in;
                valid_in <= 1;
            end

            //passthrough
            curr_time_out <= curr_time_in;
            x_out <= x_in_begin;
            y_out <= y_in_begin;
        end
    end    

endmodule

`default_nettype wire