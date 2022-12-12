`timescale 1ns / 1ps
`default_nettype none

/*

Camera interface module

*/
module camera_interface(
    input wire clk_in,
    input wire rst_in,
    
    input wire [15:0] sw,

    input wire [7:0] ja, //lower 8 bits of data from camera
    input wire [2:0] jb, //upper three bits from camera (return clock, vsync, hsync)
    output logic jbclk,  //signal we provide to camera
    output logic jblock,

    input wire [10:0] hcount,    // pixel on current line
    input wire [9:0] vcount,     // line number
    input wire hsync,
    input wire vsync,
    input wire blank,

    output logic [15:0] led,

    output logic [11:0] hand_x_left_bottom, //red, head
    output logic [11:0] hand_y_left_bottom,
    output logic [13:0] hand_z_left_bottom,
    output logic [11:0] hand_x_left_top, //blue, stick
    output logic [11:0] hand_y_left_top,
    output logic [13:0] hand_z_left_top
    );

    logic [3:0] vga_r, vga_g, vga_b;
    logic vga_hs, vga_vs;
    logic [7:0] an;
    logic caa,cab,cac,cad,cae,caf,cag;
    logic transmit;

    logic [13:0] ori_head_x;
    logic [13:0] ori_head_y;
    logic [11:0] camera_x_bottom, camera_y_bottom;
    logic [11:0] camera_x_top, camera_y_top;

    logic [19:0] curr_time_counter;
    logic [6:0] track_ori_count;

    // get ori head
    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            ori_head_x <= 0;
            ori_head_y <= 0;
            curr_time_counter <= 0;
            track_ori_count <= 10; //100 ms
        end else begin
            if(curr_time_counter == 650000) begin
                if(track_ori_count == 0) begin
                    ori_head_x <= camera_x_bottom;
                    ori_head_y <= camera_y_bottom;
                    curr_time_counter <= curr_time_counter + 1;
                end else begin
                    track_ori_count <= track_ori_count - 1;
                    curr_time_counter <= 0;
                end
            end else if(curr_time_counter < 650000) begin
                curr_time_counter <= curr_time_counter + 1;
            end
        end
    end

    camera_top_level cam_uut(
        .clk_65mhz(clk_in), //clock @ 100 mhz
        .sw(sw), //switches
        .sys_rst(rst_in), //btnc (used for reset)

        .hcount(hcount),
        .vcount(vcount),
        .hsync(hsync),
        .vsync(vsync),
        .blank(blank),

        .ja(ja), //lower 8 bits of data from camera
        .jb(jb), //upper three bits from camera (return clock, vsync, hsync)
        .jbclk(jbclk),  //signal we provide to camera
        .jblock(jblock), //signal for resetting camera

        .hand_x_left_bottom(camera_x_bottom),
        .hand_y_left_bottom(camera_y_bottom),
        .hand_z_left_bottom(),
        .hand_x_left_top(camera_x_top),
        .hand_y_left_top(camera_y_top),
        .hand_z_left_top(),

        // outputs we can just ignore in final game
        // .led(led), //just here for the funs

        .vga_r(vga_r), .vga_g(vga_g), .vga_b(vga_b),
        .vga_hs(vga_hs), .vga_vs(vga_vs),
        .an(),
        .caa(),.cab(),.cac(),.cad(),.cae(),.caf(),.cag(),
        .transmit_xy_update(transmit)
    );

    // bottom is head
    // top is hand
    always_comb begin
        if (sw[1]) begin // use HAND
            hand_x_left_top = (1800 + camera_x_top) - ori_head_x;
            hand_y_left_top = (1800 + camera_y_top) - ori_head_y;
        end else begin
            hand_x_left_top = camera_x_top + 1800;
            hand_y_left_top = camera_y_top + 1800;
        end
        
        if (sw[2]) begin // use HEAD
            hand_x_left_bottom = (1800 + camera_x_bottom) - ori_head_x;
            hand_y_left_bottom = (1800 + camera_y_bottom) - ori_head_y;
        end else begin
            hand_x_left_bottom = camera_x_bottom + 1800;
            hand_y_left_bottom = camera_y_bottom + 1800;
        end

        // avoid divide by infinity

        if (hand_x_left_top == 1800) begin
            hand_x_left_top = hand_x_left_top + 1; 
        end
        if (hand_x_left_bottom == 1800) begin
            hand_x_left_bottom = hand_x_left_bottom + 1; 
        end
    end

    assign led[15:12] = camera_x_top;
    assign led[11:8] = camera_y_top;
    assign led[7:4] = camera_x_bottom;
    assign led[3:0] = camera_y_bottom;

endmodule

`default_nettype wire