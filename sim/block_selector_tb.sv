`default_nettype none
`timescale 1ns / 1ps

module block_selector_tb;

    logic clk, rst;

    logic [17:0] curr_time;

    logic [10:0] x_in;
    logic [9:0] y_in;

    logic [11:0] [11:0] block_x_in;
    logic [11:0] [11:0] block_y_in;
    logic [11:0] [17:0] block_time_in;
    logic [11:0] block_color_in;
    logic [11:0] [2:0] block_direction_in; 
    logic [11:0] block_visible_in;

    logic [17:0] curr_time_out;
    logic [10:0] x_out;
    logic [9:0] y_out;

    logic [11:0] [11:0] block_x_out;
    logic [11:0] [11:0] block_y_out;
    logic [11:0] [13:0] block_z_out;
    logic [11:0] block_color_out;
    logic [11:0] [2:0] block_direction_out;
    logic [11:0] block_visible_out;

    block_positions uut(
        .clk_in(clk),
        .rst_in(rst),
        .curr_time_in(curr_time),
        .block_x_in(block_x_in),
        .block_y_in(block_y_in),
        .block_time_in(block_time_in),
        .block_color_in(block_color_in),
        .block_direction_in(block_direction_in),

        .curr_time_out(curr_time_out),
        .block_x_out(block_x_out),
        .block_y_out(block_y_out),
        .block_z_out(block_z_out),
        .block_color_out(block_color_out),
        .block_direction_out(block_direction_out),
        .block_visible_out(block_visible_out)
    );

    block_selector uut2(
        .clk_in(clk),
        .rst_in(rst),
        .curr_time_in(curr_time_out),
        .x_in(x_out),
        .y_in(y_out),
        .block_x_in(block_x_out),
        .block_y_in(block_y_out),
        .block_z_in(block_z_out),
        .block_color_in(block_color_out),
        .block_direction_in(block_direction_out),
        .block_visible_in(block_visible_out)

        // .curr_time_out(curr_time_out),
        // .x_out(x_out),
        // .y_out(y_out),
        // .block_x_out(block_x_out),
        // .block_y_out(block_y_out),
        // .block_z_out(block_z_out),
        // .block_color_out(block_color_out),
        // .block_direction_out(block_direction_out),
        // .block_visible_out(block_visible_out)
    );

    always begin
        #5;
        clk = !clk;
    end

    // we will increment time every 10 cycles

    initial begin
        $dumpfile("block_selector_tb.vcd");
        $dumpvars(0, block_selector_tb);
        $display("Starting Sim");

        clk = 0;
        rst = 0;
        #10;
        rst = 1;
        #10;
        rst = 0;
        #10;

        curr_time = 0;
        block_x_in[0] = 200;
        block_y_in[0] = 200;
        block_time_in[0] = 150;
        block_visible_in[0] = 1;
        #10;

        for(int i = 0; i < 31; i = i + 1) begin
            curr_time = curr_time + 5;
            $display("time is %d", curr_time);
            #10;
        end

        $display("Finishing Sim");
        $finish;
    end

endmodule

`default_nettype none