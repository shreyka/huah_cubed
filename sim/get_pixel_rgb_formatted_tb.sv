`default_nettype none
`timescale 1ns / 1ps

module get_pixel_rgb_formatted_tb;

    logic clk, rst;

    logic [3:0] r_pixel;
    logic [3:0] g_pixel;
    logic [3:0] b_pixel;
    logic [31:0] rgb_valid;

    /*
    input wire clk_in,
    input wire rst_in,

    input wire [10:0] x_in,
    input wire [9:0] y_in,

    // WARNING: THIS MUST BE IN FLOAT FORM
    input wire [11:0] [31:0] block_x_in,
    input wire [11:0] [31:0] block_y_in,
    input wire [11:0] [31:0] block_z_in,

    output logic [31:0] ray_out_x,
    output logic [31:0] ray_out_y,
    output logic [31:0] ray_out_z,
    output logic [11:0] best_block,
    output logic [31:0] best_t,
    output logic valid_out
    
    */

    logic [31:0] ray_x;
    logic [31:0] ray_y;
    logic [31:0] ray_z;
    logic [31:0] pos_z;
    logic [31:0] t_in;
    logic valid;
    logic [2:0] block_dir;

    /*
    input wire clk_in,
    input wire rst_in,

    input wire [31:0] block_pos_x,
    input wire [31:0] block_pos_y,
    input wire [31:0] block_pos_z,
    input wire [31:0] block_mat_x,
    input wire [31:0] block_mat_y,
    input wire [31:0] block_mat_z,
    input wire [2:0] block_direction,

    input wire [31:0] ray_x,
    input wire [31:0] ray_y,
    input wire [31:0] ray_z,

    input wire [10:0] x_in,
    input wire [9:0] y_in,
    input wire valid_in,

    input wire [31:0] t_in,

    output logic [10:0] x_out,
    output logic [10:0] y_out,
    output logic [3:0] r_out,
    output logic [3:0] g_out,
    output logic [3:0] b_out,
    output logic rgb_valid
    */

    logic [10:0] x_in, x_out;
    logic [9:0] y_in, y_out;

    get_pixel_rgb_formatted mod(
        .clk_in(clk),
        .rst_in(rst),

        .block_pos_x(32'b01000100111000010000000000000000),
        .block_pos_y(32'b01000100111000010000000000000000),
        .block_pos_z(pos_z),
        .block_mat_x(32'b00111111100000000000000000000000),
        .block_mat_y(32'b00000000000000000000000000000000),
        .block_mat_z(32'b00000000000000000000000000000000),
        .block_dir(block_dir),

        .ray_x(ray_x),
        .ray_y(ray_y),
        .ray_z(ray_z),

        .x_in(x_in),
        .y_in(y_in),
        .valid_in(valid),

        .t_in(t_in),

        .x_out(x_out),
        .y_out(y_out),
        .r_out(r_pixel),
        .g_out(g_pixel),
        .b_out(b_pixel),
        .rgb_valid(rgb_valid)
    );

    always begin
        #5;
        clk = !clk;
    end

    // we will increment time every 10 cycles

    initial begin
        $dumpfile("get_pixel_rgb_formatted_tb.vcd");
        $dumpvars(0, get_pixel_rgb_formatted_tb);
        $display("Starting Sim");

        clk = 0;
        rst = 0;
        #10;
        rst = 1;
        #100;
        rst = 0;
        #10;
    
        valid = 1;
        // first value
        ray_x = 32'b00110111001001111100010110101100;
        ray_y = 32'b00110111001001111100010110101100;
        ray_z = 32'b00111111100000000000000001010100;
        t_in = 32'b01000100100101011111111110011111;
        pos_z = 32'b01000100011110100000000000000000; //1000
        block_dir = 3'b1;
        x_in = 11'd100;
        y_in = 10'd50;
        #10;
        // second value
        ray_x = 32'b00110111001001111100010110101100;
        ray_y = 32'b10111100110011001010011101110100;
        ray_z = 32'b00111111011111111110110000101111;
        t_in = 32'b01000100100010011000101010100110;
        pos_z = 32'b01000100011000010000000000000000; //900
        block_dir = 3'b0;
        x_in = 11'd101;
        y_in = 10'd50;
        #10;
        valid = 0;
        #10;

        for(int i = 0; i < 2000; i = i + 1) begin
            if(rgb_valid) begin
                $display("OUTPUT %d: %b %b %b", i, r_pixel, g_pixel, b_pixel);
                $display("OUTPUT XY %d %d", x_out, y_out);
            end
            #10;
        end

        #10;

        $display("Finishing Sim");
        $finish;
    end

endmodule

`default_nettype none