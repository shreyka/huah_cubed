`timescale 1ns / 1ps
`default_nettype none

/*

This module is only for testing purposes. It will
be replaced by the camera module.

*/
module hand_controller(
    input wire clk_in,
    input wire rst_in,

    input wire left_button,
    input wire right_button,
    input wire up_button,
    input wire down_button,

    output logic [11:0] hand_x_left_bottom,
    output logic [11:0] hand_y_left_bottom,
    output logic [13:0] hand_z_left_bottom,
    output logic [11:0] hand_x_left_top,
    output logic [11:0] hand_y_left_top,
    output logic [13:0] hand_z_left_top
    );

    localparam MAX_X = 1024;
    localparam MAX_Y = 768;
    localparam MAX_Z = 500;
    localparam HAND_MOVE_SPEED = 128;

    function logic [13:0] new_coord;
        input [13:0] pos;
        input signed [11:0] delta;
        input [13:0] MAX_VAL;

        if ($signed(pos) + delta >= $signed(MAX_VAL)) begin
            return delta;
        end else if($signed(pos) + delta < 0) begin
            return $signed(MAX_VAL) + delta;
        end else begin
            return $signed(pos) + delta;
        end
    endfunction

    function logic [11:0] new_coord_x(input [11:0] pos, input signed [11:0] delta);
        return new_coord({2'b00, pos}, delta, MAX_X);
    endfunction

    function logic [11:0] new_coord_y(input [11:0] pos, input signed [11:0] delta);
        return new_coord({2'b00, pos}, delta, MAX_Y);
    endfunction

    function logic [13:0] new_coord_z(input [11:0] pos, input signed [11:0] delta);
        return new_coord(pos, delta, MAX_Z);
    endfunction

    logic pressing_button;

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            hand_x_left_bottom <= 512;
            hand_y_left_bottom <= 384;
            hand_z_left_bottom <= 0;
            hand_x_left_top <= 512;
            hand_y_left_top <= 384;
            hand_z_left_top <= 0;

            pressing_button <= 0;
        end else begin
            if(left_button || right_button || up_button || down_button) begin
                if(!pressing_button) begin
                    pressing_button <= 1;
                end
            end else begin
                pressing_button <= 0;
            end

            if(!pressing_button) begin
                if(left_button) begin
                    hand_x_left_bottom <= new_coord_x(hand_x_left_bottom, -HAND_MOVE_SPEED);
                    hand_x_left_top <= new_coord_x(hand_x_left_top, -HAND_MOVE_SPEED);
                end else if(right_button) begin
                    hand_x_left_bottom <= new_coord_x(hand_x_left_bottom, HAND_MOVE_SPEED);
                    hand_x_left_top <= new_coord_x(hand_x_left_top, HAND_MOVE_SPEED);
                end

                if(up_button) begin
                    hand_y_left_bottom <= new_coord_y(hand_y_left_bottom, -HAND_MOVE_SPEED);
                    hand_y_left_top <= new_coord_y(hand_y_left_top, -HAND_MOVE_SPEED);
                end else if(down_button) begin
                    hand_y_left_bottom <= new_coord_y(hand_y_left_bottom, HAND_MOVE_SPEED);
                    hand_y_left_top <= new_coord_y(hand_y_left_top, HAND_MOVE_SPEED);
                end
            end
        end
    end

endmodule

`default_nettype wire