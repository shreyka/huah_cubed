`timescale 1ns / 1ps
`default_nettype none

/*

Given the 12 closest blocks,
calculate the visibility and z
positions of each block 

*/
module block_positions(
    input wire clk_in,
    input wire rst_in,

    input wire [17:0] curr_time_in,

    input wire [11:0] [11:0] block_x_in,
    input wire [11:0] [11:0] block_y_in,
    input wire [11:0] [17:0] block_time_in,
    input wire [11:0] block_color_in,
    input wire [11:0] [2:0] block_direction_in, 
    input wire [11:0] [7:0] block_ID_in, 

    output logic [17:0] curr_time_out,

    output logic [11:0] [11:0] block_x_out,
    output logic [11:0] [11:0] block_y_out,
    output logic [11:0] [13:0] block_z_out, //NEW
    output logic [11:0] block_color_out,
    output logic [11:0] [2:0] block_direction_out,
    output logic [11:0] [7:0] block_ID_out,
    output logic [11:0] block_visible_out //NEW
    );

    logic [11:0] block_visible_logic;
    logic [11:0] [13:0] block_z_out_logic;

    logic [11:0] [13:0] block_z_out_pipeline;
    logic [11:0] block_visible_out_pipeline;

    always_comb begin
        for (int i = 0; i < 12; i = i + 1) begin
            block_visible_logic[i] = block_time_in[i] > curr_time_in && block_time_in[i] <= 150 + curr_time_in;
            // block_z_out_logic[i] = block_visible_logic 
            //             ? 3000 - (20 * (150 - (block_time_in[i] - curr_time_in))) 
            //             : 0;
        end
    end

    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            block_visible_out <= 0;
            block_z_out <= 0;
        end else begin
            // passthrough, we can assume this is okay?? but not really
            curr_time_out <= curr_time_in;
            block_x_out <= block_x_in;
            block_y_out <= block_y_in;
            block_color_out <= block_color_in;
            block_direction_out <= block_direction_in;
            block_ID_out <= block_ID_in;

            for (int i = 0; i < 12; i = i + 1) begin
                block_z_out_pipeline[i] <= block_visible_logic[i] 
                        ? 20 * (150 - (block_time_in[i] - curr_time_in)) 
                        : 0;
                block_z_out[i] <= block_visible_logic[i] ? 3000 - block_z_out_pipeline[i] : 0;

                // pipelining
                // block_z_out_pipeline[i] <= block_z_out_logic[i];
                // block_visible_out_pipeline[i] <= block_visible_logic[i];

                // block_z_out[i] <= block_z_out_pipeline[i];
                // block_visible_out[i] <= block_visible_out_pipeline[i];
                // block_z_out[i] <= block_z_out_logic[i];
                block_visible_out[i] <= block_visible_logic[i];
            end
        end
    end

endmodule

`default_nettype wire