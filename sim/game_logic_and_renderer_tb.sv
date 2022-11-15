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

    // we will increment time every 10 cycles

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

        hcount = 200;
        vcount = 200;

        #30;

        while(uut.curr_time != 190) begin
            #10;
        end

        // for(int j = 0; j < 3; j = j + 1) begin
        //     $display("CURRENT TIME IS %d", uut.curr_time);
        //     // $display("\tBLOCK POS i=%d is (%d, %d, %d) TIME_HIT=%d visible=%d", uut.curr_block_index_positions_out, uut.block_x, uut.block_y, uut.block_z, uut.block_time, uut.block_visible);
        //     // $display("\tXY: (%d, %d)", uut.x_in, uut.y_in);
        //     // $display("\tRGB: (%d, %d, %d)", uut.r_out, uut.g_out, uut.b_out);

        //     if(j == 0) begin
        //         hcount = 100;
        //         vcount = 200;
        //     end else if(j == 1) begin
        //         hcount = 400;
        //         vcount = 200;
        //     end else begin
        //         hcount = 200;
        //         vcount = 400;
        //     end
        //     #120;
        // end

        // for(int j = 0; j < 5; j = j + 1) begin
        //     $display("CURRENT TIME IS %d", uut.curr_time);
        //     $display("BLOCK POS (%d, %d, %d)", uut.block_x_selector, uut.block_y_selector, uut.block_z_selector);

        //     for(int i = 0; i < 1000; i = i+1) #10;
        // end

        $display("Finishing Sim");
        $finish;
    end

endmodule

`default_nettype none