`timescale 1ns / 1ps
`default_nettype none

/*

Given a block index, i, and the current time,
the current block position for block i.

*/
module block_positions(
    input wire clk_in,
    input wire rst_in,

    input wire [7:0] curr_block_index_in,
    input wire [11:0] block_x,
    input wire [11:0] block_y,
    input wire [17:0] block_time,
    input wire block_color,
    input wire [2:0] block_direction,
    input wire [17:0]  curr_time,

    output logic block_visible,
    output logic [7:0] curr_block_index_out,
    output logic [13:0] block_z,

    output logic block_position_ready
    );

    logic block_visible_logic;

    always_comb begin
        block_visible_logic = block_time > curr_time && block_time - curr_time <= 150;
    end

    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            curr_block_index_out <= 0;
        end else begin
            block_position_ready <= 1;

            block_visible <= block_visible_logic;
            curr_block_index_out <= curr_block_index_in;
            if(block_visible_logic) begin
                block_z <= 3000 - (20 * (150 - (block_time - curr_time)));
            end else begin
                block_z <= 0;
            end
        end
    end

endmodule

`default_nettype wire