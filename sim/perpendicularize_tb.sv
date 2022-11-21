`default_nettype none
`timescale 1ns / 1ps

module perpendicularize_tb;

    logic clk, rst;

    logic [10:0] hcount;
    logic [9:0] vcount;


    perpendicularize uut(
        .clk_in(),
        .rst_in(,)
        .m_in(),  // shifted up by 8 bits 1b.16bits.8bits sign.whole num.decimal
        .b_in(),
        .x_com(),  
        .y_com(),
        .valid_in(),
        .tabulate_in(),
        .m_out(),
        .b_out(),
        .valid_out());

    always begin
        #5;
        clk = !clk;
    end

    initial begin
        $dumpfile("perpendicularize_tb.vcd");
        $dumpvars(0, perpendicularize_tb);
        $display("Starting Sim");

        clk = 0;
        rst = 0;
        #10;
        rst = 1;
        #10;
        rst = 0;
        #20;

        for(int j = 0; j < 4; j = j + 1) begin
            // $display("CURRENT TIME IS %d", uut.curr_time);
            // $display("BLOCK POS i=%d is (%d, %d, %d)", uut.curr_block_index_out, uut.block_x, uut.block_y, uut.block_z);
            // $display("MISSED? %d", uut.block_missed);
            
            for(int i = 0; i < 50; i = i+1) #10;
        end

        #200;
        
        $display("Finishing Sim");
        $finish;
    end

endmodule

`default_nettype none