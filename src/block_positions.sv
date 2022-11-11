`timescale 1ns / 1ps
`default_nettype none

module block_positions(
    input wire [7:0] curr_block_index_in,
    input wire [17:0]  curr_time,

    output logic block_visible,
    output logic [7:0] curr_block_index_out,
    output logic [11:0] block_x,
    output logic [11:0] block_y,
    output logic [13:0] block_z,
    output logic block_color,
    output logic [2:0] block_direction,

    output logic block_position_ready
    );

endmodule

`default_nettype wire