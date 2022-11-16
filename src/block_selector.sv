`timescale 1ns / 1ps
`default_nettype none

/*

Given the 12 closest blocks and XY coordinates,
pass out up to one block's data that should
be rendered on this XY coordinate

Essentially a MUX

*/
module block_selector(
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

    logic [9:0] block_size;
    logic [9:0] block_size_2;

    // find index to render, given the inherent ordering of the blocks
    logic [3:0] select_index;
    logic block_hit;
    always_comb begin
        select_index = 12;
        for(int i = 12 - 1; i >= 0; i = i - 1) begin
            block_size = 512 + ($signed(block_z_in[i]) * $signed(-502) >>> 11);
            block_size_2 = (block_size > 512 ? 0 : block_size) >> 2;
            // above ranges from 0 to ~128

            if(block_visible_in[i]) begin
                // check to make sure we are not invalid
                block_hit = 0;
                for(int j = 0; j < 12; j = j + 1) begin
                    if(sliced_blocks[j] == block_ID_in[i]) begin
                        block_hit = 1;
                    end
                end

                if(!block_hit) begin
                    // $display("z=%d, SIZE/2 IS %d", block_z_in[i], block_size_2);
                    if((x_in >= block_x_in[i] - block_size_2 && x_in <= block_x_in[i] + block_size_2 && y_in >= block_y_in[i] - block_size_2 && y_in <= block_y_in[i] + block_size_2)) begin
                        select_index = i;
                    end
                end
            end
        end
    end

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
        end else begin
            //passthrough
            curr_time_out <= curr_time_in;
            x_out <= x_in;
            y_out <= y_in;

            if(select_index != 12) begin
                block_x_out <= block_x_in[select_index];
                block_y_out <= block_y_in[select_index];
                block_z_out <= block_z_in[select_index];
                block_color_out <= block_color_in[select_index];
                block_direction_out <= block_direction_in[select_index];
                block_ID_out <= block_ID_in[select_index];
                block_visible_out <= 1;
            end else begin
                block_x_out <= 0;
                block_y_out <= 0;
                block_z_out <= 0;
                block_color_out <= 0;
                block_direction_out <= 0;
                block_ID_out <= 0;
                block_visible_out <= 0;
            end
        end
    end    

endmodule

`default_nettype wire