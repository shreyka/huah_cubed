`default_nettype none
`timescale 1ns / 1ps

module block_loader_tb;

    logic clk, rst;

    logic [17:0] curr_time;

    logic [11:0] [11:0] block_x;
    logic [11:0] [11:0] block_y;
    logic [11:0] [17:0] block_time;
    logic [11:0] block_color;
    logic [11:0] [2:0] block_direction;
    logic [17:0] curr_time_out;

    block_loader uut(
        .clk_in(clk),
        .rst_in(rst),
        .curr_time_in(curr_time),

        .block_x(block_x),
        .block_y(block_y),
        .block_time(block_time),
        .block_color(block_color),
        .block_direction(block_direction),
        .curr_time_out(curr_time_out)
    );

    always begin
        #5;
        clk = !clk;
    end

    // we will increment time every 10 cycles

    initial begin
        $dumpfile("block_loader_tb.vcd");
        $dumpvars(0, block_loader_tb);
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
        curr_time = 100;

        for(int i = 0; i < 11; i = i + 1) #10;

        for(int i = 0; i < 5; i = i + 1) begin
            $display("-> CURRENT TIME: %d, pending=%d", curr_time, uut.pending_shift);
            for(int j = 0; j < 7; j = j + 1) begin
                $display("======== BLOCK NUMBER %d ========", j);
                $display("XY: (%d, %d) T: %d", block_x[j], block_y[j], block_time[j]);
            end
            // $display("COLOR/DIR: %d, %d", block_color[0], block_direction[0]);

            for(int i = 0; i < 3; i = i + 1) #10;

            curr_time = curr_time + 50;
            #10;
        end

        $display("Finishing Sim");
        $finish;
    end

endmodule

`default_nettype none