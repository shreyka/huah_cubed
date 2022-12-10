`timescale 1ns / 1ps
`default_nettype none

/*

Given a block state and the hand/head states, output whether the block has been sliced,
whether the player has been hit by an obstacle, and whether the block has been missed

*/
module state_processor(
    input wire clk_in,
    input wire rst_in,

    input wire [17:0] curr_time,

    input wire [11:0] block_x,
    input wire [11:0] block_y,
    input wire [13:0] block_z,
    input wire block_visible,
    input wire block_color,
    input wire [2:0] block_direction,
    input wire [7:0] block_ID,

    input wire [1:0] state,

    input wire [11:0] prev_hand_x_left_bottom,
    input wire [11:0] prev_hand_y_left_bottom,
    input wire [13:0] prev_hand_z_left_bottom,
    input wire [11:0] prev_hand_x_left_top,
    input wire [11:0] prev_hand_y_left_top,
    input wire [13:0] prev_hand_z_left_top,
    input wire [11:0] prev_hand_x_right_bottom,
    input wire [11:0] prev_hand_y_right_bottom,
    input wire [13:0] prev_hand_z_right_bottom,
    input wire [11:0] prev_hand_x_right_top,
    input wire [11:0] prev_hand_y_right_top,
    input wire [13:0] prev_hand_z_right_top,

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

    output logic block_sliced,
    output logic [11:0] block_x_out,
    output logic [11:0] block_y_out,
    output logic [13:0] block_z_out,
    output logic block_color_out,
    output logic [2:0] block_direction_out,
    output logic [7:0] block_ID_out,
    output logic player_hit_by_obstacle,
    output logic block_missed
    );

    typedef enum {
        UP, RIGHT, DOWN, LEFT, ANY
    } direction;

    //TODO: temporarily, we will only consider 2D intersections for testing purposes, before working 3D

    // used in the saber direction calculation
    logic signed [14:0] delta_x_top, delta_y_top;
    logic signed [13:0] delta_x_top_abs, delta_y_top_abs;

    localparam MOVEMENT_THRESHOLD = 32;

    function logic [2:0] get_saber_direction;
        input [11:0] prev_x_bottom;
        input [11:0] prev_y_bottom;
        input [13:0] prev_z_bottom;
        input [11:0] prev_x_top;
        input [11:0] prev_y_top;
        input [13:0] prev_z_top;

        input [11:0] curr_x_bottom;
        input [11:0] curr_y_bottom;
        input [13:0] curr_z_bottom;
        input [11:0] curr_x_top;
        input [11:0] curr_y_top;
        input [13:0] curr_z_top;

        delta_x_top = $signed({2'b0, curr_x_top}) - $signed({2'b0, prev_x_top});
        delta_y_top = $signed({2'b0, curr_y_top}) - $signed({2'b0, prev_y_top});

        // $display("DELTAS ARE %d, %d", delta_x_top, delta_y_top);

        delta_x_top_abs = delta_x_top[13] ? -delta_x_top : delta_x_top;
        delta_y_top_abs = delta_y_top[13] ? -delta_y_top : delta_y_top;

        if(delta_x_top_abs >= MOVEMENT_THRESHOLD && delta_x_top_abs > delta_y_top_abs) begin
            return delta_x_top >= 0 ? RIGHT : LEFT;
        end else if(delta_y_top_abs >= MOVEMENT_THRESHOLD && delta_y_top_abs > delta_x_top_abs) begin
            return delta_y_top >= 0 ? DOWN : UP;
        end

        return ANY;
    endfunction

    logic [17:0] last_sliced_time;
    logic [7:0] last_sliced_block_ID;

    function logic saber_overlaps;
        input [11:0] top_x;
        input [11:0] top_y;
        input [13:0] top_z;

        return block_x >= top_x - 100 && block_x <= top_x + 100 && block_y >= top_y - 100 && block_y <= top_y + 100;
    endfunction

    logic [2:0] left_hand_direction;
    logic [2:0] right_hand_direction;

    // always_comb begin
    //     $display("DIRECTION IS (0=UP, 1=RIGHT, 2=DOWN, 3=LEFT, 4=ANY) %d", left_hand_direction);
    // end

    assign left_hand_direction = get_saber_direction(prev_hand_x_left_bottom, prev_hand_y_left_bottom, prev_hand_z_left_bottom, prev_hand_x_left_top, prev_hand_y_left_top, prev_hand_z_left_top, hand_x_left_bottom, hand_y_left_bottom, hand_z_left_bottom, hand_x_left_top, hand_y_left_top, hand_z_left_top);
    assign right_hand_direction = get_saber_direction(prev_hand_x_right_bottom, prev_hand_y_right_bottom, prev_hand_z_right_bottom, prev_hand_x_right_top, prev_hand_y_right_top, prev_hand_z_right_top, hand_x_right_bottom, hand_y_right_bottom, hand_z_right_bottom, hand_x_right_top, hand_y_right_top, hand_z_right_top);

    always_comb begin
        if(left_hand_direction != ANY) begin
            // $display("LEFT DIRS (U, R, D, L, A): %d", left_hand_direction);
            // $display("BLOCK (%d,%d,%d) VS HAND (%d,%d) => OVERLAP? %d", block_x, block_y, block_z, hand_x_left_top, hand_y_left_top, saber_overlaps(prev_hand_x_left_top, prev_hand_y_left_top, prev_hand_z_left_top));
        end
    end

    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            block_sliced <= 0;
            player_hit_by_obstacle <= 0;
            block_missed <= 0;
            last_sliced_time <= 0;
            last_sliced_block_ID <= 0;
        end else begin
            //TODO: same for right hand
            //we only can slice once per timestep so that the
            // broken state change can propagate correctly
            if(block_visible && last_sliced_block_ID != block_ID && last_sliced_time != curr_time && left_hand_direction == block_direction && block_z <= 600 && saber_overlaps(prev_hand_x_left_top, prev_hand_y_left_top, prev_hand_z_left_top)) begin
                last_sliced_time <= curr_time;
                block_x_out <= block_x;
                block_y_out <= block_y; 
                block_z_out <= block_z;
                last_sliced_block_ID <= block_ID;
                block_color_out <= block_color;
                block_direction_out <= block_direction;

                block_sliced <= 1;
                block_ID_out <= block_ID;
            end else begin
                block_sliced <= 0;
                block_ID_out <= 0;
            end
            player_hit_by_obstacle <= 0;
            block_missed <= block_z == 0;
        end
    end
endmodule

`default_nettype wire