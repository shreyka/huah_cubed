`default_nettype none
`timescale 1ns / 1ps

module get_pixel_color_tb;

    logic clk, rst;

    logic [31:0] r_pixel;
    logic [31:0] g_pixel;
    logic [31:0] b_pixel;
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

    get_pixel_color mod(
        .clk_in(clk),
        .rst_in(rst),

        .block_pos_x(32'b01000100111000010000000000000000),
        .block_pos_y(32'b01000100111000010000000000000000),
        .block_pos_z(pos_z),
        .block_mat_x(32'b00111111100000000000000000000000),
        .block_mat_y(32'b00000000000000000000000000000000),
        .block_mat_z(32'b00000000000000000000000000000000),
        .block_dir(block_dir),
        .valid_in(valid),

        .ray_x(ray_x),
        .ray_y(ray_y),
        .ray_z(ray_z),

        .t_in(t_in),

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
        $dumpfile("get_pixel_color_tb.vcd");
        $dumpvars(0, get_pixel_color_tb);
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
        #10;
        // second value
        ray_x = 32'b00110111001001111100010110101100;
        ray_y = 32'b10111100110011001010011101110100;
        ray_z = 32'b00111111011111111110110000101111;
        t_in = 32'b01000100100010011000101010100110;
        pos_z = 32'b01000100011000010000000000000000; //900
        block_dir = 3'b0;
        #10;
        valid = 0;
        #10;

        for(int i = 0; i < 2000; i = i + 1) begin
            if(rgb_valid) begin
                $display("OUTPUT %d: %b %b %b", i, r_pixel, g_pixel, b_pixel);
            end
            #10;
        end

        #10;

        $display("Finishing Sim");
        $finish;
    end

endmodule

`default_nettype none