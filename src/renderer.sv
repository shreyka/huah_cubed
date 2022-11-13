`timescale 1ns / 1ps
`default_nettype none

module renderer(
    input wire clk_in,
    input wire rst_in,

    input wire [10:0] x_in,
    input wire [9:0] y_in,

    input wire block_visible,
    input wire [7:0] curr_block_index_in,
    input wire [11:0] block_x,
    input wire [11:0] block_y,
    input wire [13:0] block_z,
    input wire block_color,
    input wire [2:0] block_direction,

    input wire [1:0] state,
    input wire [17:0] curr_time,
    input wire [17:0] max_time,
    input wire [11:0] score_in,
    input wire [3:0] health_in,
    input wire [2:0] combo_in,

    input wire [11:0] hand_x_left_bottom,
    input wire [11:0] hand_y_left_bottom,
    input wire [13:0] hand_z_left_bottom,
    input wire [11:0] hand_x_left_top,
    input wire [11:0] hand_y_left_top,
    input wire [13:0] hand_z_left_top,
    input wire [11:0] hand_x_right_bottom,
    input wire [11:0] hand_y_right_bottom,
    input wire [13:0] hand_z_right_bottom,
    input wire [11:0] hand_x_right_top,
    input wire [11:0] hand_y_right_top,
    input wire [13:0] hand_z_right_top,
    input wire [11:0] head_x,
    input wire [11:0] head_y,
    input wire [13:0] head_z,

    output logic [4:0] r_out,
    output logic [5:0] g_out,
    output logic [4:0] b_out
    );

    /*
    Given a specific time, need to figure out how to place the blocks on the map
    */

    logic [9:0] block_size;

    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            r_out <= 0;
            g_out <= 0;
            b_out <= 0;
        end else begin
            block_size <= 512 + ($signed(block_z) * $signed(502) / $signed(-3000));

            // $display("size is z=%d, %d", block_z, block_size);

            if(x_in >= block_x && x_in <= block_x + block_size && y_in >= block_y && y_in <= block_y + block_size) begin
                r_out <= 0;
                g_out <= 0;
                b_out <= 4'hF;
            end else begin
                r_out <= 0;
                g_out <= 0;
                b_out <= 0;
            end
        end
    end

endmodule

`default_nettype wire