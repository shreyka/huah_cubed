`default_nettype none
`timescale 1ns / 1ps

module perpendicularize_tb;

    logic clk, rst;

    logic [10:0] hcount;
    logic [9:0] vcount;

    logic [24:0] m_in;
    logic [17:0] b_in; 
    logic [10:0] x_com;
    logic [9:0] y_com;
    logic valid_in;
    logic tabulate_in;
    logic signed [24:0] m_out;
    logic signed [17:0] b_out; 
    logic valid_out;


    perpendicularize uut(
        .clk_in(clk),
        .rst_in(rst),
        .m_in(m_in),  // shifted up by 8 bits 1b.16bits.8bits sign.whole num.decimal
        .b_in(b_in),
        .x_com(x_com),  
        .y_com(y_com),
        .valid_in(valid_in),
        .tabulate_in(tabulate_in),
        .m_out(m_out),
        .b_out(b_out),
        .valid_out(valid_out));

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

        valid_in = 0;
        tabulate_in = 0;
        m_in = 1 ; 
        b_in = 300;
        x_com = 100;
        y_com = 500;
        #10;
        valid_in = 1;
        #10;
        for(int i = 0; i < 100; i = i+1) begin
            if (valid_out) begin 
                $display("m_out IS %d", uut.m_out);
                $display("b_out IS %d", uut.b_out);
            end
        end

        // for(int j = 0; j < 4; j = j + 1) begin
        //     // $display("CURRENT TIME IS %d", uut.curr_time);
        //     // $display("BLOCK POS i=%d is (%d, %d, %d)", uut.curr_block_index_out, uut.block_x, uut.block_y, uut.block_z);
        //     // $display("MISSED? %d", uut.block_missed);
            
        //     for(int i = 0; i < 50; i = i+1) #10;
        // end

        #2000;
        
        $display("Finishing Sim");
        $finish;
    end

endmodule

`default_nettype none


///////// iverilog -g2012 -Wall -o sim/per.out sim/perpendicularize_tb.sv src/perpendicularize.sv src/divider.sv
//////// vvp sim/per.out
///////   gtkwave perpendicularize_tb.vcd


////////