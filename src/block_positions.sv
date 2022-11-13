`timescale 1ns / 1ps
`default_nettype none

/*

Given a block index, i, and the current time,
we want to get the block data, as well as the
current block position for block i.

*/
module block_positions(
    input wire clk_in,
    input wire rst_in,

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

    // TODO: in the future, this should read from a BRAM. for simplicity, this will only return 3 blocks at preset times
    /*
    -> pretend the song is only 4 seconds long, max_time=400
    -> each block takes one second to get to the player
    -> each block will have 3 frames until it reaches the player at z=0, which occurs at timesteps t (spawn), t+33, t+66, t+99 (player)
    -> block 0
        -> ()
    */

    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            curr_block_index_out <= 0;
        end else begin

            block_visible <= 1;
            curr_block_index_out <= curr_block_index_in;
            block_x <= 200;
            block_y <= 200;
            block_color <= 1;
            block_direction <= 0;
            block_position_ready <= 1;

            if(curr_time < 150) begin
                block_z <= 3000 - (20 * curr_time);
            end else begin
                block_z <= 0;
            end
        end
    end

endmodule

`default_nettype wire