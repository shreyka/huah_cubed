`timescale 1ns / 1ps
`default_nettype none

module state_processor(
    output logic block_visible,
    output logic [7:0] curr_block_index_out,
    output logic [11:0] block_x,
    output logic [11:0] block_y,
    output logic [13:0] block_z,
    output logic block_color,
    output logic [2:0] block_direction,
    );

endmodule

`default_nettype wire