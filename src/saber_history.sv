`timescale 1ns / 1ps
`default_nettype none

/*

This module will simply save the saber positions every
5 time cycles, and then print out them in a buffer

*/
module saber_history(
    input wire clk_in,
    input wire rst_in,

    input wire [17:0] curr_time,

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

    output logic [11:0] prev_hand_x_left_bottom,
    output logic [11:0] prev_hand_y_left_bottom,
    output logic [13:0] prev_hand_z_left_bottom,
    output logic [11:0] prev_hand_x_left_top,
    output logic [11:0] prev_hand_y_left_top,
    output logic [13:0] prev_hand_z_left_top,
    output logic [11:0] prev_hand_x_right_bottom,
    output logic [11:0] prev_hand_y_right_bottom,
    output logic [13:0] prev_hand_z_right_bottom,
    output logic [11:0] prev_hand_x_right_top,
    output logic [11:0] prev_hand_y_right_top,
    output logic [13:0] prev_hand_z_right_top
    );

    logic [11:0] stored_hand_x_left_bottom;
    logic [11:0] stored_hand_y_left_bottom;
    logic [13:0] stored_hand_z_left_bottom;
    logic [11:0] stored_hand_x_left_top;
    logic [11:0] stored_hand_y_left_top;
    logic [13:0] stored_hand_z_left_top;
    logic [11:0] stored_hand_x_right_bottom;
    logic [11:0] stored_hand_y_right_bottom;
    logic [13:0] stored_hand_z_right_bottom;
    logic [11:0] stored_hand_x_right_top;
    logic [11:0] stored_hand_y_right_top;
    logic [13:0] stored_hand_z_right_top;

    logic [3:0] time_counter;
    logic [17:0] last_time;

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            time_counter <= 0;
            last_time <= 0;
        end else begin
            if(last_time != curr_time) begin
                if(time_counter == 10) begin
                    time_counter <= 0;
                end else begin    
                    time_counter <= time_counter + 1;
                end
                last_time <= curr_time;

                if(time_counter == 0) begin
                    // $display("prev=%d, curr=%d", prev_hand_x_left_top, hand_x_left_top);
                    // send out the previously stored position
                    prev_hand_x_left_bottom <= stored_hand_x_left_bottom;
                    prev_hand_y_left_bottom <= stored_hand_y_left_bottom;
                    prev_hand_z_left_bottom <= stored_hand_z_left_bottom;
                    prev_hand_x_left_top <= stored_hand_x_left_top;
                    prev_hand_y_left_top <= stored_hand_y_left_top;
                    prev_hand_z_left_top <= stored_hand_z_left_top;

                    prev_hand_x_right_bottom <= stored_hand_x_right_bottom;
                    prev_hand_y_right_bottom <= stored_hand_y_right_bottom;
                    prev_hand_z_right_bottom <= 
                    stored_hand_z_right_bottom;
                    prev_hand_x_right_top <= stored_hand_x_right_top;
                    prev_hand_y_right_top <= stored_hand_y_right_top;
                    prev_hand_z_right_top <= stored_hand_z_right_top;

                    // store the current position
                    stored_hand_x_left_bottom <= hand_x_left_bottom;
                    stored_hand_y_left_bottom <= hand_y_left_bottom;
                    stored_hand_z_left_bottom <= hand_z_left_bottom;
                    stored_hand_x_left_top <= hand_x_left_top;
                    stored_hand_y_left_top <= hand_y_left_top;
                    stored_hand_z_right_top <= hand_z_right_top;

                    stored_hand_x_right_bottom <= hand_x_right_bottom;
                    stored_hand_y_right_bottom <= hand_y_right_bottom;
                    stored_hand_z_right_bottom <= hand_z_right_bottom;
                    stored_hand_x_right_top <= hand_x_right_top;
                    stored_hand_y_right_top <= hand_y_right_top;
                    stored_hand_z_right_top <= hand_z_right_top;
                end
            end
        end
    end

endmodule

`default_nettype wire