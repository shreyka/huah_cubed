`default_nettype none
`timescale 1ns / 1ps

module hand_controller_tb;

    logic clk, rst;

    logic left_button;
    logic right_button;
    logic up_button;
    logic down_button;

    logic [11:0] hand_x_left_bottom;
    logic [11:0] hand_y_left_bottom;
    logic [13:0] hand_z_left_bottom;
    logic [11:0] hand_x_left_top;
    logic [11:0] hand_y_left_top;
    logic [13:0] hand_z_left_top;

    hand_controller uut(
        .clk_in(clk),
        .rst_in(rst),
        .left_button(left_button),
        .right_button(right_button),
        .up_button(up_button),
        .down_button(down_button),

        .hand_x_left_bottom(hand_x_left_bottom),
        .hand_y_left_bottom(hand_y_left_bottom),
        .hand_z_left_bottom(hand_z_left_bottom),
        .hand_x_left_top(hand_x_left_top),
        .hand_y_left_top(hand_y_left_top),
        .hand_z_left_top(hand_z_left_top)
    );

    always begin
        #5;
        clk = !clk;
    end

    // we will increment time every 10 cycles

    initial begin
        $dumpfile("hand_controller_tb.vcd");
        $dumpvars(0, hand_controller_tb);
        $display("Starting Sim");

        clk = 0;
        rst = 0;
        #10;
        rst = 1;
        #10;
        rst = 0;
        #10;

        #10;

        // inputs
        $display("POS: (%d, %d)", hand_x_left_bottom, hand_y_left_bottom);

        for (int i = 0; i < 2000; i = i + 1) begin
            $display("POS: (%d, %d)", hand_x_left_bottom, hand_y_left_bottom);

            left_button = 1;
            #10;
            left_button = 0;
            #10;
        end    

        $display("Finishing Sim");
        $finish;
    end

endmodule

`default_nettype none