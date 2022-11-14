`timescale 1ns / 1ps
`default_nettype none

/*

Given a block index, i,
we want to get the block data.

*/
module block_loader(
    input wire clk_in,
    input wire rst_in,

    output logic [7:0] curr_block_index_out,
    output logic [11:0] block_x,
    output logic [11:0] block_y,
    output logic [17:0] block_time,
    output logic block_color,
    output logic [2:0] block_direction
    );

    typedef enum {
        UP, RIGHT, DOWN, LEFT, ANY
    } direction;

    typedef enum {
        BLUE, RED
    } block_color_enum;

    // TODO: in the future, this should read from a BRAM. for simplicity, this will only return 3 blocks at preset times
    /*
    -> pretend the song is only 4 seconds long, max_time=400
    -> each block takes one second to get to the player
    -> each block will have 3 frames until it reaches the player at z=0, which occurs at timesteps t (spawn), t+33, t+66, t+99 (player)
    -> block 0
        -> ()
    */

    localparam MAX_BLOCKS = 4;

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            curr_block_index_out <= 0;
        end else begin
            // loop all blocks in order
            if (curr_block_index_out == MAX_BLOCKS - 1) begin
                curr_block_index_out <= 0;
            end else begin
                curr_block_index_out <= curr_block_index_out + 1;
            end

            case(curr_block_index_out)
                0: begin
                    block_x <= 200;
                    block_y <= 200;
                    block_time <= 200;
                    block_color <= RED;
                    block_direction <= UP;
                end
                1: begin
                    block_x <= 300;
                    block_y <= 200;
                    block_time <= 300;
                    block_color <= BLUE;
                    block_direction <= RIGHT;
                end
                2: begin
                    block_x <= 400;
                    block_y <= 200;
                    block_time <= 400;
                    block_color <= BLUE;
                    block_direction <= DOWN;
                end
                3: begin
                    block_x <= 500;
                    block_y <= 200;
                    block_time <= 500;
                    block_color <= RED;
                    block_direction <= LEFT;
                end
            endcase
        end
    end

endmodule

`default_nettype wire