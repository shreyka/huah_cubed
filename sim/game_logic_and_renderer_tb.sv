`default_nettype none
`timescale 1ns / 1ps

module game_logic_and_renderer_tb;

    logic clk, rst;

    logic [10:0] hcount;
    logic [9:0] vcount;

    logic [11:0] hand_x_left_bottom;
    logic [11:0] hand_y_left_bottom;
    logic [13:0] hand_z_left_bottom;
    logic [11:0] hand_x_left_top;
    logic [11:0] hand_y_left_top;
    logic [13:0] hand_z_left_top;
    logic [11:0] hand_x_right_bottom;
    logic [11:0] hand_y_right_bottom;
    logic [13:0] hand_z_right_bottom;
    logic [11:0] hand_x_right_top;
    logic [11:0] hand_y_right_top;
    logic [13:0] hand_z_right_top;
    logic [11:0] head_x;
    logic [11:0] head_y;
    logic [13:0] head_z;

    logic [4:0] r_out;
    logic [5:0] g_out;
    logic [4:0] b_out;

    game_logic_and_renderer uut(
        .clk_in(clk),
        .rst_in(rst),
        // retrieve from VGA
        .x_in(hcount),
        .y_in(vcount),
        
        // retrieve from camera data
        .hand_x_left_bottom(hand_x_left_bottom),
        .hand_y_left_bottom(hand_y_left_bottom),
        .hand_z_left_bottom(hand_z_left_bottom),
        .hand_x_left_top(hand_x_left_top),
        .hand_y_left_top(hand_y_left_top),
        .hand_z_left_top(hand_z_left_top),
        .hand_x_right_bottom(hand_x_right_bottom),
        .hand_y_right_bottom(hand_y_right_bottom),
        .hand_z_right_bottom(hand_z_right_bottom),
        .hand_x_right_top(hand_x_right_top),
        .hand_y_right_top(hand_y_right_top),
        .hand_z_right_top(hand_z_right_top),
        .head_x(head_x),
        .head_y(head_y),
        .head_z(head_z),

        // outputs
        .r_out(r_out),
        .g_out(g_out),
        .b_out(b_out)
    );

    always begin
        #5;
        clk = !clk;
    end

    initial begin
        $dumpfile("game_logic_and_renderer_tb.vcd");
        $dumpvars(0, game_logic_and_renderer_tb);
        $display("Starting Sim");

        clk = 0;
        rst = 0;
        #10;
        rst = 1;
        #10;
        rst = 0;
        #20;

        for(int j = 0; j < 4; j = j + 1) begin
            $display("CURRENT TIME IS %d", uut.curr_time);
            $display("BLOCK POS i=%d is (%d, %d, %d)", uut.curr_block_index_out, uut.block_x, uut.block_y, uut.block_z);
            $display("MISSED? %d", uut.block_missed);
            
            for(int i = 0; i < 50; i = i+1) #10;
        end

        #200;
        
        $display("Finishing Sim");
        $finish;
    end

endmodule

`default_nettype none