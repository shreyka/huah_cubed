`default_nettype none
`timescale 1ns / 1ps

module get_intersecting_block_tb;

    logic clk, rst;

    logic [10:0] x_in;
    logic [9:0] y_in;
    logic [11:0] [11:0] block_x_in;
    logic [11:0] [11:0] block_y_in;
    logic [11:0] [13:0] block_z_in;
    logic valid_in;

    logic [31:0] ray_out_x, ray_out_y, ray_out_z;
    logic [31:0] best_t;
    logic [10:0] x_out;
    logic [9:0] y_out;

    logic res_valid;
    logic [3:0] best_block;

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

    get_intersecting_block mod(
        .clk_in(clk),
        .rst_in(rst),
        .x_in(x_in),
        .y_in(y_in),
        .valid_in(valid_in),

        .block_x_notfloat_in(block_x_in),
        .block_y_notfloat_in(block_y_in),
        .block_z_notfloat_in(block_z_in),

        .ray_out_x(ray_out_x),
        .ray_out_y(ray_out_y),
        .ray_out_z(ray_out_z),
        .x_out(x_out),
        .y_out(y_out),
        .best_block(best_block),
        .best_t(best_t),
        .valid_out(res_valid)
    );

    always begin
        #5;
        clk = !clk;
    end

    // we will increment time every 10 cycles

    initial begin
        $dumpfile("get_intersecting_block_tb.vcd");
        $dumpvars(0, get_intersecting_block_tb);
        $display("Starting Sim");

        // block_x_in[0] = 32'b01000100111000010000000000000000; //1800
        // block_y_in[0] = 32'b01000100111000010000000000000000; //1800
        // block_z_in[0] = 32'b01000100001011110000000000000000; //700
        // block_x_in[1] = 32'b01000101000000001000000000000000; //2056
        // block_y_in[1] = 32'b01000100111000010000000000000000; //1800
        // block_z_in[1] = 32'b01000100010010000000000000000000; //800

        block_x_in[0] = 200;
        block_y_in[0] = 200;
        block_z_in[0] = 3000;
        block_x_in[1] = 2056;
        block_y_in[1] = 1800;
        block_z_in[1] = 800;

        clk = 0;
        rst = 0;
        #10;
        rst = 1;
        #100;
        rst = 0;
        #100;

        valid_in = 1;
        x_in = 0;
        y_in = 0;
        #10;
        $display("SETTING X/Y AT i=-1");
        x_in = 256;
        y_in = 200;

        // #10;
        // x_in = 350;
        // y_in = 200;
        #10;

        for(int i = 0; i < 2000; i = i + 1) begin
            if(x_in >= 1024) begin
                x_in = 0;
                if (y_in >= 768) begin
                    y_in = 0;
                end else begin
                    y_in += 1;
                end
            end else begin
                x_in += 1;
            end
            $display("%d: X, Y (%d, %d) Z: %d", i, x_in, y_in, block_z_in[0]);

            if (block_z_in[0] >= 10) begin
                block_z_in[0] = block_z_in[0] - 100;
            end

            if(res_valid) begin
                $display("OUTPUT %d: INTSERCT-BLOCK IS %d", i, best_block);
                $display("OUTPUT XY: (%d, %d)", x_out, y_out);
            end
            #10;
        end

        #10;

        $display("Finishing Sim");
        $finish;
    end

endmodule

`default_nettype none